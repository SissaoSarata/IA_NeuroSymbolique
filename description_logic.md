# LandGuard Neuro-Symbolic AI — Modélisation en Logique de Description

## 1. Taxonomie des Concepts (TBox)

### Hiérarchie des Acteurs
```
Acteur ≡ Citoyen ⊔ AgentPublic ⊔ Promoteur ⊔ Notaire
Citoyen ⊑ Acteur
AgentPublic ⊑ Acteur
Promoteur ⊑ Acteur
Notaire ⊑ Acteur
Citoyen ⊓ AgentPublic ⊑ ⊥   (disjonction stricte)
```

### Hiérarchie des Parcelles
```
Parcelle ≡ ParcelleUrbaine ⊔ ParcelleRurale
ParcelleUrbaine ⊑ Parcelle
ParcelleRurale ⊑ Parcelle
ParcelleUrbaine ⊓ ParcelleRurale ⊑ ⊥
```

### Hiérarchie des Affectations
```
Affectation ≡ Attribution ⊔ Revente ⊔ Héritage
Attribution ⊑ Affectation
Revente ⊑ Affectation
Héritage ⊑ Affectation
```

### Hiérarchie des Dossiers
```
Dossier ≡ DossierActif ⊔ DossierSuspect
DossierActif ⊑ Dossier
DossierSuspect ⊑ Dossier
DossierActif ⊓ DossierSuspect ⊑ ⊥
```

### Hiérarchie des Liens Sociaux
```
LienSocial ≡ Familial ⊔ Professionnel ⊔ Financier
Familial ⊑ LienSocial
Professionnel ⊑ LienSocial
Financier ⊑ LienSocial
```

---

## 2. Rôles et Relations

| Rôle | Domaine | Co-domaine | Description |
|------|---------|------------|-------------|
| `possede(X,Y)` | Acteur | Parcelle | X est propriétaire de Y |
| `traite(X,Y)` | AgentPublic | Dossier | X instruit le dossier Y |
| `beneficiaire(X,Y)` | Acteur | Affectation | X bénéficie de l'affectation Y |
| `lienFamilial(X,Y)` | Acteur | Acteur | X et Y sont liés familialement |
| `vendA(X,Y)` | Acteur | Acteur | X vend une parcelle à Y |
| `partageTelephone(X,Y)` | Acteur | Acteur | X et Y ont le même téléphone |
| `partageAdresse(X,Y)` | Acteur | Acteur | X et Y ont la même adresse |
| `partageIBAN(X,Y)` | Acteur | Acteur | X et Y partagent un compte bancaire |
| `concerne(X,Y)` | Dossier | Parcelle | Le dossier X porte sur la parcelle Y |
| `instruitPar(X,Y)` | Dossier | AgentPublic | Le dossier X est traité par Y |

### Propriétés des Rôles
```
lienFamilial ≡ lienFamilial⁻         (symétrique)
partageTelephone ≡ partageTelephone⁻  (symétrique)
partageAdresse ≡ partageAdresse⁻      (symétrique)
lienFamilial ∘ lienFamilial ⊑ lienFamilial  (transitivité partielle)
```

---

## 3. Axiomes de Description Logic (10 axiomes complexes)

### AX-01 : Accaparement Urbain
```
Citoyen ⊓ (≥ 4 possede.ParcelleUrbaine) ⊑ AccapareurUrbain
```
*Un citoyen possédant 4 parcelles urbaines ou plus est classé accapareur urbain.*

### AX-02 : Conflit d'Intérêt Direct
```
AgentPublic ⊓ ∃traite.Dossier ⊓ ∃beneficiaire.Affectation ⊑ ConflitInteret
```
*Un agent public qui traite un dossier dont il est lui-même bénéficiaire est en conflit d'intérêt.*

### AX-03 : Prête-Nom par Téléphone
```
Acteur ⊓ ∃partageTelephone.(Acteur ⊓ ∃possede.Parcelle) ⊑ SuspectPreteNom
```
*Tout acteur partageant un téléphone avec un propriétaire de parcelle est suspect de prête-nom.*

### AX-04 : Spéculateur Foncier
```
Acteur ⊓ ∃vendA.Acteur ⊓ (≥ 3 possede.Parcelle) ⊑ SpeculateurFoncier
```
*Un acteur ayant revendu des parcelles et possédant au moins 3 propriétés est classé spéculateur.*

### AX-05 : Conflit d'Intérêt Familial
```
AgentPublic ⊓ ∃traite.(Dossier ⊓ ∃concerne.(Parcelle ⊓ ∃possede⁻.(Acteur ⊓ ∃lienFamilial.AgentPublic))) ⊑ ConflitFamilial
```
*Un agent traitant un dossier concernant une parcelle appartenant à un membre de sa famille est en conflit familial.*

### AX-06 : Réseau Circulaire de Transactions
```
Acteur ⊓ ∃vendA.(Acteur ⊓ ∃vendA.(Acteur ⊓ ∃vendA.Self)) ⊑ ReseauCirculaire
```
*Un acteur impliqué dans une chaîne de reventes revenant à lui-même constitue un réseau circulaire (blanchiment).*

### AX-07 : Promoteur Fantôme
```
Promoteur ⊓ (≤ 0 partageAdresse.Acteur) ⊓ (≤ 0 partageTelephone.Acteur) ⊑ PromoteurFantome
```
*Un promoteur sans adresse vérifiable ni téléphone partagé avec aucun acteur du système est suspect d'être fantôme.*

### AX-08 : Accaparement Rural Familial
```
Acteur ⊓ (≥ 2 lienFamilial.Acteur) ⊓ (≥ 6 possede⁻.ParcelleRurale) ⊑ AccapareurRuralFamilial
```
*Un réseau familial (≥ 2 membres liés) cumulant plus de 6 parcelles rurales constitue un accaparement rural familial.*

### AX-09 : Dossier à Haut Risque
```
Dossier ⊓ ∃instruitPar.(AgentPublic ⊓ ∃lienFamilial.Acteur) ⊓ ∃concerne.ParcelleUrbaine ⊑ DossierHautRisque
```
*Un dossier portant sur une parcelle urbaine, instruit par un agent ayant des liens familiaux avec un acteur du dossier, est à haut risque.*

### AX-10 : Fraude Composite Neuro-Symbolique
```
Acteur ⊓ ∃partageTelephone.Acteur ⊓ ∃partageAdresse.Acteur ⊓ (≥ 2 vendA.Acteur) ⊓ ∃lienFamilial.AgentPublic ⊑ FraudeComposite
```
*Un acteur cumulant : téléphone partagé + adresse partagée + au moins 2 reventes + lien familial avec un agent public constitue une fraude composite.*

---

## 4. Contraintes d'Intégrité (CI)

### CI-1 : Interdiction d'auto-traitement
```
∀X : AgentPublic(X) → ¬(traite(X, D) ∧ beneficiaire(X, A) ∧ concerne(D, P) ∧ affecte(A, P))
```
*Un agent public ne peut pas traiter un dossier dont il est bénéficiaire direct.*

### CI-2 : Plafond de parcelles urbaines
```
∀X : Citoyen(X) → |{P : ParcelleUrbaine(P) ∧ possede(X,P)}| ≤ 3
```
*Un citoyen ne peut posséder plus de 3 parcelles urbaines.*

### CI-3 : Plafond de parcelles rurales
```
∀X : Citoyen(X) → |{P : ParcelleRurale(P) ∧ possede(X,P)}| ≤ 5
```
*Un citoyen ne peut posséder plus de 5 parcelles rurales.*

### CI-4 : Unicité de traitement de dossier
```
∀D : Dossier(D) → |{A : AgentPublic(A) ∧ traite(A,D)}| = 1
```
*Chaque dossier doit être traité par exactement un agent public.*

### CI-5 : Téléphone partagé entre acheteurs → suspicion prête-nom
```
∀X,Y : (Acteur(X) ∧ Acteur(Y) ∧ X≠Y ∧ partageTelephone(X,Y) ∧ ∃P(possede(X,P) ∧ possede(Y,P'))) → SuspectPreteNom(X) ∧ SuspectPreteNom(Y)
```

### CI-6 : Interdiction de revente ultra-rapide (< 6 mois)
```
∀X,P : (possede(X,P) ∧ duree_detention(X,P) < 180) → ViolationSpeculation(X)
```

### CI-7 : Adresse partagée entre vendeur et acheteur → suspicion
```
∀X,Y : (vendA(X,Y) ∧ partageAdresse(X,Y)) → SuspectTransaction(X,Y)
```

### CI-8 : Notaire ne peut instrumenter ses propres transactions
```
∀X : Notaire(X) → ¬(∃P : possede(X,P) ∧ ∃D : instruitPar(D,X) ∧ concerne(D,P))
```

---

## 5. Correspondance DL → Prédicats Prolog

| Concept DL | Prédicat Prolog |
|-----------|-----------------|
| `Citoyen(x)` | `citoyen(X)` |
| `AgentPublic(x)` | `agent_public(X)` |
| `Promoteur(x)` | `promoteur(X)` |
| `Notaire(x)` | `notaire(X)` |
| `ParcelleUrbaine(p)` | `parcelle_urbaine(P)` |
| `ParcelleRurale(p)` | `parcelle_rurale(P)` |
| `possede(x,y)` | `possede(X,Y)` |
| `traite(x,y)` | `traite(X,Y)` |
| `lienFamilial(x,y)` | `lien_familial(X,Y)` |
| `vendA(x,y)` | `vend_a(X,Y,Prix,Date)` |
| `partageTelephone(x,y)` | `partage_telephone(X,Y)` |
| `partageAdresse(x,y)` | `partage_adresse(X,Y)` |
| `AccapareurUrbain(x)` | `accapareur_urbain(X)` |
| `ConflitInteret(x)` | `conflit_interet(X,_)` |
| `SuspectPreteNom(x)` | `suspect_prete_nom(X,_)` |
