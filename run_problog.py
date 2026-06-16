#!/usr/bin/env python3
"""
LandGuard Neuro-Symbolic AI
run_problog.py — Exécution des requêtes probabilistes (Partie 3)
Contexte : Burkina Faso — 50 dossiers fonciers
"""

import os, sys, warnings
from datetime import datetime
from pathlib import Path

warnings.filterwarnings("ignore")

BASE_DIR     = Path(__file__).parent
RULES_PATH   = BASE_DIR / "probabilistic_rules.pl"
RAPPORT_PATH = BASE_DIR / "rapport_inference_prob.txt"

try:
    from problog.program import PrologString
    from problog import get_evaluatable
    PROBLOG_OK = True
except ImportError:
    PROBLOG_OK = False
    print("[ERREUR] ProbLog non installé — pip install problog")
    sys.exit(1)

# ── Seuils de criticité ────────────────────────────────────
SEUILS = {"CRITIQUE": 0.80, "ÉLEVÉ": 0.60, "MOYEN": 0.30, "FAIBLE": 0.0}

def niveau(p):
    if p < 0:      return "ERREUR  "
    if p >= 0.80:  return "CRITIQUE ⚠"
    if p >= 0.60:  return "ÉLEVÉ    ▲"
    if p >= 0.30:  return "MOYEN    ►"
    return               "FAIBLE   ✓"

def barre(p, w=30):
    if p < 0: return "[ERREUR]"
    r = int(p * w)
    return f"[{'█'*r}{'░'*(w-r)}] {p:.2%}"

def eval_q(prog, atom):
    full = prog + f"\nquery({atom}).\n"
    try:
        res = get_evaluatable().create_from(PrologString(full)).evaluate()
        for v in res.values(): return float(v)
        return 0.0
    except Exception as e:
        return -1.0

# ── Requêtes organisées par catégorie ─────────────────────
QUERIES = {
    "Prête-Nom & Accaparement (Ouagadougou)": [
        ("prete_nom(idrissa_kabore,aziz_compaore)",
         "Q01 — Prête-nom tél. : Idrissa Kaboré / Aziz Compaoré"),
        ("prete_nom_familial(idrissa_kabore,aziz_compaore)",
         "Q02 — Prête-nom familial : Idrissa / Aziz"),
        ("prete_nom(kassoum_ouedraogo,mariam_sawadogo)",
         "Q03 — Prête-nom : Kassoum / Mariam Sawadogo"),
        ("accapareur_urbain(idrissa_kabore)",
         "Q04 — Accaparement urbain : Idrissa Kaboré (Secteur 30)"),
        ("reseau_familial(idrissa_kabore,aziz_compaore,noel_sawadogo)",
         "Q05 — Réseau familial : Idrissa / Aziz / Noël"),
    ],
    "Spéculation Foncière": [
        ("revente_rapide(romuald_sawadogo)",
         "Q06 — Revente rapide : Romuald Sawadogo (30j, Pissy)"),
        ("plus_value_anormale(gaoussou_traore)",
         "Q07 — Plus-value anormale : Gaoussou Traoré (+133%, Bobo)"),
        ("speculateur(romuald_sawadogo)",
         "Q08 — Spéculateur confirmé : Romuald Sawadogo"),
    ],
    "Conflits d'Intérêts": [
        ("conflit_familial(paul_sawadogo,kassoum_ouedraogo)",
         "Q09 — Conflit familial : Paul Sawadogo → Kassoum"),
        ("conflit_familial(paul_sawadogo,mariam_sawadogo)",
         "Q10 — Conflit familial : Paul Sawadogo → Mariam"),
        ("auto_attribution(ramata_kabore)",
         "Q11 — Auto-attribution : Ramata Kaboré (agent, Zone du Bois)"),
        ("auto_attribution(luc_traore)",
         "Q12 — Auto-attribution : Luc Traoré (notaire, Koulouba)"),
        ("notaire_conflit(saidou_kabore)",
         "Q13 — Conflit notaire : Saidou Kaboré"),
    ],
    "Réseaux & Blanchiment": [
        ("reseau_circulaire(kassoum_ouedraogo,ramata_kabore,adama_compaore)",
         "Q14 — Réseau circulaire : Kassoum→Ramata→Adama→Kassoum"),
        ("reseau_financier_etendu(kassoum_ouedraogo,ramata_kabore,adama_compaore)",
         "Q15 — Réseau IBAN étendu : Kassoum / Ramata / Adama"),
        ("promoteur_fantome(marcelline_traore)",
         "Q16 — Promoteur fantôme : Marcelline Traoré (Koulouba)"),
    ],
    "Fraudes Composites & Sophistiquées": [
        ("fraude_composite(kassoum_ouedraogo)",
         "Q17 — Fraude composite : Kassoum Ouédraogo (Cissin)"),
        ("fraude_sophistiquee(kassoum_ouedraogo)",
         "Q18 — Fraude sophistiquée : Kassoum Ouédraogo"),
    ],
    "Suspicion Globale Multi-Signaux": [
        ("suspicion_globale(idrissa_kabore)",
         "Q19 — Suspicion globale : Idrissa Kaboré"),
        ("suspicion_globale(kassoum_ouedraogo)",
         "Q20 — Suspicion globale : Kassoum Ouédraogo"),
        ("suspicion_globale(ramata_kabore)",
         "Q21 — Suspicion globale : Ramata Kaboré"),
        ("suspicion_globale(romuald_sawadogo)",
         "Q22 — Suspicion globale : Romuald Sawadogo"),
        ("suspicion_globale(adama_ouedraogo)",
         "Q23 — Suspicion globale : Adama Ouédraogo (cas sain ✓)"),
    ],
}

def main():
    sep = "=" * 72

    print(f"\n{sep}")
    print("  LandGuard AI — Inférence Probabiliste (ProbLog)")
    print(f"  Burkina Faso | {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
    print(f"{sep}\n")

    if not RULES_PATH.exists():
        print(f"[ERREUR] Fichier introuvable : {RULES_PATH}")
        sys.exit(1)

    prog = RULES_PATH.read_text(encoding='utf-8')
    print(f"  Programme chargé : {RULES_PATH.name}")
    total_q = sum(len(v) for v in QUERIES.values())
    print(f"  Requêtes totales : {total_q}\n")

    resultats = {}
    crits, elevs, moys, faib = [], [], [], []

    for cat, qs in QUERIES.items():
        print(f"  ▌ {cat}")
        resultats[cat] = []
        for atom, label in qs:
            p   = eval_q(prog, atom)
            niv = niveau(p)
            print(f"    {label:<55} P={p:.4f}  [{niv}]")
            resultats[cat].append((label, p))
            if   p >= 0.80: crits.append((label, p))
            elif p >= 0.60: elevs.append((label, p))
            elif p >= 0.30: moys.append((label, p))
            elif p >= 0:    faib.append((label, p))
        print()

    # ── Génération du rapport ──────────────────────────────
    lignes = [sep,
        "  LANDGUARD NEURO-SYMBOLIC AI — RAPPORT D'INFÉRENCE PROBABILISTE",
        f"  Partie 3 : ProbLog | Burkina Faso | {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}",
        sep, "",
        "  Échelle de criticité :",
        "    FAIBLE   (✓) : P < 0.30  — Aucune action immédiate",
        "    MOYEN    (►) : P ∈ [0.30, 0.60) — Surveillance renforcée",
        "    ÉLEVÉ    (▲) : P ∈ [0.60, 0.80) — Instruction approfondie",
        "    CRITIQUE (⚠) : P ≥ 0.80  — Procédure d'enquête obligatoire", ""]

    for cat, qs in resultats.items():
        lignes += [f"{'─'*72}", f"  ▌ {cat}", f"{'─'*72}"]
        for label, p in qs:
            niv = niveau(p)
            lignes += [f"  {label:<55}  {niv}", f"    {barre(p)}", ""]

    lignes += [sep, "  RÉSUMÉ GLOBAL DES ALERTES", sep, ""]
    for titre, lst in [("CRITIQUE ⚠", crits), ("ÉLEVÉ    ▲", elevs),
                        ("MOYEN    ►", moys),  ("FAIBLE   ✓", faib)]:
        lignes.append(f"  {titre} ({len(lst)} alerte(s)) :")
        for lb, p in sorted(lst, key=lambda x: -x[1]):
            lignes.append(f"    • {lb:<55} P={p:.4f}")
        if not lst: lignes.append("    (aucune)")
        lignes.append("")

    lignes += [sep,
        f"  Total requêtes évaluées : {total_q}/{total_q}",
        f"  Alertes CRITIQUE : {len(crits)}",
        f"  Alertes ÉLEVÉES  : {len(elevs)}",
        f"  Alertes MOYENNES : {len(moys)}",
        f"  Alertes FAIBLES  : {len(faib)}", sep]

    rapport = "\n".join(lignes)
    RAPPORT_PATH.write_text(rapport, encoding='utf-8')

    print(f"\n{sep}")
    print(f"  ✅ Rapport sauvegardé : {RAPPORT_PATH.name}")
    print(f"  CRITIQUE:{len(crits)} | ÉLEVÉ:{len(elevs)} | MOYEN:{len(moys)} | FAIBLE:{len(faib)}")
    print(f"{sep}\n")

if __name__ == "__main__":
    main()
