# LandGuard Neuro-Symbolic AI 

> **Régulation foncière intelligente par Logique de Description, Prolog, ProbLog et DeepProbLog**
---

##  Description du projet

LandGuard Neuro-Symbolic AI est un système hybride de détection de fraude foncière combinant :

- **Logique de Description** — modélisation formelle du domaine (TBox/ABox)
- **SWI-Prolog** — moteur de raisonnement déductif (16 règles juridiques)
- **ProbLog** — raisonnement probabiliste sous incertitude (23 requêtes)
- **PyTorch** — réseau neuronal de classification (FraudDetectionNet 12→64→32→16→4)
- **DeepProbLog** — fusion neuro-symbolique avec explicabilité (XAI)

Le pipeline analyse **50 dossiers fonciers burkinabè** et produit des décisions
entièrement explicables sur 4 niveaux : FAIBLE / MOYEN / ÉLEVÉ / CRITIQUE.

---

##  Structure du projet

```
landguard/
│
├──  knowledge_base.pl          # Base de faits (50 dossiers, contexte Burkina Faso)
├──  rules.pl                   # 16 règles Prolog (catégories A/B/C/D)
├──  inference_engine.pl        # Moteur d'inférence + scoring de risque
├──  explainability.pl          # Module XAI — traces et justifications
│
├──  probabilistic_rules.pl     # Clauses probabilistes ProbLog
├──  queries.pl                 # 23 requêtes d'inférence probabiliste
├──  run_problog.py             # Exécution des requêtes ProbLog (Python)
│
├──  neural_model.py            # FraudDetectionNet (PyTorch) + entraînement
├──  deepproblog_model.pl       # Prédicat neuronal nn/4 + règles hybrides NS
├──  deepproblog_integration.py # Intégration PyTorch ↔ DeepProbLog
│
├──  main.py                    # Pipeline d'orchestration complet (6 étapes)
│
├──  dataset.csv                # 50 dossiers fonciers burkinabè (ground truth)
├──  test_suite.py              # Suite de tests (26 tests : Prolog/ProbLog/E2E)
│
├──  model_weights.pth          # Poids du meilleur checkpoint (epoch 79, acc=98%)
├── feature_scaler.json        # Paramètres de normalisation des features
│
├──  description_logic.md       # Axiomes DL formalisés (10 axiomes, 8 CI)
├──  diagramme_concepts.pdf     # Diagramme TBox DL 
│
└──  rapport_landguard.pdf      # Rapport 

---

##  Installation

### Prérequis

| Outil | Version minimale |
|-------|-----------------|
| Python | 3.10+ |
| SWI-Prolog | 9.0+ |
| PyTorch | 2.0+ |
| ProbLog | 2.0+ |
| DeepProbLog | 2.0+ |

### 1. Cloner le dépôt

```bash
git clone https://github.com/<votre-username>/landguard-neuro-symbolic.git
cd landguard-neuro-symbolic
```

### 2. Créer l'environnement Python

```bash
python3 -m venv venv
source venv/bin/activate        # Linux/macOS
# venv\Scripts\activate         # Windows
```

### 3. Installer les dépendances Python

```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
pip install problog deepproblog numpy pandas scikit-learn pypdf reportlab
```

### 4. Installer SWI-Prolog

```bash
# Ubuntu / Debian
sudo apt-get install swi-prolog

# macOS
brew install swi-prolog

# Windows : télécharger depuis https://www.swi-prolog.org/download/stable
```

---

##  Exécution rapide

### Pipeline complet (recommandé)

```bash
python3 main.py
```

Produit en ~4 secondes :
- `rapport_final_landguard.txt` — rapport détaillé avec traces XAI
- `rapport_final_landguard.csv` — tableau de bord exportable

### Entraîner le réseau neuronal seul

```bash
python3 neural_model.py
```

### Exécuter les requêtes ProbLog

```bash
python3 run_problog.py
```

### Lancer la suite de tests (26 tests)

```bash
python3 test_suite.py
```

### Charger la base de connaissances en SWI-Prolog

```prolog
?- [knowledge_base], [rules], [inference_engine], [explainability].
?- analyser_tous_les_acteurs.
?- rapport_risques.
```

---

##  Live Demo — Scénario de fraude inconnu

Pour la démonstration face à l'examinateur, le système accepte un nouveau
dossier injecté à la volée. Exemple d'injection :

**Étape 1 — Ajouter le dossier suspect dans `knowledge_base.pl` :**

```prolog
citoyen(nouveau_suspect).
possede(nouveau_suspect, p_urb_999).
possede(nouveau_suspect, p_urb_998).
possede(nouveau_suspect, p_urb_997).
possede(nouveau_suspect, p_urb_996).     % 4 parcelles urbaines → AX-01
parcelle_urbaine(p_urb_996). parcelle_urbaine(p_urb_997).
parcelle_urbaine(p_urb_998). parcelle_urbaine(p_urb_999).
partage_telephone(nouveau_suspect, kassoum_ouedraogo).  % CI-5
partage_telephone(kassoum_ouedraogo, nouveau_suspect).
lien_familial(nouveau_suspect, paul_sawadogo).          % lien agent
lien_familial(paul_sawadogo, nouveau_suspect).
traite(paul_sawadogo, dossier_nouveau).
beneficiaire(nouveau_suspect, dossier_nouveau).
```

**Étape 2 — Analyser en SWI-Prolog :**

```prolog
?- [knowledge_base], [rules], [inference_engine], [explainability].
?- analyser_acteur(nouveau_suspect).
?- score_risque(nouveau_suspect, S), niveau_risque(nouveau_suspect, N).
?- expliquer(nouveau_suspect).
```

**Étape 3 — Inférence probabiliste :**

```python
# Dans run_problog.py, ajouter :
("prete_nom(nouveau_suspect, kassoum_ouedraogo)",
 "Prête-nom : nouveau_suspect / Kassoum"),
("suspicion_globale(nouveau_suspect)",
 "Suspicion globale : nouveau_suspect"),
```

**Étape 4 — Pipeline neuronal :**

```python
from neural_model import load_model, normalize_features, predict_actor
import json

model = load_model("model_weights.pth")
scaler = "feature_scaler.json"

# Features du nouveau suspect :
# [nb_urb, nb_rur, nb_tot, freq_rev, ratio_pv, delai/365,
#  nb_liens, tel, adr, iban, fam_ag, age/100]
features_brutes = [4, 0, 4, 0.0, 0.0, 2.0, 3, 1, 1, 0, 1, 0.38]
features_norm   = normalize_features(features_brutes, scaler)

result = predict_actor(features_norm, model)
print(result)
# → {'classe': 'fraude', 'confiance': 0.94, ...}
```

---

##  Résultats obtenus

| Métrique | Valeur |
|----------|--------|
| Accuracy réseau neuronal | **98%** (epoch 79) |
| Tests automatisés | **26/26**  |
| Alertes CRITIQUE (pipeline) | **14 / 50** dossiers |
| Requêtes ProbLog CRITIQUE | **12 / 23** requêtes (P ≥ 0.80) |
| Durée pipeline complet | **~4 secondes** |

### Distribution des décisions finales (50 dossiers)

```
CRITIQUE  ████████████████░░░░░░░░░░░░░░  14 dossiers (28%)
ÉLEVÉ     ████████████░░░░░░░░░░░░░░░░░░  10 dossiers (20%)
MOYEN     ████████████████████████████░░  25 dossiers (50%)
FAIBLE    ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░   1 dossier  ( 2%)
```

---

##  Architecture du système

```
dataset.csv
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                    main.py                          │
│                                                     │
│  Étape 1 ──► Chargement dataset (50 dossiers BF)   │
│  Étape 2 ──► Inférence neuronale (PyTorch)          │
│  Étape 3 ──► Inférence probabiliste (ProbLog)       │
│  Étape 4 ──► Évaluation règles Prolog (A/B/C/D)    │
│  Étape 5 ──► Fusion neuro-symbolique (DeepProbLog)  │
│  Étape 6 ──► Rapport consolidé XAI                 │
└─────────────────────────────────────────────────────┘
    │
    ▼
rapport_final_landguard.txt
rapport_final_landguard.csv
```

