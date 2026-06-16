#!/usr/bin/env python3
"""
LandGuard Neuro-Symbolic AI
neural_model.py — Module neuronal PyTorch (Partie 4)

Architecture : 12 → 64 → 32 → 16 → 4 classes
Classes : standard | atypique | speculateur | fraude
Contexte : Burkina Faso — 50 dossiers fonciers
"""

import os, csv, json
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from pathlib import Path
from collections import Counter

# ── Configuration ──────────────────────────────────────────
INPUT_DIM   = 12
HIDDEN_DIM1 = 64
HIDDEN_DIM2 = 32
HIDDEN_DIM3 = 16
OUTPUT_DIM  = 4
CLASSES     = ["standard", "atypique", "speculateur", "fraude"]
LABEL_MAP   = {"standard":0, "speculateur":2, "accapareur":1, "limite":1, "fraude":3}
LEARNING_RATE = 0.001
EPOCHS        = 150
BATCH_SIZE    = 8
WEIGHT_DECAY  = 1e-4

BASE_DIR     = Path(__file__).parent
DATASET_PATH = BASE_DIR / "dataset.csv"
WEIGHTS_PATH = BASE_DIR / "model_weights.pth"
SCALER_PATH  = BASE_DIR / "feature_scaler.json"


# ── Architecture ────────────────────────────────────────────
class FraudDetectionNet(nn.Module):
    """
    Réseau feed-forward pour détection de fraude foncière.
    Retourne log_softmax pour compatibilité NLLLoss et DeepProbLog.
    """
    def __init__(self, dropout=0.3):
        super().__init__()
        self.input_dim  = INPUT_DIM
        self.output_dim = OUTPUT_DIM
        self.classes    = CLASSES

        self.fc1 = nn.Linear(INPUT_DIM,    HIDDEN_DIM1)
        self.bn1 = nn.BatchNorm1d(HIDDEN_DIM1)
        self.fc2 = nn.Linear(HIDDEN_DIM1,  HIDDEN_DIM2)
        self.bn2 = nn.BatchNorm1d(HIDDEN_DIM2)
        self.fc3 = nn.Linear(HIDDEN_DIM2,  HIDDEN_DIM3)
        self.bn3 = nn.BatchNorm1d(HIDDEN_DIM3)
        self.fc_out = nn.Linear(HIDDEN_DIM3, OUTPUT_DIM)
        self.drop = nn.Dropout(dropout)

        for m in self.modules():
            if isinstance(m, nn.Linear):
                nn.init.xavier_uniform_(m.weight)
                nn.init.zeros_(m.bias)

    def forward(self, x):
        def bn_safe(layer, bn, t):
            t = layer(t)
            if t.size(0) > 1: t = bn(t)
            return t
        x = self.drop(F.relu(bn_safe(self.fc1, self.bn1, x)))
        x = self.drop(F.relu(bn_safe(self.fc2, self.bn2, x)))
        x = F.relu(bn_safe(self.fc3, self.bn3, x))
        return F.log_softmax(self.fc_out(x), dim=-1)

    def predict_proba(self, x):
        self.eval()
        with torch.no_grad():
            return torch.exp(self.forward(x))

    def predict_class(self, x):
        p = self.predict_proba(x)
        idx = p.argmax(dim=-1).item()
        return CLASSES[idx], p[0][idx].item()


# ── Dataset ─────────────────────────────────────────────────
class LandGuardDataset(Dataset):
    """
    Charge les 50 dossiers burkinabè depuis dataset.csv.
    Features (12) : parcelles, reventes, plus-value, délai,
                    liens réseau, contacts partagés, âge.
    """
    FEATURE_NAMES = [
        "nb_parcelles_urbaines","nb_parcelles_rurales","nb_parcelles_total",
        "frequence_revente","ratio_plus_value","delai_detention_norm",
        "nb_liens_reseau","partage_telephone","partage_adresse",
        "partage_iban","lien_familial_agent","age_norm",
    ]

    def __init__(self, csv_path, fit=True, scaler_path=None):
        raws, labs = [], []
        with open(csv_path, newline='', encoding='utf-8') as f:
            for row in csv.DictReader(f):
                raws.append(self._feat(row))
                labs.append(LABEL_MAP.get(row['label'], 0))

        X = np.array(raws, dtype=np.float32)
        if fit:
            self.mins = X.min(0); self.maxs = X.max(0)
            if scaler_path:
                json.dump({'min_vals': self.mins.tolist(),
                           'max_vals': self.maxs.tolist(),
                           'feature_names': self.FEATURE_NAMES},
                          open(scaler_path,'w'), indent=2)
        elif scaler_path and os.path.exists(scaler_path):
            d = json.load(open(scaler_path))
            self.mins = np.array(d['min_vals'], np.float32)
            self.maxs = np.array(d['max_vals'], np.float32)
        else:
            self.mins = X.min(0); self.maxs = X.max(0)

        den = self.maxs - self.mins; den[den==0] = 1.0
        Xn  = (X - self.mins) / den

        self.samples = [torch.tensor(r, dtype=torch.float32) for r in Xn]
        self.labels  = [torch.tensor(l, dtype=torch.long) for l in labs]

    def _feat(self, row):
        nu    = float(row.get('nb_parcelles_urbaines',0))
        nr    = float(row.get('nb_parcelles_rurales',0))
        nt    = float(row.get('nb_parcelles_total',0))
        pa    = float(row.get('prix_achat_fcfa',1))
        pr    = float(row.get('prix_revente_fcfa',0))
        delai = float(row.get('delai_detention_jours',365))
        nrev  = float(row.get('nb_reventes',0))
        liens = float(row.get('nb_liens_reseau',0))
        age   = float(row.get('age_premier_achat',35))
        return [
            nu, nr, nt,
            nrev / max(delai/365.0, 0.1),
            pr/pa if pa>0 and pr>0 else 0.0,
            delai/365.0,
            liens,
            1.0 if row.get('partage_telephone')=='oui' else 0.0,
            1.0 if row.get('partage_adresse')=='oui'   else 0.0,
            1.0 if row.get('partage_iban')=='oui'      else 0.0,
            1.0 if row.get('lien_familial_agent')=='oui' else 0.0,
            age/100.0,
        ]

    def __len__(self):  return len(self.samples)
    def __getitem__(self, i): return self.samples[i], self.labels[i]


# ── Entraînement ────────────────────────────────────────────
def train(model, dataset, epochs=EPOCHS, lr=LEARNING_RATE,
          batch_size=BATCH_SIZE, weights_path=None):
    """Entraîne le modèle avec poids de classe pour le déséquilibre."""
    # standard=30, atypique=10, speculateur=5, fraude=5
    class_weights = torch.tensor([1.0, 3.0, 6.0, 6.0])
    criterion = nn.NLLLoss(weight=class_weights)
    optimizer = optim.Adam(model.parameters(), lr=lr, weight_decay=WEIGHT_DECAY)
    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=50, gamma=0.5)
    loader    = DataLoader(dataset, batch_size=batch_size, shuffle=True, drop_last=False)

    history   = {'loss':[], 'accuracy':[]}
    best_acc  = 0.0

    print(f"\n{'='*55}")
    print(f"  LandGuard — FraudDetectionNet — Entraînement")
    print(f"  {len(dataset)} dossiers | {epochs} epochs | lr={lr}")
    print(f"  12 → {HIDDEN_DIM1} → {HIDDEN_DIM2} → {HIDDEN_DIM3} → 4")
    print(f"{'='*55}")

    for epoch in range(1, epochs+1):
        model.train()
        tot_loss, correct, total = 0.0, 0, 0
        for Xb, yb in loader:
            optimizer.zero_grad()
            out  = model(Xb)
            loss = criterion(out, yb)
            loss.backward(); optimizer.step()
            tot_loss += loss.item() * Xb.size(0)
            correct  += (out.argmax(1) == yb).sum().item()
            total    += Xb.size(0)
        scheduler.step()

        avg_loss = tot_loss / total
        acc      = correct / total * 100
        history['loss'].append(avg_loss)
        history['accuracy'].append(acc)

        if acc > best_acc:
            best_acc = acc
            if weights_path:
                torch.save({'epoch':epoch,
                            'model_state_dict': model.state_dict(),
                            'optimizer_state_dict': optimizer.state_dict(),
                            'accuracy': acc, 'loss': avg_loss,
                            'classes': CLASSES, 'input_dim': INPUT_DIM},
                           weights_path)
        if epoch % 25 == 0 or epoch == 1:
            print(f"  [{epoch:3d}/{epochs}] Loss={avg_loss:.4f}  "
                  f"Acc={acc:.1f}%  (best={best_acc:.1f}%)")

    print(f"\n  ✅ Meilleure accuracy : {best_acc:.1f}%")
    return history


# ── Évaluation ──────────────────────────────────────────────
def evaluate(model, dataset):
    """Évalue et affiche la matrice de confusion + métriques par classe."""
    model.eval()
    preds, trues = [], []
    with torch.no_grad():
        for X, y in DataLoader(dataset, batch_size=len(dataset)):
            preds.extend(model(X).argmax(1).tolist())
            trues.extend(y.tolist())

    n = OUTPUT_DIM
    mat = [[0]*n for _ in range(n)]
    for t,p in zip(trues, preds): mat[t][p] += 1

    print(f"\n  Matrice de confusion :")
    print(f"  {'':>16} " + "  ".join(f"{c[:8]:>8}" for c in CLASSES))
    for i, row in enumerate(mat):
        print(f"  {CLASSES[i]:>16} " + "  ".join(f"{v:>8}" for v in row))

    correct = sum(mat[i][i] for i in range(n))
    total   = sum(sum(r) for r in mat)
    acc = correct/total*100
    metrics = {'accuracy': acc, 'matrix': mat, 'per_class': {}}

    print(f"\n  Métriques par classe :")
    for i, cls in enumerate(CLASSES):
        tp = mat[i][i]
        fp = sum(mat[j][i] for j in range(n)) - tp
        fn = sum(mat[i]) - tp
        P  = tp/(tp+fp) if tp+fp > 0 else 0.0
        R  = tp/(tp+fn) if tp+fn > 0 else 0.0
        F1 = 2*P*R/(P+R) if P+R > 0 else 0.0
        metrics['per_class'][cls] = {'precision':P,'recall':R,'f1':F1}
        print(f"    {cls:>16} : P={P:.2f}  R={R:.2f}  F1={F1:.2f}")

    print(f"\n  Accuracy globale : {correct}/{total} = {acc:.1f}%")
    return metrics


# ── Utilitaires ─────────────────────────────────────────────
def load_model(weights_path=None):
    model = FraudDetectionNet()
    if weights_path and os.path.exists(weights_path):
        ck = torch.load(weights_path, map_location='cpu', weights_only=True)
        model.load_state_dict(ck['model_state_dict'])
        print(f"  Modèle chargé : epoch={ck.get('epoch','?')} "
              f"acc={ck.get('accuracy',0):.1f}%")
    model.eval()
    return model


def normalize_features(raw, scaler_path):
    d    = json.load(open(scaler_path))
    mins = np.array(d['min_vals'], np.float32)
    maxs = np.array(d['max_vals'], np.float32)
    den  = maxs - mins; den[den==0] = 1.0
    return ((np.array(raw, np.float32) - mins) / den).tolist()


def predict_actor(features, model):
    x     = torch.tensor(features, dtype=torch.float32).unsqueeze(0)
    probs = model.predict_proba(x)[0]
    idx   = probs.argmax().item()
    return {'classe':      CLASSES[idx],
            'probabilites':{c: round(probs[i].item(),4) for i,c in enumerate(CLASSES)},
            'confiance':   round(probs[idx].item(), 4)}


# ── Main ────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n" + "="*55)
    print("  LandGuard AI — Entraînement réseau neuronal")
    print("  Burkina Faso — 50 dossiers fonciers")
    print("="*55)

    dataset = LandGuardDataset(str(DATASET_PATH), fit=True,
                               scaler_path=str(SCALER_PATH))
    print(f"\n  Dataset : {len(dataset)} dossiers")
    cnt = Counter(dataset.labels[i].item() for i in range(len(dataset)))
    for i,c in enumerate(CLASSES):
        print(f"    {c:>16} : {cnt.get(i,0)}")

    model   = FraudDetectionNet()
    total_p = sum(p.numel() for p in model.parameters())
    print(f"\n  Paramètres : {total_p}")

    history  = train(model, dataset, weights_path=str(WEIGHTS_PATH))
    best_mdl = load_model(str(WEIGHTS_PATH))
    metrics  = evaluate(best_mdl, dataset)

    # Démonstration sur acteurs burkinabè représentatifs
    print("\n" + "="*55)
    print("  Prédictions sur cas représentatifs")
    print("="*55)
    cas = [
        ("Adama Ouédraogo (Pissy, standard)",
         normalize_features([1,0,1, 0.0,0.0, 2.0, 0,0,0,0,0,0.34], SCALER_PATH)),
        ("Idrissa Kaboré (Secteur 30, accapareur)",
         normalize_features([4,0,4, 0.0,0.0, 3.0, 3,1,1,1,0,0.47], SCALER_PATH)),
        ("Romuald Sawadogo (Pissy, spéculateur)",
         normalize_features([2,1,3, 2.0,2.37,0.08,2,0,1,0,0,0.38], SCALER_PATH)),
        ("Kassoum Ouédraogo (Cissin, fraude)",
         normalize_features([4,2,6, 3.0,0.0, 1.5, 5,1,1,1,1,0.39], SCALER_PATH)),
    ]
    for nom, feats in cas:
        r = predict_actor(feats, best_mdl)
        print(f"\n  {nom}")
        print(f"    → {r['classe'].upper()} (confiance={r['confiance']:.1%})")
        for c,p in r['probabilites'].items():
            print(f"       {c:>16} : {p:.3f} {'█'*int(p*25)}")
