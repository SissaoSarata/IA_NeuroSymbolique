#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║          LANDGUARD NEURO-SYMBOLIC AI — main.py                  ║
║          Pipeline d'orchestration complet                        ║
║          Contexte : Burkina Faso — 50 dossiers fonciers         ║
╠══════════════════════════════════════════════════════════════════╣
║  Flux complet :                                                  ║
║   1. Chargement du dataset (dataset.csv)                        ║
║   2. Inférence neuronale   (PyTorch — FraudDetectionNet)        ║
║   3. Inférence probabiliste (ProbLog — probabilistic_rules.pl)  ║
║   4. Évaluation règles logiques (Prolog — rules.pl simulé)      ║
║   5. Fusion neuro-symbolique (DeepProbLog)                      ║
║   6. Génération rapport consolidé (XAI + décisions)             ║
╚══════════════════════════════════════════════════════════════════╝
"""

import os, sys, csv, json, re, warnings, time
from pathlib import Path
from datetime import datetime
from collections import defaultdict, Counter

import numpy as np
import torch

warnings.filterwarnings("ignore")

# ── Imports locaux ──────────────────────────────────────────────
BASE_DIR = Path(__file__).parent
sys.path.insert(0, str(BASE_DIR))

from neural_model import (
    FraudDetectionNet, LandGuardDataset, CLASSES, LABEL_MAP,
    WEIGHTS_PATH, SCALER_PATH, DATASET_PATH,
    load_model, normalize_features, predict_actor,
)
from deepproblog_integration import (
    build_actor_tensors, ACTOR_TENSORS,
    evaluer_regle_ns, construire_signaux_symboliques,
    REGLES_NS, generer_rapport_xai,
)

# ── Import ProbLog ───────────────────────────────────────────────
try:
    from problog.program import PrologString
    from problog import get_evaluatable
    PROBLOG_OK = True
except ImportError:
    PROBLOG_OK = False

# ── Chemins ─────────────────────────────────────────────────────
PROBLOG_RULES = BASE_DIR / "probabilistic_rules.pl"
RAPPORT_PATH  = BASE_DIR / "rapport_final_landguard.txt"
RAPPORT_CSV   = BASE_DIR / "rapport_final_landguard.csv"

# ── Seuils ProbLog ──────────────────────────────────────────────
SEUILS = {"CRITIQUE": 0.80, "ÉLEVÉ": 0.60, "MOYEN": 0.30, "FAIBLE": 0.0}

# ── Correspondance label → classe neuronale ──────────────────────
LABEL_TO_CLASSE = {
    "standard":    "standard",
    "speculateur": "speculateur",
    "accapareur":  "atypique",
    "limite":      "atypique",
    "fraude":      "fraude",
}


# ════════════════════════════════════════════════════════════════
# UTILITAIRES
# ════════════════════════════════════════════════════════════════

def slug(nom: str) -> str:
    n = nom.lower().strip()
    for a, b in [("é","e"),("è","e"),("ê","e"),("à","a"),("â","a"),
                 ("î","i"),("ô","o"),("ù","u"),("û","u"),("ç","c"),
                 ("ñ","n"),("'","_"),(" ","_"),("-","_"),(".","")]:
        n = n.replace(a, b)
    return re.sub(r'[^a-z0-9_]', '', n)


def niveau_risque(p: float) -> str:
    if p >= SEUILS["CRITIQUE"]: return "CRITIQUE"
    if p >= SEUILS["ÉLEVÉ"]:   return "ÉLEVÉ"
    if p >= SEUILS["MOYEN"]:   return "MOYEN"
    return "FAIBLE"


def barre(p: float, w: int = 25) -> str:
    r = int(p * w)
    return f"{'█'*r}{'░'*(w-r)} {p:.1%}"


def sep(char="═", n=68): return char * n


# ════════════════════════════════════════════════════════════════
# ÉTAPE 1 : CHARGEMENT DU DATASET
# ════════════════════════════════════════════════════════════════

def etape1_charger_dataset() -> tuple[list, dict]:
    """
    Charge dataset.csv et retourne :
    - rows     : liste de dicts (une ligne par dossier)
    - index    : {slug_acteur: row}
    """
    print(f"\n  {'─'*60}")
    print(f"  ÉTAPE 1 — Chargement du dataset")
    print(f"  {'─'*60}")

    rows = []
    with open(DATASET_PATH, newline='', encoding='utf-8') as f:
        rows = list(csv.DictReader(f))

    index = {slug(r['nom_acteur']): r for r in rows}

    dist = Counter(r['label'] for r in rows)
    print(f"  ✅ {len(rows)} dossiers chargés depuis {DATASET_PATH.name}")
    print(f"     Distribution : " +
          " | ".join(f"{k}={v}" for k,v in dist.items()))

    return rows, index


# ════════════════════════════════════════════════════════════════
# ÉTAPE 2 : INFÉRENCE NEURONALE (PyTorch)
# ════════════════════════════════════════════════════════════════

def etape2_inference_neuronale(rows: list, index: dict) -> dict:
    """
    Charge FraudDetectionNet et prédit la classe pour chaque acteur.
    Retourne {slug: {'classe', 'confiance', 'probabilites'}}
    """
    print(f"\n  {'─'*60}")
    print(f"  ÉTAPE 2 — Inférence neuronale (PyTorch)")
    print(f"  {'─'*60}")

    # Charger le dataset normalisé
    dataset = LandGuardDataset(str(DATASET_PATH), fit=False,
                               scaler_path=str(SCALER_PATH))
    # Charger le modèle
    model = load_model(str(WEIGHTS_PATH))

    resultats_nn = {}
    correct = 0

    for i, row in enumerate(rows):
        s = slug(row['nom_acteur'])
        x = dataset.samples[i].unsqueeze(0)
        probs = model.predict_proba(x)[0]
        idx   = probs.argmax().item()
        classe_pred = CLASSES[idx]
        conf        = probs[idx].item()
        classe_gt   = LABEL_TO_CLASSE.get(row['label'], 'standard')
        ok = (classe_pred == classe_gt)
        if ok: correct += 1

        resultats_nn[s] = {
            'nom':        row['nom_acteur'],
            'ville':      row['ville'],
            'quartier':   row['quartier'],
            'label_gt':   row['label'],
            'classe_gt':  classe_gt,
            'classe_nn':  classe_pred,
            'confiance':  round(conf, 4),
            'prob_std':   round(probs[0].item(), 4),
            'prob_aty':   round(probs[1].item(), 4),
            'prob_spe':   round(probs[2].item(), 4),
            'prob_fra':   round(probs[3].item(), 4),
            'correct_nn': ok,
        }

    acc = correct / len(rows) * 100
    print(f"  ✅ {len(rows)} acteurs analysés — Accuracy NN : {acc:.1f}%")
    dist_pred = Counter(v['classe_nn'] for v in resultats_nn.values())
    print(f"     Prédictions : " +
          " | ".join(f"{k}={v}" for k,v in dist_pred.items()))

    return resultats_nn


# ════════════════════════════════════════════════════════════════
# ÉTAPE 3 : INFÉRENCE PROBABILISTE (ProbLog)
# ════════════════════════════════════════════════════════════════

def etape3_inference_problog() -> dict:
    """
    Évalue les 23 requêtes ProbLog sur les acteurs burkinabè.
    Retourne {query_label: {'probabilite', 'niveau', 'acteur'}}
    """
    print(f"\n  {'─'*60}")
    print(f"  ÉTAPE 3 — Inférence probabiliste (ProbLog)")
    print(f"  {'─'*60}")

    if not PROBLOG_OK:
        print("  ⚠ ProbLog non disponible — étape ignorée")
        return {}

    with open(PROBLOG_RULES, encoding='utf-8') as f:
        prog = f.read()

    # Requêtes cibles (acteur, prédicat, label lisible)
    QUERIES_BF = [
        ("idrissa_kabore",    "prete_nom(idrissa_kabore,aziz_compaore)",           "Prête-nom Idrissa/Aziz"),
        ("idrissa_kabore",    "prete_nom_familial(idrissa_kabore,aziz_compaore)",   "Prête-nom familial Idrissa/Aziz"),
        ("kassoum_ouedraogo", "prete_nom(kassoum_ouedraogo,mariam_sawadogo)",       "Prête-nom Kassoum/Mariam"),
        ("idrissa_kabore",    "accapareur_urbain(idrissa_kabore)",                  "Accaparement Idrissa (Secteur 30)"),
        ("romuald_sawadogo",  "revente_rapide(romuald_sawadogo)",                   "Revente rapide Romuald"),
        ("gaoussou_traore",   "plus_value_anormale(gaoussou_traore)",               "Plus-value Gaoussou (+133%)"),
        ("romuald_sawadogo",  "speculateur(romuald_sawadogo)",                      "Spéculateur confirmé Romuald"),
        ("paul_sawadogo",     "conflit_familial(paul_sawadogo,kassoum_ouedraogo)",  "Conflit familial Sawadogo/Kassoum"),
        ("paul_sawadogo",     "conflit_familial(paul_sawadogo,mariam_sawadogo)",    "Conflit familial Sawadogo/Mariam"),
        ("ramata_kabore",     "auto_attribution(ramata_kabore)",                    "Auto-attribution Ramata"),
        ("luc_traore",        "auto_attribution(luc_traore)",                       "Auto-attribution Luc Traoré"),
        ("saidou_kabore",     "notaire_conflit(saidou_kabore)",                     "Conflit notaire Saidou"),
        ("kassoum_ouedraogo", "reseau_circulaire(kassoum_ouedraogo,ramata_kabore,adama_compaore)", "Réseau circulaire Kassoum"),
        ("marcelline_traore", "promoteur_fantome(marcelline_traore)",               "Promoteur fantôme Marcelline"),
        ("kassoum_ouedraogo", "suspicion_globale(kassoum_ouedraogo)",               "Suspicion globale Kassoum"),
        ("idrissa_kabore",    "suspicion_globale(idrissa_kabore)",                  "Suspicion globale Idrissa"),
        ("ramata_kabore",     "suspicion_globale(ramata_kabore)",                   "Suspicion globale Ramata"),
        ("romuald_sawadogo",  "suspicion_globale(romuald_sawadogo)",                "Suspicion globale Romuald"),
        ("adama_ouedraogo",   "suspicion_globale(adama_ouedraogo)",                 "Suspicion globale Adama (sain)"),
    ]

    def eval_q(atom):
        full = prog + f"\nquery({atom}).\n"
        try:
            res = get_evaluatable().create_from(
                PrologString(full)).evaluate()
            for v in res.values(): return float(v)
            return 0.0
        except: return -1.0

    resultats_prob = {}
    for acteur, atom, label in QUERIES_BF:
        p = eval_q(atom)
        niv = niveau_risque(p) if p >= 0 else "ERREUR"
        resultats_prob[label] = {
            'acteur':      acteur,
            'probabilite': p,
            'niveau':      niv,
        }
        print(f"    {label:<45} P={p:.4f}  [{niv}]")

    dist_niv = Counter(v['niveau'] for v in resultats_prob.values())
    print(f"\n  ✅ {len(QUERIES_BF)} requêtes — " +
          " | ".join(f"{k}={v}" for k,v in dist_niv.items()))

    return resultats_prob


# ════════════════════════════════════════════════════════════════
# ÉTAPE 4 : ÉVALUATION RÈGLES PROLOG (simulée en Python)
# ════════════════════════════════════════════════════════════════

def etape4_regles_prolog(rows: list) -> dict:
    """
    Applique les 16 règles Prolog (A,B,C,D) sur chaque dossier
    via simulation Python fidèle à rules.pl.
    Retourne {slug: [liste des règles déclenchées]}
    """
    print(f"\n  {'─'*60}")
    print(f"  ÉTAPE 4 — Évaluation règles Prolog (A/B/C/D)")
    print(f"  {'─'*60}")

    alertes = defaultdict(list)

    for row in rows:
        s        = slug(row['nom_acteur'])
        nu       = int(row['nb_parcelles_urbaines'])
        nr       = int(row['nb_parcelles_rurales'])
        nt       = int(row['nb_parcelles_total'])
        pa       = float(row['prix_achat_fcfa'])
        pr       = float(row['prix_revente_fcfa'])
        delai    = int(row['delai_detention_jours'])
        nrev     = int(row['nb_reventes'])
        liens    = int(row['nb_liens_reseau'])
        tel      = row['partage_telephone'] == 'oui'
        adr      = row['partage_adresse']   == 'oui'
        iban     = row['partage_iban']       == 'oui'
        fam_ag   = row['lien_familial_agent'] == 'oui'
        pv_pct   = (pr-pa)/pa*100 if pa > 0 and pr > 0 else 0

        # CATÉGORIE A — ACCAPAREMENT
        if nu >= 4:
            alertes[s].append(("A1", "Accaparement urbain (≥4 parcelles urbaines)"))
        if nr >= 5:
            alertes[s].append(("A2", "Accaparement rural (≥5 parcelles rurales)"))
        if nt >= 6:
            alertes[s].append(("A3", "Multipropriété excessive (≥6 parcelles total)"))
        if liens >= 2 and nu >= 2:
            alertes[s].append(("A4", "Accaparement familial groupé"))

        # CATÉGORIE B — SPÉCULATION
        if delai < 90 and nrev > 0:
            alertes[s].append(("B1", f"Revente ultra-rapide ({delai}j < 90j)"))
        if pv_pct > 80:
            alertes[s].append(("B2", f"Plus-value anormale ({pv_pct:.1f}% > 80%)"))
        if delai < 90 and pv_pct > 80:
            alertes[s].append(("B3", "Spéculateur confirmé (rapide + plus-value)"))
        if delai > 180 and nrev == 0 and pa > 0:
            alertes[s].append(("B4", "Non-mise en valeur (>180j sans cession)"))

        # CATÉGORIE C — CONFLITS D'INTÉRÊTS
        typ = row['type_acteur']
        nb_doss = int(row['nb_dossiers_traites_meme_agent'])
        if typ in ('agent_public','notaire') and fam_ag:
            alertes[s].append(("C1", "Auto-attribution / conflit direct"))
        if fam_ag:
            alertes[s].append(("C2", "Conflit familial avec agent traitant"))
        if nb_doss >= 3 and fam_ag:
            alertes[s].append(("C3", f"Favoritisme répétitif ({nb_doss} dossiers)"))
        if typ == 'notaire' and (tel or adr):
            alertes[s].append(("C4", "Conflit notaire (contacts partagés)"))

        # CATÉGORIE D — RÉSEAUX & PRÊTE-NOMS
        if tel and nt > 0:
            alertes[s].append(("D1", "Prête-nom téléphone (contact partagé)"))
        if adr and fam_ag:
            alertes[s].append(("D2", "Prête-nom adresse+famille"))
        if iban and liens >= 2:
            alertes[s].append(("D3", "Réseau circulaire probable (IBAN+liens)"))
        if iban and adr and tel:
            alertes[s].append(("D4", "Réseau IBAN coordonné (triple partage)"))

    total_alertes = sum(len(v) for v in alertes.values())
    acteurs_flagges = sum(1 for v in alertes.values() if v)
    print(f"  ✅ {total_alertes} alertes Prolog sur {acteurs_flagges} acteurs")

    return dict(alertes)


# ════════════════════════════════════════════════════════════════
# ÉTAPE 5 : FUSION NEURO-SYMBOLIQUE (DeepProbLog)
# ════════════════════════════════════════════════════════════════

def etape5_fusion_ns(resultats_nn: dict,
                     alertes_prolog: dict) -> dict:
    """
    Fusionne prédictions neuronales + règles symboliques.
    Retourne {slug: decision_finale (CRITIQUE/ÉLEVÉ/MOYEN/FAIBLE)}
    """
    print(f"\n  {'─'*60}")
    print(f"  ÉTAPE 5 — Fusion neuro-symbolique (DeepProbLog)")
    print(f"  {'─'*60}")

    build_actor_tensors()
    signaux = construire_signaux_symboliques()
    decisions = {}

    for s, r in resultats_nn.items():
        classe_nn  = r['classe_nn']
        nb_alertes = len(alertes_prolog.get(s, []))
        sym_ok     = bool(signaux.get(s))

        # Score de fusion (pondéré)
        score = 0
        if classe_nn == 'fraude':      score += 4
        elif classe_nn == 'speculateur': score += 3
        elif classe_nn == 'atypique':    score += 2
        score += min(nb_alertes, 4)         # max +4 depuis Prolog
        if sym_ok: score += 2               # signal symbolique confirmé

        # Décision finale
        if score >= 8:   decision = "CRITIQUE"
        elif score >= 5: decision = "ÉLEVÉ"
        elif score >= 2: decision = "MOYEN"
        else:            decision = "FAIBLE"

        decisions[s] = {
            'decision':    decision,
            'score':       score,
            'classe_nn':   classe_nn,
            'nb_alertes_prolog': nb_alertes,
            'symbolique_ok': sym_ok,
        }

    dist = Counter(v['decision'] for v in decisions.values())
    print(f"  ✅ Décisions fusionnées :")
    for niv in ["CRITIQUE","ÉLEVÉ","MOYEN","FAIBLE"]:
        print(f"     {niv:>9} : {dist.get(niv,0)}")

    return decisions


# ════════════════════════════════════════════════════════════════
# ÉTAPE 6 : RAPPORT CONSOLIDÉ (XAI + Décisions)
# ════════════════════════════════════════════════════════════════

def etape6_rapport(rows, resultats_nn, resultats_prob,
                   alertes_prolog, decisions):
    """
    Génère le rapport PDF consolidé :
    - Tableau de synthèse par acteur
    - Détail des alertes Prolog
    - Résultats ProbLog
    - Décisions neuro-symboliques finales
    - Traces XAI
    """
    print(f"\n  {'─'*60}")
    print(f"  ÉTAPE 6 — Génération du rapport consolidé")
    print(f"  {'─'*60}")

    ts    = datetime.now().strftime('%d/%m/%Y %H:%M:%S')
    lignes = []

    def L(*args): lignes.append("  ".join(str(a) for a in args))

    # ── En-tête ─────────────────────────────────────────────────
    L(sep()); L()
    L("LANDGUARD NEURO-SYMBOLIC AI — RAPPORT CONSOLIDÉ FINAL")
    L(f"Burkina Faso — 50 dossiers fonciers | Généré le {ts}")
    L(sep()); L()
    L("ARCHITECTURE DU SYSTÈME :")
    L("  Couche 1 — Logique de Description  : knowledge_base_bf.pl (TBox + ABox)")
    L("  Couche 2 — Raisonnement Prolog     : rules.pl (16 règles A/B/C/D)")
    L("  Couche 3 — ProbLog                 : probabilistic_rules.pl (23 requêtes)")
    L("  Couche 4 — PyTorch (neuronal)      : FraudDetectionNet 12→64→32→16→4")
    L("  Couche 5 — DeepProbLog (hybride)   : nn/4 prédicat + règles NS")
    L("  Couche 6 — XAI                     : explainability.pl + rapport")
    L()

    # ── Synthèse globale ────────────────────────────────────────
    L(sep('─')); L("SYNTHÈSE GLOBALE DES DÉCISIONS"); L(sep('─')); L()
    dist = Counter(v['decision'] for v in decisions.values())
    for niv, emoji in [("CRITIQUE","⚠"),("ÉLEVÉ","▲"),("MOYEN","►"),("FAIBLE","✓")]:
        acteurs_niv = [s for s,d in decisions.items() if d['decision']==niv]
        L(f"  {emoji} {niv:>9} : {dist.get(niv,0):>3} acteur(s)")
        for a in acteurs_niv[:5]:
            nn_info = resultats_nn.get(a, {})
            L(f"       → {nn_info.get('nom', a):<35} "
              f"NN={nn_info.get('classe_nn','?'):>12} "
              f"score={decisions[a]['score']}")
    L()

    # ── Tableau acteur par acteur ────────────────────────────────
    L(sep('─')); L("DÉTAIL PAR ACTEUR"); L(sep('─')); L()

    niveaux_ordre = {"CRITIQUE":0,"ÉLEVÉ":1,"MOYEN":2,"FAIBLE":3}
    acteurs_tries = sorted(
        decisions.items(),
        key=lambda x: (niveaux_ordre.get(x[1]['decision'],4),
                       -x[1]['score'])
    )

    for s, d in acteurs_tries:
        r    = resultats_nn.get(s, {})
        prolog_alerts = alertes_prolog.get(s, [])
        niv  = d['decision']
        icone = {"CRITIQUE":"⚠","ÉLEVÉ":"▲","MOYEN":"►","FAIBLE":"✓"}.get(niv,"?")

        L(f"\n  {icone} [{niv}] {r.get('nom', s)}")
        L(f"     Ville/Quartier : {r.get('ville','?')} / {r.get('quartier','?')}")
        L(f"     Label réel     : {r.get('label_gt','?').upper()}")
        L(f"     Score fusion   : {d['score']} pts")
        L()

        # Couche neuronale
        L(f"     ▸ NEURAL  → {r.get('classe_nn','?').upper()} "
          f"(confiance={r.get('confiance',0):.1%})")
        L(f"       Dist. : std={r.get('prob_std',0):.3f} | "
          f"aty={r.get('prob_aty',0):.3f} | "
          f"spe={r.get('prob_spe',0):.3f} | "
          f"fra={r.get('prob_fra',0):.3f}")

        # Couche Prolog
        if prolog_alerts:
            L(f"     ▸ PROLOG → {len(prolog_alerts)} règle(s) déclenchée(s)")
            for code, motif in prolog_alerts[:4]:
                L(f"       [{code}] {motif}")
        else:
            L(f"     ▸ PROLOG → aucune règle déclenchée")

        # Décision finale
        L(f"     ▸ DÉCISION FINALE → {niv}")
        if niv in ("CRITIQUE","ÉLEVÉ"):
            L(f"       → Procédure d'instruction approfondie recommandée")
        elif niv == "MOYEN":
            L(f"       → Surveillance renforcée recommandée")
        else:
            L(f"       → Profil dans les normes réglementaires")

    # ── Résultats ProbLog ────────────────────────────────────────
    L(); L(sep('─')); L("INFÉRENCE PROBABILISTE (ProbLog)"); L(sep('─')); L()
    for label, info in resultats_prob.items():
        p   = info['probabilite']
        niv = info['niveau']
        icone = {"CRITIQUE":"⚠","ÉLEVÉ":"▲","MOYEN":"►","FAIBLE":"✓",
                 "ERREUR":"✗"}.get(niv,"?")
        bar = barre(p) if p >= 0 else "[ERREUR]"
        L(f"  {icone} {label:<45} {bar}  [{niv}]")

    # ── Statistiques finales ────────────────────────────────────
    L(); L(sep('─')); L("STATISTIQUES FINALES"); L(sep('─')); L()
    total = len(rows)
    nn_acc = sum(1 for v in resultats_nn.values() if v.get('correct_nn')) / total * 100
    L(f"  Total dossiers analysés  : {total}")
    L(f"  Accuracy réseau neuronal : {nn_acc:.1f}%")
    L(f"  Alertes CRITIQUE         : {dist.get('CRITIQUE',0)}")
    L(f"  Alertes ÉLEVÉ            : {dist.get('ÉLEVÉ',0)}")
    L(f"  Alertes MOYEN            : {dist.get('MOYEN',0)}")
    L(f"  Profils FAIBLE           : {dist.get('FAIBLE',0)}")
    total_prolog = sum(len(v) for v in alertes_prolog.values())
    L(f"  Total alertes Prolog     : {total_prolog}")
    L(f"  Requêtes ProbLog         : {len(resultats_prob)}")
    L(); L(sep()); L()

    # ── Écriture fichiers ────────────────────────────────────────
    rapport_txt = "\n".join(lignes)
    with open(RAPPORT_PATH, 'w', encoding='utf-8') as f:
        f.write(rapport_txt)

    # Export CSV
    with open(RAPPORT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'acteur','nom','ville','label_gt','classe_nn',
            'confiance_nn','nb_alertes_prolog','score_fusion','decision_finale'
        ])
        writer.writeheader()
        for s, d in decisions.items():
            r = resultats_nn.get(s, {})
            writer.writerow({
                'acteur':            s,
                'nom':               r.get('nom', s),
                'ville':             r.get('ville',''),
                'label_gt':          r.get('label_gt',''),
                'classe_nn':         d['classe_nn'],
                'confiance_nn':      resultats_nn.get(s,{}).get('confiance',0),
                'nb_alertes_prolog': d['nb_alertes_prolog'],
                'score_fusion':      d['score'],
                'decision_finale':   d['decision'],
            })

    print(f"  ✅ Rapport TXT : {RAPPORT_PATH.name}")
    print(f"  ✅ Rapport CSV : {RAPPORT_CSV.name}")
    return rapport_txt


# ════════════════════════════════════════════════════════════════
# POINT D'ENTRÉE PRINCIPAL
# ════════════════════════════════════════════════════════════════

def main():
    t0 = time.time()
    print()
    print(sep())
    print("  LANDGUARD NEURO-SYMBOLIC AI — Pipeline Principal")
    print(f"  Burkina Faso | {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
    print(sep())

    # ── Étape 1 : Dataset ───────────────────────────────────────
    rows, index = etape1_charger_dataset()

    # ── Étape 2 : Neurones ──────────────────────────────────────
    resultats_nn = etape2_inference_neuronale(rows, index)

    # ── Étape 3 : ProbLog ───────────────────────────────────────
    resultats_prob = etape3_inference_problog()

    # ── Étape 4 : Prolog ────────────────────────────────────────
    alertes_prolog = etape4_regles_prolog(rows)

    # ── Étape 5 : Fusion NS ─────────────────────────────────────
    decisions = etape5_fusion_ns(resultats_nn, alertes_prolog)

    # ── Étape 6 : Rapport ───────────────────────────────────────
    rapport = etape6_rapport(
        rows, resultats_nn, resultats_prob, alertes_prolog, decisions
    )

    # ── Résumé final ────────────────────────────────────────────
    duree = time.time() - t0
    print()
    print(sep())
    print(f"  ✅ Pipeline terminé en {duree:.1f}s")
    dist = Counter(v['decision'] for v in decisions.values())
    print(f"  ⚠  CRITIQUE  : {dist.get('CRITIQUE',0)} dossier(s)")
    print(f"  ▲  ÉLEVÉ     : {dist.get('ÉLEVÉ',0)} dossier(s)")
    print(f"  ►  MOYEN     : {dist.get('MOYEN',0)} dossier(s)")
    print(f"  ✓  FAIBLE    : {dist.get('FAIBLE',0)} dossier(s)")
    print(sep())

    return decisions


if __name__ == "__main__":
    main()
