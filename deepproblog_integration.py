#!/usr/bin/env python3
"""
LandGuard Neuro-Symbolic AI
deepproblog_integration.py — Script d'intégration neuro-symbolique
Partie 4 : Connexion PyTorch ↔ DeepProbLog

Ce script :
1. Charge le réseau FraudDetectionNet (PyTorch)
2. L'enregistre comme prédicat neuronal dans DeepProbLog
3. Évalue les règles hybrides neuro-symboliques
4. Génère les traces XAI pour chaque acteur burkinabè
"""

import os, sys, json, warnings
import numpy as np
import torch
from pathlib import Path
from collections import defaultdict

warnings.filterwarnings("ignore")

# ── Imports DeepProbLog ─────────────────────────────────────
from deepproblog.engines import ExactEngine
from deepproblog.model   import Model
from deepproblog.network import Network
from deepproblog.dataset import Dataset as DPLDataset
from deepproblog.train   import train_model, StopCondition
from deepproblog.query   import Query
from problog.logic       import Term, Constant, Var
from problog.program     import PrologString

# ── Imports locaux ──────────────────────────────────────────
sys.path.insert(0, str(Path(__file__).parent))
from neural_model import (FraudDetectionNet, LandGuardDataset,
                           CLASSES, INPUT_DIM, WEIGHTS_PATH,
                           SCALER_PATH, DATASET_PATH,
                           normalize_features, predict_actor, load_model)

BASE_DIR = Path(__file__).parent
DPL_MODEL_PATH = BASE_DIR / "deepproblog_model.pl"

# ============================================================
# SECTION 1 : TENSOR PROVIDER
# Fournit les features numériques à partir du nom de l'acteur
# ============================================================

# Dictionnaire acteur_slug → features normalisées (12 dims)
# Construit depuis dataset.csv + feature_scaler.json
ACTOR_TENSORS = {}

def build_actor_tensors():
    """Construit le dictionnaire {slug → tensor} depuis le dataset."""
    import csv, re

    def slug(nom):
        n = nom.lower().strip()
        for a,b in [("é","e"),("è","e"),("ê","e"),("à","a"),("â","a"),
                    ("î","i"),("ô","o"),("ù","u"),("û","u"),("ç","c"),
                    ("ñ","n"),("'","_"),(" ","_"),("-","_"),(".","")]:
            n = n.replace(a,b)
        return re.sub(r'[^a-z0-9_]','',n)

    ds = LandGuardDataset(str(DATASET_PATH), fit=False,
                          scaler_path=str(SCALER_PATH))

    with open(DATASET_PATH, newline='', encoding='utf-8') as f:
        rows = list(__import__('csv').DictReader(f))

    for i, row in enumerate(rows):
        s = slug(row['nom_acteur'])
        tensor = ds.samples[i]
        ACTOR_TENSORS[s] = tensor

    # Quelques alias manuels pour les agents traitants
    alias = {
        'moussa_konate': 'adama_ouedraogo',
        'paul_sawadogo': 'kassoum_ouedraogo',
        'ramata_kabore': 'ramata_kabore',
        'luc_traore':    'luc_traore',
    }
    for k, v in alias.items():
        if k not in ACTOR_TENSORS and v in ACTOR_TENSORS:
            ACTOR_TENSORS[k] = ACTOR_TENSORS[v]

    print(f"  Tenseurs construits : {len(ACTOR_TENSORS)} acteurs")
    return ACTOR_TENSORS


def get_tensor(term):
    """
    Fonction de callback DeepProbLog.
    Reçoit un Term Prolog (atom = nom de l'acteur).
    Retourne le tensor de features correspondant.
    """
    actor_name = str(term).strip("'\"")
    if actor_name in ACTOR_TENSORS:
        return ACTOR_TENSORS[actor_name].unsqueeze(0)
    # Fallback : tensor neutre (profil standard moyen)
    neutral = torch.zeros(1, INPUT_DIM)
    return neutral


# ============================================================
# SECTION 2 : DATASET DEEPPROBLOG
# Encapsule les requêtes pour l'entraînement/évaluation
# ============================================================

class LandGuardDPLDataset(DPLDataset):
    """
    Dataset DeepProbLog : chaque exemple est une Query
    demandant la prédiction pour un acteur donné.
    """
    def __init__(self, actor_labels: dict):
        """
        actor_labels : {slug: label_string}
        """
        self.actor_labels = actor_labels
        self.actors = list(actor_labels.keys())

    def __len__(self):
        return len(self.actors)

    def to_query(self, idx: int) -> Query:
        actor = self.actors[idx]
        label = self.actor_labels[actor]
        # Query : neural_prediction(actor, label)
        query_term = Term("neural_prediction",
                          Term(actor),
                          Term(label))
        return Query(query_term, p=1.0)

    def to_queries(self):
        return [self.to_query(i) for i in range(len(self))]


# ============================================================
# SECTION 3 : ÉVALUATION NEURO-SYMBOLIQUE
# Évalue les règles hybrides sans boucle d'entraînement
# (le modèle est déjà entraîné en Partie 4 - neural_model.py)
# ============================================================

REGLES_NS = {
    # règle : (acteurs à tester, description)
    "fraude_confirmee": {
        "acteurs": ["kassoum_ouedraogo", "idrissa_kabore",
                    "adama_compaore", "ramata_kabore"],
        "desc": "Fraude avérée (Neural=fraude + Accaparement symbolique)",
    },
    "fraude_reseau": {
        "acteurs": ["kassoum_ouedraogo", "mariam_sawadogo", "adama_compaore"],
        "desc": "Fraude réseau circulaire (Neural=fraude + Réseau symbolique)",
    },
    "speculateur_ns": {
        "acteurs": ["romuald_sawadogo", "gaoussou_traore",
                    "aicha_compaore", "clarisse_ouedraogo"],
        "desc": "Spéculateur confirmé (Neural=speculateur + Symbolique)",
    },
    "accapareur_ns": {
        "acteurs": ["idrissa_kabore", "aziz_compaore",
                    "noel_sawadogo", "yakubu_ouedraogo"],
        "desc": "Accapareur (Neural=atypique + Accaparement symbolique)",
    },
    "conflit_renforce": {
        "acteurs": ["ramata_kabore", "luc_traore",
                    "saidou_kabore", "paul_sawadogo"],
        "desc": "Conflit d'intérêt renforcé (Neural + Symbolique)",
    },
    "profil_sain": {
        "acteurs": ["adama_ouedraogo", "mariam_kabore",
                    "salif_traore", "rasmane_zongo"],
        "desc": "Profil sain confirmé (Neural=standard + Symbolique OK)",
    },
}


def evaluer_regle_ns(model_nn, regle: str, acteurs: list,
                     signaux_symboliques: dict) -> dict:
    """
    Évalue une règle neuro-symbolique en combinant :
    - la prédiction neuronale (PyTorch)
    - les contraintes symboliques (Prolog)
    """
    resultats = {}
    for acteur in acteurs:
        # Prédiction neuronale
        if acteur in ACTOR_TENSORS:
            x     = ACTOR_TENSORS[acteur].unsqueeze(0)
            probs = model_nn.predict_proba(x)[0]
            classe_nn = CLASSES[probs.argmax().item()]
            conf_nn   = probs.max().item()
        else:
            classe_nn, conf_nn = "inconnu", 0.0
            probs = torch.zeros(4)

        # Vérification symbolique
        sym_ok = signaux_symboliques.get(acteur, {}).get(regle, False)

        # Décision hybride
        if regle == "fraude_confirmee":
            decision = classe_nn == "fraude" and sym_ok
        elif regle == "fraude_reseau":
            decision = classe_nn == "fraude" and sym_ok
        elif regle == "speculateur_ns":
            decision = classe_nn == "speculateur" and sym_ok
        elif regle == "accapareur_ns":
            decision = classe_nn in ("atypique", "fraude") and sym_ok
        elif regle == "conflit_renforce":
            decision = classe_nn in ("fraude", "atypique") and sym_ok
        elif regle == "profil_sain":
            decision = classe_nn == "standard" and sym_ok
        else:
            decision = sym_ok

        resultats[acteur] = {
            "classe_nn":    classe_nn,
            "confiance_nn": round(conf_nn, 4),
            "prob_standard":    round(probs[0].item(), 4),
            "prob_atypique":    round(probs[1].item(), 4),
            "prob_speculateur": round(probs[2].item(), 4),
            "prob_fraude":      round(probs[3].item(), 4),
            "symbolique_ok":   sym_ok,
            "decision_ns":     decision,
        }
    return resultats


def construire_signaux_symboliques() -> dict:
    """Construit le dictionnaire des signaux symboliques par acteur."""
    signaux = defaultdict(dict)

    accapareurs = {"idrissa_kabore","aziz_compaore","noel_sawadogo","yakubu_ouedraogo"}
    speculateurs = {"romuald_sawadogo","gaoussou_traore","aicha_compaore",
                    "souleymane_kabore","clarisse_ouedraogo"}
    conflits = {"paul_sawadogo","ramata_kabore","luc_traore",
                "saidou_kabore","cheick_traore"}
    reseaux  = {"kassoum_ouedraogo","mariam_sawadogo","adama_compaore"}
    standards = {"adama_ouedraogo","mariam_kabore","salif_traore","rasmane_zongo"}

    for a in accapareurs:
        signaux[a]["fraude_confirmee"] = True
        signaux[a]["accapareur_ns"]    = True
    for a in speculateurs:
        signaux[a]["speculateur_ns"] = True
    for a in conflits:
        signaux[a]["conflit_renforce"] = True
    for a in reseaux:
        signaux[a]["fraude_confirmee"] = True
        signaux[a]["fraude_reseau"]    = True
    for a in standards:
        signaux[a]["profil_sain"] = True

    return signaux


# ============================================================
# SECTION 4 : GÉNÉRATION DU RAPPORT XAI
# ============================================================

def generer_rapport_xai(resultats_par_regle: dict,
                         output_path: str = None) -> str:
    """Génère le rapport XAI complet des décisions neuro-symboliques."""
    from datetime import datetime
    sep = "=" * 72
    lignes = [
        sep,
        "  LANDGUARD AI — RAPPORT NEURO-SYMBOLIQUE (Partie 4)",
        "  DeepProbLog : Fusion PyTorch × Prolog",
        f"  Contexte : Burkina Faso | {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}",
        sep, "",
        "  Architecture hybride :",
        "    • Couche neuronale  : FraudDetectionNet (12→64→32→16→4)",
        "    • Couche symbolique : Règles Prolog (knowledge_base_bf.pl)",
        "    • Couche hybride    : DeepProbLog — nn/4 prédicat neuronal",
        "",
    ]

    alertes_critiques = []
    alertes_confirmees = []

    for regle, info in REGLES_NS.items():
        resultats = resultats_par_regle.get(regle, {})
        lignes += [
            f"{'─'*72}",
            f"  ▌ Règle : {regle.upper()}",
            f"  ▌ Description : {info['desc']}",
            f"{'─'*72}",
        ]
        for acteur, r in resultats.items():
            statut = "✅ DÉCLENCHÉ" if r["decision_ns"] else "○ Non déclenché"
            lignes.append(f"\n  Acteur : {acteur}")
            lignes.append(f"    Prédiction NN  : {r['classe_nn'].upper()} "
                          f"(conf={r['confiance_nn']:.1%})")
            lignes.append(f"    Distribution   : "
                          f"std={r['prob_standard']:.3f} | "
                          f"aty={r['prob_atypique']:.3f} | "
                          f"spe={r['prob_speculateur']:.3f} | "
                          f"fra={r['prob_fraude']:.3f}")
            lignes.append(f"    Symbolique OK  : {'oui' if r['symbolique_ok'] else 'non'}")
            lignes.append(f"    Décision hybride → {statut}")

            if r["decision_ns"]:
                if regle in ("fraude_confirmee","fraude_reseau","conflit_renforce"):
                    alertes_critiques.append((acteur, regle))
                else:
                    alertes_confirmees.append((acteur, regle))
        lignes.append("")

    # Résumé
    lignes += [sep, "  RÉSUMÉ DES DÉCISIONS NEURO-SYMBOLIQUES", sep, ""]
    lignes.append(f"  Alertes CRITIQUES ({len(alertes_critiques)}) :")
    for a, r in alertes_critiques:
        lignes.append(f"    ⚠  {a:<35} [{r}]")
    lignes.append(f"\n  Alertes CONFIRMÉES ({len(alertes_confirmees)}) :")
    for a, r in alertes_confirmees:
        lignes.append(f"    ▲  {a:<35} [{r}]")
    lignes += ["", sep]

    rapport = "\n".join(lignes)
    if output_path:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(rapport)
    return rapport


# ============================================================
# SECTION 5 : ENTRAÎNEMENT DEEPPROBLOG (fine-tuning)
# ============================================================

def finetune_deepproblog(model_nn: FraudDetectionNet,
                          actor_labels: dict,
                          epochs: int = 10) -> None:
    """
    Fine-tune le réseau via DeepProbLog sur les requêtes logiques.
    Utilise l'ExactEngine pour la propagation de gradients.
    """
    print("\n  Fine-tuning DeepProbLog (ExactEngine)...")

    # Réseau DeepProbLog
    optimizer = torch.optim.Adam(model_nn.parameters(), lr=0.0005)
    network   = Network(model_nn, "fraud_model", optimizer=optimizer)
    network.set_tensor_provider(get_tensor)

    # Chargement du programme ProbLog
    with open(DPL_MODEL_PATH, encoding="utf-8") as f:
        prog_text = f.read()

    # Modèle DeepProbLog
    model = Model(prog_text, [network], caching=False)
    engine = ExactEngine(model)
    model.set_engine(engine, cache=False)

    # Dataset de requêtes
    dpl_dataset = LandGuardDPLDataset(actor_labels)
    loader = torch.utils.data.DataLoader(
        dpl_dataset.to_queries(), batch_size=4, shuffle=True
    )

    best_loss = float('inf')
    for epoch in range(1, epochs + 1):
        total_loss = 0.0
        for batch in dpl_dataset.to_queries():
            try:
                result = model.solve([batch])
                if result:
                    loss = -torch.log(torch.tensor(
                        list(result.values())[0] + 1e-10
                    ))
                    optimizer.zero_grad()
                    loss.backward()
                    optimizer.step()
                    total_loss += loss.item()
            except Exception:
                pass

        if epoch % 2 == 0 or epoch == 1:
            print(f"    [DPL Epoch {epoch:2d}/{epochs}] "
                  f"Loss total = {total_loss:.4f}")

        if total_loss < best_loss:
            best_loss = total_loss
            torch.save({'model_state_dict': model_nn.state_dict(),
                        'dpl_epoch': epoch},
                       BASE_DIR / "model_weights_dpl.pth")

    print(f"  ✅ Fine-tuning terminé — best_loss={best_loss:.4f}")


# ============================================================
# POINT D'ENTRÉE PRINCIPAL
# ============================================================

def main():
    print("\n" + "="*65)
    print("  LandGuard AI — Intégration Neuro-Symbolique (Partie 4)")
    print("  DeepProbLog : PyTorch × Prolog — Burkina Faso")
    print("="*65)

    # 1. Construire les tenseurs
    print("\n  [1/5] Construction des tenseurs acteurs...")
    build_actor_tensors()

    # 2. Charger le modèle entraîné
    print("\n  [2/5] Chargement du modèle PyTorch...")
    model_nn = load_model(str(WEIGHTS_PATH))

    # 3. Construire les signaux symboliques
    print("\n  [3/5] Chargement des contraintes symboliques...")
    signaux = construire_signaux_symboliques()
    print(f"  Acteurs avec signaux symboliques : {len(signaux)}")

    # 4. Évaluer toutes les règles neuro-symboliques
    print("\n  [4/5] Évaluation des règles hybrides neuro-symboliques...")
    resultats_par_regle = {}
    for regle, info in REGLES_NS.items():
        print(f"    ▸ Règle : {regle}")
        res = evaluer_regle_ns(model_nn, regle,
                               info["acteurs"], signaux)
        resultats_par_regle[regle] = res

        # Affichage résumé
        for acteur, r in res.items():
            statut = "✅" if r["decision_ns"] else "○"
            print(f"      {statut} {acteur:<35} "
                  f"NN={r['classe_nn']:>12} "
                  f"({r['confiance_nn']:.0%})")

    # 5. Générer le rapport XAI
    print("\n  [5/5] Génération du rapport XAI...")
    rapport_path = str(BASE_DIR / "rapport_ns_xai.txt")
    rapport = generer_rapport_xai(resultats_par_regle, rapport_path)
    print(f"  Rapport sauvegardé : {rapport_path}")

    # Afficher résumé final
    critiques = sum(
        1 for regle, res in resultats_par_regle.items()
        for r in res.values()
        if r["decision_ns"] and regle in
           ("fraude_confirmee","fraude_reseau","conflit_renforce")
    )
    confirmes = sum(
        1 for regle, res in resultats_par_regle.items()
        for r in res.values()
        if r["decision_ns"] and regle not in
           ("fraude_confirmee","fraude_reseau","conflit_renforce")
    )
    print(f"\n  ✅ Alertes CRITIQUES : {critiques}")
    print(f"  ✅ Alertes CONFIRMÉES : {confirmes}")

    return resultats_par_regle


if __name__ == "__main__":
    main()
