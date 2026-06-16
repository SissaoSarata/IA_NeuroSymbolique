% ============================================================
% LandGuard Neuro-Symbolic AI
% deepproblog_model.pl — Intégration Neuro-Symbolique
% Partie 4 : DeepProbLog — Fusion réseau neuronal + logique
% Contexte : Burkina Faso — 50 dossiers fonciers
% ============================================================
%
% Prédicat neuronal central :
%   nn(fraud_model, [X], Y, [standard, atypique, speculateur, fraude])
%
% X est un identifiant d'acteur (atom Prolog).
% Le réseau PyTorch (FraudDetectionNet) calcule la distribution
% de probabilité sur les 4 classes à partir des 12 features.
% DeepProbLog fusionne ces probabilités avec les clauses logiques.
% ============================================================

:- use_module(library(lists)).

% ============================================================
% SECTION 1 : PRÉDICAT NEURONAL (interface PyTorch → ProbLog)
%
% Syntaxe DeepProbLog :
%   nn(NomRéseau, [Entrée], Sortie, [classe0, classe1, ...])
%
% Le réseau 'fraud_model' est enregistré depuis Python via :
%   Network(net, "fraud_model", ["standard","atypique","speculateur","fraude"])
% ============================================================

% Prédicat neuronal principal
% neural_prediction(Acteur, Classe) ← le réseau prédit Classe pour Acteur
neural_prediction(X, Classe) :-
    nn(fraud_model, [X], Classe,
       [standard, atypique, speculateur, fraude]).

% ============================================================
% SECTION 2 : FAITS SYMBOLIQUES DE BASE
% (Repris de knowledge_base_bf.pl pour les acteurs clés)
% ============================================================

% Accapareurs — Secteur 30 / Tampouy (Ouagadougou)
accaparement_urbain_symbolique(idrissa_kabore).
accaparement_urbain_symbolique(aziz_compaore).
accaparement_urbain_symbolique(noel_sawadogo).
accaparement_urbain_symbolique(yakubu_ouedraogo).

% Spéculateurs — reventes rapides avec plus-value
speculation_symbolique(romuald_sawadogo).
speculation_symbolique(gaoussou_traore).
speculation_symbolique(aicha_compaore).
speculation_symbolique(souleymane_kabore).
speculation_symbolique(clarisse_ouedraogo).

% Conflits d'intérêts — agents et notaires
conflit_symbolique(paul_sawadogo).
conflit_symbolique(ramata_kabore).
conflit_symbolique(luc_traore).
conflit_symbolique(saidou_kabore).
conflit_symbolique(cheick_traore).

% Réseaux frauduleux — réseau circulaire Cissin / Zone du Bois
reseau_fraude_symbolique(kassoum_ouedraogo).
reseau_fraude_symbolique(mariam_sawadogo).
reseau_fraude_symbolique(adama_compaore).

% Cas limites — signaux mixtes
cas_limite_symbolique(hamza_diallo).
cas_limite_symbolique(saidou_kabore).
cas_limite_symbolique(flore_compaore).
cas_limite_symbolique(roukia_sawadogo).

% Acteurs standards (citoyens honnêtes)
acteur_standard(adama_ouedraogo). acteur_standard(mariam_kabore).
acteur_standard(salif_traore).    acteur_standard(fatimata_sawadogo).
acteur_standard(issouf_compaore). acteur_standard(rasmane_zongo).

% ============================================================
% SECTION 3 : RÈGLES HYBRIDES NEURO-SYMBOLIQUES
%
% Ces règles combinent la prédiction neuronale avec
% les contraintes logiques symboliques (Prolog).
% La probabilité finale est le produit des deux.
% ============================================================

% REGLE-NS-1 : Fraude avérée
% Condition : réseau prédit "fraude" ET contrainte symbolique d'accaparement
fraude_confirmee(X) :-
    neural_prediction(X, fraude),
    accaparement_urbain_symbolique(X).

% REGLE-NS-2 : Fraude réseau (circulaire)
% Condition : prédiction "fraude" ET appartenance au réseau symbolique
fraude_reseau(X) :-
    neural_prediction(X, fraude),
    reseau_fraude_symbolique(X).

% REGLE-NS-3 : Spéculateur neuro-symbolique
% Condition : réseau prédit "speculateur" ET règle symbolique de spéculation
speculateur_ns(X) :-
    neural_prediction(X, speculateur),
    speculation_symbolique(X).

% REGLE-NS-4 : Accapareur neuro-symbolique
% Condition : réseau prédit "atypique" ET accaparement symbolique détecté
accapareur_ns(X) :-
    neural_prediction(X, atypique),
    accaparement_urbain_symbolique(X).

% REGLE-NS-5 : Conflit d'intérêt renforcé
% Condition : réseau prédit "fraude" ou "atypique" ET conflit symbolique
conflit_renforce(X) :-
    neural_prediction(X, fraude),
    conflit_symbolique(X).

conflit_renforce(X) :-
    neural_prediction(X, atypique),
    conflit_symbolique(X).

% REGLE-NS-6 : Cas limite nécessitant investigation
% Condition : réseau hésite (atypique) ET cas limite symbolique
investigation_requise(X) :-
    neural_prediction(X, atypique),
    cas_limite_symbolique(X).

% REGLE-NS-7 : Profil sain confirmé
% Condition : réseau prédit "standard" ET aucune contrainte symbolique alarmante
profil_sain(X) :-
    neural_prediction(X, standard),
    acteur_standard(X),
    \+ accaparement_urbain_symbolique(X),
    \+ speculation_symbolique(X),
    \+ conflit_symbolique(X),
    \+ reseau_fraude_symbolique(X).

% REGLE-NS-8 : Alerte maximale — fraude composite
% Condition : réseau prédit "fraude" + réseau frauduleux + conflit symbolique
alerte_maximale(X) :-
    neural_prediction(X, fraude),
    reseau_fraude_symbolique(X),
    conflit_symbolique(X).

% ============================================================
% SECTION 4 : DÉCISION FINALE UNIFIÉE
%
% Agrège la prédiction neuronale et la logique symbolique
% en une décision finale avec niveau d'alerte.
% ============================================================

% Niveau CRITIQUE : fraude neuro-symbolique avérée
decision_finale(X, critique) :-
    fraude_confirmee(X).
decision_finale(X, critique) :-
    fraude_reseau(X).
decision_finale(X, critique) :-
    alerte_maximale(X).
decision_finale(X, critique) :-
    conflit_renforce(X).

% Niveau ÉLEVÉ : spéculation ou accaparement confirmé
decision_finale(X, eleve) :-
    speculateur_ns(X),
    \+ decision_finale(X, critique).
decision_finale(X, eleve) :-
    accapareur_ns(X),
    \+ decision_finale(X, critique).

% Niveau MOYEN : cas limite nécessitant investigation
decision_finale(X, moyen) :-
    investigation_requise(X),
    \+ decision_finale(X, critique),
    \+ decision_finale(X, eleve).

% Niveau FAIBLE : profil sain
decision_finale(X, faible) :-
    profil_sain(X),
    \+ decision_finale(X, critique),
    \+ decision_finale(X, eleve),
    \+ decision_finale(X, moyen).

% ============================================================
% SECTION 5 : EXPLICABILITÉ NEURO-SYMBOLIQUE (XAI)
%
% Pour chaque décision, génère une trace expliquant
% quelle part vient du neural vs quelle part vient du symbolique.
% ============================================================

expliquer_decision(X) :-
    neural_prediction(X, ClasseNeural),
    (decision_finale(X, Niveau) -> true ; Niveau = inconnu),
    format("~n[XAI] Acteur       : ~w~n", [X]),
    format("[XAI] Prédiction NN : ~w~n", [ClasseNeural]),
    format("[XAI] Décision fin. : ~w~n", [Niveau]),
    expliquer_signaux_symboliques(X).

expliquer_signaux_symboliques(X) :-
    (accaparement_urbain_symbolique(X) ->
        format("[XAI]   ▸ Signal symbolique : ACCAPAREMENT URBAIN détecté~n", []) ; true),
    (speculation_symbolique(X) ->
        format("[XAI]   ▸ Signal symbolique : SPÉCULATION détectée~n", []) ; true),
    (conflit_symbolique(X) ->
        format("[XAI]   ▸ Signal symbolique : CONFLIT D'INTÉRÊT détecté~n", []) ; true),
    (reseau_fraude_symbolique(X) ->
        format("[XAI]   ▸ Signal symbolique : RÉSEAU FRAUDULEUX détecté~n", []) ; true),
    (cas_limite_symbolique(X) ->
        format("[XAI]   ▸ Signal symbolique : CAS LIMITE — investigation~n", []) ; true),
    (acteur_standard(X) ->
        format("[XAI]   ▸ Signal symbolique : Profil standard confirmé~n", []) ; true).

% ============================================================
% SECTION 6 : REQUÊTES PRÉDÉFINIES
% ============================================================

% Analyser tous les acteurs suspects
analyser_suspects :-
    member(X, [kassoum_ouedraogo, idrissa_kabore, ramata_kabore,
               romuald_sawadogo, luc_traore, mariam_sawadogo,
               adama_compaore, hamza_diallo, adama_ouedraogo]),
    expliquer_decision(X),
    fail ; true.

% Lister toutes les fraudes confirmées
lister_fraudes :-
    write("=== FRAUDES NEURO-SYMBOLIQUES CONFIRMÉES ==="), nl,
    forall(fraude_confirmee(X),
           format("  → ~w : fraude_confirmee~n", [X])),
    forall(fraude_reseau(X),
           format("  → ~w : fraude_reseau~n", [X])),
    forall(alerte_maximale(X),
           format("  → ~w : alerte_maximale~n", [X])).
