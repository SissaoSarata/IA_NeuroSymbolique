% ============================================================
% LandGuard Neuro-Symbolic AI
% rules.pl — 15 règles logiques réparties en 4 catégories
% Catégorie A : Accaparement
% Catégorie B : Spéculation
% Catégorie C : Conflits d'intérêts
% Catégorie D : Réseaux & Prête-noms
% ============================================================
:- encoding(utf8).
:- use_module(library(lists)).

% ============================================================
% CATÉGORIE A — ACCAPAREMENT (4 règles)
% ============================================================

% REGLE-A1 : Accaparement urbain direct (≥ 4 parcelles urbaines)
accaparement_urbain(X) :-
    citoyen(X),
    findall(P, (possede(X, P), parcelle_urbaine(P)), Parcelles),
    length(Parcelles, N),
    N >= 4,
    log_alerte('REGLE-A1', X, Parcelles,
        'Accaparement urbain détecté : citoyen possède >= 4 parcelles urbaines').

% REGLE-A2 : Accaparement rural (≥ 5 parcelles rurales)
accaparement_rural(X) :-
    citoyen(X),
    findall(P, (possede(X, P), parcelle_rurale(P)), Parcelles),
    length(Parcelles, N),
    N >= 5,
    log_alerte('REGLE-A2', X, Parcelles,
        'Accaparement rural détecté : citoyen possède >= 5 parcelles rurales').

% REGLE-A3 : Multipropriété totale excessive (≥ 6 parcelles toutes catégories)
multi_propriete_excessive(X) :-
    acteur(X),
    findall(P, possede(X, P), Toutes),
    length(Toutes, N),
    N >= 6,
    log_alerte('REGLE-A3', X, Toutes,
        'Multipropriété excessive : acteur cumule >= 6 parcelles au total').

% REGLE-A4 : Accaparement familial groupé (famille cumule ≥ 6 parcelles urbaines)
accaparement_familial(X) :-
    citoyen(X),
    findall(M, (lien_familial(X, M), citoyen(M)), Membres),
    findall(P, (
        (member(M2, [X|Membres])),
        possede(M2, P),
        parcelle_urbaine(P)
    ), ParcFam),
    sort(ParcFam, ParcUniq),
    length(ParcUniq, N),
    N >= 6,
    log_alerte('REGLE-A4', X, ParcUniq,
        'Accaparement familial : le réseau familial cumule >= 6 parcelles urbaines').

% ============================================================
% CATÉGORIE B — SPÉCULATION (4 règles)
% ============================================================

% REGLE-B1 : Revente ultra-rapide (délai < 90 jours)
revente_rapide(X, P) :-
    acteur(X),
    possede(X, P),
    date_achat(X, P, DateAchat),
    vend_a(X, _, _, DateVente),
    Delai is DateVente - DateAchat,
    Delai < 90,
    Delai > 0,
    log_alerte('REGLE-B1', X, [P, DateAchat, DateVente, Delai],
        'Revente ultra-rapide : parcelle revendue en moins de 90 jours').

% REGLE-B2 : Plus-value anormale (> 80% du prix d'achat)
plus_value_anormale(X, P) :-
    acteur(X),
    prix_achat(X, P, PrixAchat),
    vend_a(X, _, PrixVente, _),
    PrixAchat > 0,
    PlusValue is (PrixVente - PrixAchat) / PrixAchat * 100,
    PlusValue > 80,
    log_alerte('REGLE-B2', X, [P, PrixAchat, PrixVente, PlusValue],
        'Plus-value anormale : bénéfice supérieur à 80% du prix d achat').

% REGLE-B3 : Spéculateur confirmé (revente rapide ET plus-value anormale)
speculateur_confirme(X) :-
    acteur(X),
    revente_rapide(X, P),
    plus_value_anormale(X, P),
    log_alerte('REGLE-B3', X, [P],
        'Spéculateur confirmé : cumul revente rapide et plus-value anormale sur même parcelle').

% REGLE-B4 : Non-mise en valeur (achat sans aucune affectation déclarée après 180j)
non_mise_en_valeur(X, P) :-
    acteur(X),
    possede(X, P),
    date_achat(X, P, DateAchat),
    date_courante(DateCourante),
    Detention is DateCourante - DateAchat,
    Detention > 180,
    \+ beneficiaire(X, _),
    \+ vend_a(X, _, _, _),
    log_alerte('REGLE-B4', X, [P, Detention],
        'Non-mise en valeur : parcelle détenue > 180 jours sans affectation ni cession').

% ============================================================
% CATÉGORIE C — CONFLITS D'INTÉRÊTS (4 règles)
% ============================================================

% REGLE-C1 : Auto-attribution directe (agent traite son propre dossier)
auto_attribution(X) :-
    agent_public(X),
    traite(X, Dossier),
    beneficiaire(X, Dossier),
    log_alerte('REGLE-C1', X, [Dossier],
        'Auto-attribution : agent public traite un dossier dont il est lui-même bénéficiaire').

% REGLE-C2 : Conflit familial (agent traite dossier bénéficiant un parent)
conflit_familial(X, Y) :-
    agent_public(X),
    traite(X, Dossier),
    beneficiaire(Y, Dossier),
    Y \= X,
    lien_familial(X, Y),
    log_alerte('REGLE-C2', X, [Dossier, Y],
        'Conflit familial : agent instruit dossier au profit d un membre de sa famille').

% REGLE-C3 : Favoritisme répétitif (agent traite ≥ 2 dossiers du même bénéficiaire)
favoritisme_repetitif(X, Y) :-
    agent_public(X),
    findall(D, (traite(X, D), beneficiaire(Y, D)), Dossiers),
    length(Dossiers, N),
    N >= 2,
    log_alerte('REGLE-C3', X, [Y, Dossiers],
        'Favoritisme répétitif : agent traite >= 2 dossiers pour le même bénéficiaire').

% REGLE-C4 : Notaire en conflit (instrumente une parcelle lui appartenant — CI-8)
notaire_conflit(X) :-
    notaire(X),
    traite(X, Dossier),
    concerne(Dossier, P),
    possede(X, P),
    log_alerte('REGLE-C4', X, [Dossier, P],
        'Conflit notaire : notaire instrumente un acte sur une parcelle lui appartenant').

% ============================================================
% CATÉGORIE D — RÉSEAUX & PRÊTE-NOMS (4 règles)
% ============================================================

% REGLE-D1 : Prête-nom par téléphone (deux propriétaires partagent un téléphone)
suspect_prete_nom_telephone(X, Y) :-
    acteur(X), acteur(Y),
    X \= Y,
    partage_telephone(X, Y),
    possede(X, _),
    possede(Y, _),
    log_alerte('REGLE-D1', X, [Y],
        'Prête-nom téléphone : deux propriétaires distincts partagent le même numéro').

% REGLE-D2 : Prête-nom par adresse et lien familial
suspect_prete_nom_adresse(X, Y) :-
    acteur(X), acteur(Y),
    X \= Y,
    partage_adresse(X, Y),
    lien_familial(X, Y),
    possede(X, _),
    possede(Y, _),
    log_alerte('REGLE-D2', X, [Y],
        'Prête-nom adresse+famille : adresse commune et lien familial entre propriétaires').

% REGLE-D3 : Réseau circulaire de transactions (A → B → C → A)
reseau_circulaire(X, Y, Z) :-
    acteur(X), acteur(Y), acteur(Z),
    X \= Y, Y \= Z, X \= Z,
    vend_a(X, Y, _, _),
    vend_a(Y, Z, _, _),
    vend_a(Z, X, _, _),
    log_alerte('REGLE-D3', X, [Y, Z],
        'Réseau circulaire : chaîne de reventes A→B→C→A détectée (blanchiment probable)').

% REGLE-D4 : Cluster IBAN partagé (réseau financier coordonné)
reseau_iban_partage(X, Y, Z) :-
    acteur(X), acteur(Y), acteur(Z),
    X \= Y, Y \= Z, X \= Z,
    partage_iban(X, Y),
    partage_iban(Y, Z),
    log_alerte('REGLE-D4', X, [Y, Z],
        'Réseau IBAN : trois acteurs liés par comptes bancaires partagés en chaîne').

% ============================================================
% RÈGLE SYNTHÈSE : Fraude Composite (combine plusieurs indicateurs)
% ============================================================

fraude_composite(X) :-
    acteur(X),
    partage_telephone(X, _),
    partage_adresse(X, _),
    findall(Y, vend_a(X, Y, _, _), Ventes),
    length(Ventes, NV), NV >= 2,
    lien_familial(X, A), agent_public(A),
    log_alerte('REGLE-COMPOSITE', X, [A, Ventes],
        'Fraude composite : cumul téléphone+adresse partagés, >= 2 reventes, et lien avec agent public').
