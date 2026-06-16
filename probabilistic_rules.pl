% ============================================================
% LandGuard Neuro-Symbolic AI
% probabilistic_rules.pl — Raisonnement probabiliste (ProbLog)
% Partie 3 : Modélisation de l'incertitude
% Jeu de données : 50 dossiers — Contexte Burkina Faso
% ============================================================
%
% Échelle de criticité :
%   FAIBLE   : P < 0.30
%   MOYEN    : 0.30 <= P < 0.60
%   ÉLEVÉ    : 0.60 <= P < 0.80
%   CRITIQUE : P >= 0.80
% ============================================================

% ============================================================
% SECTION 1 : BASE DE FAITS (extraits de knowledge_base_bf.pl)
% ============================================================

% --- Citoyens standards ---
citoyen(adama_ouedraogo). citoyen(mariam_kabore). citoyen(salif_traore).
citoyen(fatimata_sawadogo). citoyen(issouf_compaore). citoyen(aminata_diallo).
citoyen(rasmane_zongo). citoyen(bintou_nikiema). citoyen(dramane_ouedraogo).
citoyen(safi_kabore). citoyen(wendyam_compaore). citoyen(hawa_sawadogo).
citoyen(lassane_traore). citoyen(roukiata_zongo). citoyen(moussa_ouedraogo).
citoyen(aissata_kabore). citoyen(karim_compaore). citoyen(oumou_diallo).
citoyen(youssouf_nikiema). citoyen(kadiatou_traore). citoyen(noufou_sawadogo).
citoyen(bibata_compaore). citoyen(inoussa_kabore). citoyen(pelagie_ouedraogo).
citoyen(seydou_zongo). citoyen(issa_compaore). citoyen(fatoumata_nikiema).
citoyen(bassirou_traore). citoyen(marietou_sawadogo). citoyen(hamidou_diallo).

% --- Citoyens spéculateurs ---
citoyen(souleymane_kabore). citoyen(aicha_compaore). citoyen(gaoussou_traore).
citoyen(romuald_sawadogo). citoyen(clarisse_ouedraogo).

% --- Citoyens accapareurs ---
citoyen(idrissa_kabore). citoyen(aziz_compaore).
citoyen(noel_sawadogo). citoyen(yakubu_ouedraogo).

% --- Citoyens cas limites ---
citoyen(hamza_diallo). citoyen(flore_compaore).
citoyen(roukia_sawadogo). citoyen(mariam_sawadogo).

% --- Fraudeurs complexes ---
citoyen(kassoum_ouedraogo).

% --- Agents publics ---
agent_public(moussa_konate).  % Konaté Moussa
agent_public(paul_sawadogo).  % Sawadogo Paul
agent_public(brice_coulibaly). % Coulibaly Brice
agent_public(ines_zongo).     % Zongo Inès
agent_public(henri_tapsoba).  % Tapsoba Henri
agent_public(ramata_kabore).  % FRAUDE — agent auto-attribution

% --- Promoteurs ---
promoteur(marcelline_traore). % Accapareur promoteur

% --- Notaires ---
notaire(saidou_kabore).   % CAS LIMITE — notaire
notaire(cheick_traore).   % CAS LIMITE
notaire(luc_traore).      % FRAUDE — notaire auto-attribution
notaire(adama_compaore).  % FRAUDE — promoteur/notaire réseau

% ============================================================
% SECTION 2 : PARCELLES
% ============================================================

% Standards
parcelle_urbaine(p_urb_001). parcelle_urbaine(p_urb_002). parcelle_urbaine(p_urb_003).
parcelle_urbaine(p_urb_004). parcelle_urbaine(p_urb_005). parcelle_urbaine(p_urb_006).
parcelle_rurale(p_rur_001). parcelle_rurale(p_rur_002). parcelle_rurale(p_rur_003).

% Accapareurs — idrissa_kabore (4 urb) et aziz_compaore (5 urb + 1 rur)
parcelle_urbaine(p_urb_033). parcelle_urbaine(p_urb_034).
parcelle_urbaine(p_urb_035). parcelle_urbaine(p_urb_036).
parcelle_urbaine(p_urb_037). parcelle_urbaine(p_urb_038).
parcelle_urbaine(p_urb_039). parcelle_urbaine(p_urb_040). parcelle_urbaine(p_urb_041).
parcelle_rurale(p_rur_024).

% Fraudes — kassoum (4urb+2rur), ramata (3urb), adama_compaore (5urb+3rur)
parcelle_urbaine(p_urb_065). parcelle_urbaine(p_urb_066).
parcelle_urbaine(p_urb_067). parcelle_urbaine(p_urb_068).
parcelle_rurale(p_rur_034). parcelle_rurale(p_rur_035).
parcelle_urbaine(p_urb_069). parcelle_urbaine(p_urb_070). parcelle_urbaine(p_urb_071).
parcelle_urbaine(p_urb_072). parcelle_urbaine(p_urb_073). parcelle_urbaine(p_urb_074).
parcelle_urbaine(p_urb_075). parcelle_urbaine(p_urb_076).
parcelle_rurale(p_rur_036). parcelle_rurale(p_rur_037). parcelle_rurale(p_rur_038).
parcelle_urbaine(p_urb_077). parcelle_urbaine(p_urb_078).
parcelle_rurale(p_rur_039). parcelle_rurale(p_rur_040).
parcelle_urbaine(p_urb_079). parcelle_urbaine(p_urb_080).

% ============================================================
% SECTION 3 : PROPRIÉTÉS
% ============================================================

% Standards (1 parcelle chacun)
possede(adama_ouedraogo, p_urb_001).   possede(mariam_kabore, p_rur_001).
possede(salif_traore, p_urb_002).      possede(fatimata_sawadogo, p_rur_002).
possede(issouf_compaore, p_urb_003).   possede(aminata_diallo, p_rur_003).

% Accapareurs
possede(idrissa_kabore, p_urb_033). possede(idrissa_kabore, p_urb_034).
possede(idrissa_kabore, p_urb_035). possede(idrissa_kabore, p_urb_036).
possede(aziz_compaore, p_urb_037).  possede(aziz_compaore, p_urb_038).
possede(aziz_compaore, p_urb_039).  possede(aziz_compaore, p_urb_040).
possede(aziz_compaore, p_urb_041).  possede(aziz_compaore, p_rur_024).

% Fraudeurs
possede(kassoum_ouedraogo, p_urb_065). possede(kassoum_ouedraogo, p_urb_066).
possede(kassoum_ouedraogo, p_urb_067). possede(kassoum_ouedraogo, p_urb_068).
possede(kassoum_ouedraogo, p_rur_034). possede(kassoum_ouedraogo, p_rur_035).
possede(ramata_kabore, p_urb_069). possede(ramata_kabore, p_urb_070).
possede(ramata_kabore, p_urb_071).
possede(adama_compaore, p_urb_072). possede(adama_compaore, p_urb_073).
possede(adama_compaore, p_urb_074). possede(adama_compaore, p_urb_075).
possede(adama_compaore, p_urb_076). possede(adama_compaore, p_rur_036).
possede(adama_compaore, p_rur_037). possede(adama_compaore, p_rur_038).
possede(luc_traore, p_urb_077). possede(luc_traore, p_urb_078).
possede(luc_traore, p_rur_039).
possede(mariam_sawadogo, p_urb_079). possede(mariam_sawadogo, p_urb_080).
possede(mariam_sawadogo, p_rur_040).

% Notaire auto-attribution
possede(saidou_kabore, p_urb_004). possede(cheick_traore, p_urb_005).

% ============================================================
% SECTION 4 : TRANSACTIONS
% vend_a(Vendeur, Acheteur, Prix_FCFA, Jour)
% ============================================================

% Spéculateurs
vend_a(souleymane_kabore, acheteur_d031,  9500000, 185).  % +11.8% en 25j
vend_a(aicha_compaore,    acheteur_d032, 14500000, 210).  % +141.7% en 45j
vend_a(gaoussou_traore,   acheteur_d033, 35000000, 230).  % +133.3% en 60j
vend_a(romuald_sawadogo,  acheteur_d034, 28500000, 205).  % +137.5% en 30j
vend_a(clarisse_ouedraogo,acheteur_d035, 11200000, 235).  % +148.9% en 55j

% Cas limites
vend_a(hamza_diallo,    acheteur_d041, 14000000, 250).    % +55.6% en 40j
vend_a(flore_compaore,  acheteur_d043, 13000000, 305).    % +36.8% en 85j
vend_a(roukia_sawadogo, acheteur_d045, 19500000, 300).    % +77.3% en 70j

% Fraudes complexes
vend_a(ramata_kabore,    acheteur_d047, 32000000, 275).   % +106.5% en 35j
vend_a(luc_traore,       acheteur_d049, 29000000, 278).   % +107.1% en 28j
vend_a(mariam_sawadogo,  acheteur_d050, 55000000, 275).   % +111.5% en 20j

% Réseau circulaire de blanchiment (Ouagadougou)
vend_a(kassoum_ouedraogo, ramata_kabore,  22000000, 280).
vend_a(ramata_kabore,     adama_compaore, 23000000, 290).
vend_a(adama_compaore,    kassoum_ouedraogo, 21500000, 300).

% ============================================================
% SECTION 5 : PRIX D'ACHAT
% ============================================================

prix_achat(souleymane_kabore, p_urb_001,  8500000).
prix_achat(aicha_compaore,    p_urb_002,  6000000).
prix_achat(gaoussou_traore,   p_urb_003, 15000000).
prix_achat(romuald_sawadogo,  p_urb_004, 12000000).
prix_achat(clarisse_ouedraogo,p_urb_005,  4500000).
prix_achat(hamza_diallo,      p_urb_006,  9000000).
prix_achat(roukia_sawadogo,   p_rur_001, 11000000).
prix_achat(ramata_kabore,     p_urb_069, 15500000).
prix_achat(luc_traore,        p_urb_077, 14000000).
prix_achat(mariam_sawadogo,   p_urb_079, 26000000).

% ============================================================
% SECTION 6 : DATES D'ACHAT
% ============================================================

date_achat(souleymane_kabore,  p_urb_001, 160).
date_achat(aicha_compaore,     p_urb_002, 165).
date_achat(gaoussou_traore,    p_urb_003, 170).
date_achat(romuald_sawadogo,   p_urb_004, 175).
date_achat(clarisse_ouedraogo, p_urb_005, 180).
date_achat(hamza_diallo,       p_urb_006, 210).
date_achat(roukia_sawadogo,    p_rur_001, 230).
date_achat(ramata_kabore,      p_urb_069, 240).
date_achat(luc_traore,         p_urb_077, 250).
date_achat(mariam_sawadogo,    p_urb_079, 255).
date_achat(idrissa_kabore,     p_urb_033, 100).
date_achat(aziz_compaore,      p_urb_037, 120).
date_achat(kassoum_ouedraogo,  p_urb_065, 200).

date_courante(800).

% ============================================================
% SECTION 7 : LIENS FAMILIAUX
% ============================================================

lien_familial(idrissa_kabore, aziz_compaore).
lien_familial(aziz_compaore, idrissa_kabore).
lien_familial(idrissa_kabore, noel_sawadogo).
lien_familial(noel_sawadogo, idrissa_kabore).
lien_familial(idrissa_kabore, yakubu_ouedraogo).
lien_familial(yakubu_ouedraogo, idrissa_kabore).
lien_familial(aziz_compaore, noel_sawadogo).
lien_familial(noel_sawadogo, aziz_compaore).
lien_familial(kassoum_ouedraogo, paul_sawadogo).   % lien avec agent traitant
lien_familial(paul_sawadogo, kassoum_ouedraogo).
lien_familial(ramata_kabore, ramata_kabore).       % auto-lien (cas particulier)
lien_familial(mariam_sawadogo, paul_sawadogo).
lien_familial(paul_sawadogo, mariam_sawadogo).
lien_familial(luc_traore, adama_compaore).
lien_familial(adama_compaore, luc_traore).
lien_familial(hamza_diallo, paul_sawadogo).
lien_familial(paul_sawadogo, hamza_diallo).
lien_familial(adama_compaore, brice_coulibaly).    % promoteur lié à agent
lien_familial(brice_coulibaly, adama_compaore).

% ============================================================
% SECTION 8 : CONTACTS PARTAGÉS
% ============================================================

% Téléphones partagés — réseau accapareurs Secteur 30 / Tampouy (Ouaga)
partage_telephone(idrissa_kabore, aziz_compaore).
partage_telephone(aziz_compaore, idrissa_kabore).
partage_telephone(idrissa_kabore, noel_sawadogo).
partage_telephone(noel_sawadogo, idrissa_kabore).
partage_telephone(idrissa_kabore, yakubu_ouedraogo).
partage_telephone(yakubu_ouedraogo, idrissa_kabore).
% Réseau fraude Cissin / Zone du Bois (Ouaga)
partage_telephone(kassoum_ouedraogo, ramata_kabore).
partage_telephone(ramata_kabore, kassoum_ouedraogo).
partage_telephone(kassoum_ouedraogo, adama_compaore).
partage_telephone(adama_compaore, kassoum_ouedraogo).
partage_telephone(kassoum_ouedraogo, luc_traore).
partage_telephone(luc_traore, kassoum_ouedraogo).
partage_telephone(kassoum_ouedraogo, mariam_sawadogo).
partage_telephone(mariam_sawadogo, kassoum_ouedraogo).

% Adresses partagées
partage_adresse(idrissa_kabore, aziz_compaore).
partage_adresse(aziz_compaore, idrissa_kabore).
partage_adresse(idrissa_kabore, noel_sawadogo).
partage_adresse(noel_sawadogo, idrissa_kabore).
partage_adresse(idrissa_kabore, yakubu_ouedraogo).
partage_adresse(yakubu_ouedraogo, idrissa_kabore).
partage_adresse(kassoum_ouedraogo, ramata_kabore).
partage_adresse(ramata_kabore, kassoum_ouedraogo).
partage_adresse(kassoum_ouedraogo, adama_compaore).
partage_adresse(adama_compaore, kassoum_ouedraogo).
partage_adresse(kassoum_ouedraogo, luc_traore).
partage_adresse(luc_traore, kassoum_ouedraogo).
partage_adresse(kassoum_ouedraogo, mariam_sawadogo).
partage_adresse(mariam_sawadogo, kassoum_ouedraogo).

% IBAN partagés
partage_iban(aziz_compaore, idrissa_kabore).
partage_iban(idrissa_kabore, aziz_compaore).
partage_iban(noel_sawadogo, idrissa_kabore).
partage_iban(idrissa_kabore, noel_sawadogo).
partage_iban(kassoum_ouedraogo, ramata_kabore).
partage_iban(ramata_kabore, kassoum_ouedraogo).
partage_iban(kassoum_ouedraogo, adama_compaore).
partage_iban(adama_compaore, kassoum_ouedraogo).
partage_iban(kassoum_ouedraogo, luc_traore).
partage_iban(luc_traore, kassoum_ouedraogo).
partage_iban(kassoum_ouedraogo, mariam_sawadogo).
partage_iban(mariam_sawadogo, kassoum_ouedraogo).

% ============================================================
% SECTION 9 : DOSSIERS
% ============================================================

% Agents honnêtes
traite(moussa_konate,  d001). concerne(d001, p_urb_001). beneficiaire(adama_ouedraogo, d001).
traite(paul_sawadogo,  d007). concerne(d007, p_urb_005). beneficiaire(rasmane_zongo, d007).
traite(brice_coulibaly,d013). concerne(d013, p_urb_009). beneficiaire(lassane_traore, d013).

% Conflits d'intérêts — agents
traite(paul_sawadogo,  d031). concerne(d031, p_urb_001). beneficiaire(souleymane_kabore, d031).
traite(paul_sawadogo,  d046). concerne(d046, p_urb_065). beneficiaire(kassoum_ouedraogo, d046).
traite(paul_sawadogo,  d050). concerne(d050, p_urb_079). beneficiaire(mariam_sawadogo, d050).

% Auto-attribution — agents et notaires traitent leurs propres dossiers
traite(ramata_kabore,  d047). concerne(d047, p_urb_069). beneficiaire(ramata_kabore, d047).
traite(luc_traore,     d049). concerne(d049, p_urb_077). beneficiaire(luc_traore, d049).
traite(saidou_kabore,  d042). concerne(d042, p_urb_004). beneficiaire(saidou_kabore, d042).
traite(cheick_traore,  d044). concerne(d044, p_urb_005). beneficiaire(cheick_traore, d044).

% ============================================================
% SECTION 10 : PRÉDICATS AUXILIAIRES
% ============================================================

acteur(X) :- citoyen(X).
acteur(X) :- agent_public(X).
acteur(X) :- promoteur(X).
acteur(X) :- notaire(X).
parcelle(X) :- parcelle_urbaine(X).
parcelle(X) :- parcelle_rurale(X).

% ============================================================
% SECTION 11 : CLAUSES PROBABILISTES
% ============================================================

% ---- CATÉGORIE A : ACCAPAREMENT ----

% Téléphone partagé entre deux propriétaires → forte suspicion prête-nom
0.85::prete_nom(X, Y) :-
    partage_telephone(X, Y), X \= Y,
    possede(X, _), possede(Y, _).

% Adresse partagée + lien familial → prête-nom quasi-certain
0.90::prete_nom_familial(X, Y) :-
    partage_adresse(X, Y), lien_familial(X, Y),
    X \= Y, possede(X, _), possede(Y, _).

% Multipropriété urbaine excessive (>= 4 parcelles)
0.80::accapareur_urbain(X) :-
    citoyen(X),
    possede(X, P1), possede(X, P2), possede(X, P3), possede(X, P4),
    parcelle_urbaine(P1), parcelle_urbaine(P2),
    parcelle_urbaine(P3), parcelle_urbaine(P4),
    P1 \= P2, P1 \= P3, P1 \= P4, P2 \= P3, P2 \= P4, P3 \= P4.

% Réseau familial coordonné entre accapareurs
0.75::reseau_familial(X, Y, Z) :-
    lien_familial(X, Y), lien_familial(Y, Z),
    X \= Y, Y \= Z, X \= Z,
    possede(X, _), possede(Y, _), possede(Z, _).

% ---- CATÉGORIE B : SPÉCULATION ----

% Revente rapide (< 90 jours)
0.70::revente_rapide(X) :-
    vend_a(X, _, _, DateVente),
    date_achat(X, _, DateAchat),
    Delai is DateVente - DateAchat,
    Delai > 0, Delai < 90.

% Plus-value anormale (> 80%)
0.75::plus_value_anormale(X) :-
    prix_achat(X, _, PrixAchat),
    vend_a(X, _, PrixVente, _),
    PrixAchat > 0,
    PlusValue is (PrixVente - PrixAchat) / PrixAchat * 100,
    PlusValue > 80.

% Spéculateur confirmé
0.88::speculateur(X) :- revente_rapide(X), plus_value_anormale(X).

% Spéculation partielle (données prix manquantes)
0.50::speculateur_probable(X) :-
    revente_rapide(X), \+ prix_achat(X, _, _).

% ---- CATÉGORIE C : CONFLITS D'INTÉRÊTS ----

% Agent instruit dossier d'un proche
0.80::conflit_familial(X, Y) :-
    agent_public(X), traite(X, D),
    beneficiaire(Y, D), lien_familial(X, Y), X \= Y.

% Auto-attribution directe (agent/notaire bénéficiaire de son propre dossier)
0.95::auto_attribution(X) :-
    traite(X, D), beneficiaire(X, D).

% Notaire instrumente sa propre parcelle
0.90::notaire_conflit(X) :-
    notaire(X), traite(X, D), concerne(D, P), possede(X, P).

% Favoritisme : même agent, même bénéficiaire, dossiers différents
0.60::favoritisme(X, Y) :-
    agent_public(X),
    traite(X, D1), traite(X, D2),
    beneficiaire(Y, D1), beneficiaire(Y, D2),
    D1 \= D2.

% ---- CATÉGORIE D : RÉSEAUX & BLANCHIMENT ----

% Transactions circulaires A → B → C → A
0.85::reseau_circulaire(X, Y, Z) :-
    vend_a(X, Y, _, _), vend_a(Y, Z, _, _), vend_a(Z, X, _, _),
    X \= Y, Y \= Z, X \= Z.

% IBAN partagé entre deux acteurs
0.65::reseau_financier(X, Y) :-
    partage_iban(X, Y), X \= Y.

% Réseau IBAN en chaîne (3 acteurs)
0.78::reseau_financier_etendu(X, Y, Z) :-
    partage_iban(X, Y), partage_iban(Y, Z),
    X \= Y, Y \= Z, X \= Z.

% Promoteur sans contact traçable (fantôme)
0.70::promoteur_fantome(X) :-
    promoteur(X),
    \+ partage_telephone(X, _),
    \+ partage_adresse(X, _).

% ---- FRAUDES COMPOSITES ----

% Fraude composite : prête-nom + conflit + revente + réseau financier
0.92::fraude_composite(X) :-
    prete_nom(X, _),
    conflit_familial(_, X),
    revente_rapide(X),
    reseau_financier(X, _).

% Fraude hautement sophistiquée : réseau circulaire + prête-nom + conflit
0.95::fraude_sophistiquee(X) :-
    reseau_circulaire(X, _, _),
    prete_nom(X, _),
    auto_attribution(X).

% ---- PROPAGATION MULTI-SIGNAUX ----

0.40::signal_accaparement(X) :- accapareur_urbain(X).
0.30::signal_accaparement(X) :- reseau_familial(X, _, _).
0.50::signal_speculation(X)  :- speculateur(X).
0.25::signal_speculation(X)  :- speculateur_probable(X).
0.60::signal_conflit(X)      :- conflit_familial(_, X).
0.70::signal_conflit(X)      :- auto_attribution(X).
0.55::signal_conflit(X)      :- notaire_conflit(X).
0.45::signal_reseau(X)       :- prete_nom(X, _).
0.50::signal_reseau(X)       :- reseau_circulaire(X, _, _).
0.35::signal_reseau(X)       :- reseau_financier_etendu(X, _, _).

suspicion_globale(X) :- signal_accaparement(X).
suspicion_globale(X) :- signal_speculation(X).
suspicion_globale(X) :- signal_conflit(X).
suspicion_globale(X) :- signal_reseau(X).
