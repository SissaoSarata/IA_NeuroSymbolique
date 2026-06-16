% ============================================================
% LandGuard Neuro-Symbolic AI
% inference_engine.pl — Moteur d'inférence principal
% Orchestre l'exécution de toutes les règles sur la KB
% ============================================================
:- encoding(utf8).
:- [knowledge_base].
:- [rules].
:- [explainability].

% ============================================================
% POINT D'ENTRÉE PRINCIPAL
% Appel : ?- analyser_tous_les_acteurs.
% ============================================================

analyser_tous_les_acteurs :-
    write('========================================='), nl,
    write('   LandGuard AI — Analyse en cours...   '), nl,
    write('========================================='), nl, nl,
    findall(X, acteur(X), Acteurs),
    sort(Acteurs, ActeursUniq),
    maplist(analyser_acteur, ActeursUniq),
    nl, write('========================================='), nl,
    write('   Analyse terminée.'), nl,
    write('========================================='), nl.

% Analyse complète d'un acteur individuel
analyser_acteur(X) :-
    format("~n--- Acteur : ~w ---~n", [X]),
    verifier_toutes_regles(X).

% ============================================================
% VÉRIFICATION DE TOUTES LES RÈGLES POUR UN ACTEUR
% ============================================================

verifier_toutes_regles(X) :-
    % Catégorie A : Accaparement
    verifier_regle(accaparement_urbain(X),    'A1'),
    verifier_regle(accaparement_rural(X),     'A2'),
    verifier_regle(multi_propriete_excessive(X), 'A3'),
    verifier_regle(accaparement_familial(X),  'A4'),
    % Catégorie B : Spéculation
    verifier_regle_2args(revente_rapide,       X, 'B1'),
    verifier_regle_2args(plus_value_anormale,  X, 'B2'),
    verifier_regle(speculateur_confirme(X),   'B3'),
    verifier_regle_2args(non_mise_en_valeur,   X, 'B4'),
    % Catégorie C : Conflits d'intérêts
    verifier_regle(auto_attribution(X),       'C1'),
    verifier_conflit_familial(X),
    verifier_favoritisme(X),
    verifier_regle(notaire_conflit(X),        'C4'),
    % Catégorie D : Réseaux
    verifier_prete_nom_tel(X),
    verifier_prete_nom_adr(X),
    verifier_reseau_circ(X),
    verifier_reseau_iban(X),
    % Synthèse
    verifier_regle(fraude_composite(X), 'COMPOSITE').

% ============================================================
% HELPERS D'EXÉCUTION SÉCURISÉE
% ============================================================

% Vérification d'un prédicat à 1 argument (succès ou silence)
verifier_regle(Goal, Code) :-
    (   call(Goal)
    ->  format("  [ALERTE-~w] Violation détectée.~n", [Code])
    ;   true
    ).

% Vérification d'un prédicat à 2 arguments (X + variable libre)
verifier_regle_2args(Pred, X, Code) :-
    Goal =.. [Pred, X, _],
    (   call(Goal)
    ->  format("  [ALERTE-~w] Violation détectée pour ~w.~n", [Code, X])
    ;   true
    ).

verifier_conflit_familial(X) :-
    (   conflit_familial(X, Y)
    ->  format("  [ALERTE-C2] Conflit familial : ~w → ~w.~n", [X, Y])
    ;   true
    ).

verifier_favoritisme(X) :-
    (   favoritisme_repetitif(X, Y)
    ->  format("  [ALERTE-C3] Favoritisme envers ~w.~n", [Y])
    ;   true
    ).

verifier_prete_nom_tel(X) :-
    (   suspect_prete_nom_telephone(X, Y)
    ->  format("  [ALERTE-D1] Prête-nom téléphone avec ~w.~n", [Y])
    ;   true
    ).

verifier_prete_nom_adr(X) :-
    (   suspect_prete_nom_adresse(X, Y)
    ->  format("  [ALERTE-D2] Prête-nom adresse avec ~w.~n", [Y])
    ;   true
    ).

verifier_reseau_circ(X) :-
    (   reseau_circulaire(X, Y, Z)
    ->  format("  [ALERTE-D3] Réseau circulaire : ~w→~w→~w→~w.~n", [X, Y, Z, X])
    ;   true
    ).

verifier_reseau_iban(X) :-
    (   reseau_iban_partage(X, Y, Z)
    ->  format("  [ALERTE-D4] Réseau IBAN : ~w, ~w, ~w.~n", [X, Y, Z])
    ;   true
    ).

% ============================================================
% REQUÊTES PRÉDÉFINIES UTILES
% ============================================================

% Tous les accapareurs urbains
:- meta_predicate lister_accapareurs_urbains.
lister_accapareurs_urbains :-
    write('=== Accapareurs urbains ==='), nl,
    forall(
        (citoyen(X), accaparement_urbain(X)),
        format("  -> ~w~n", [X])
    ).

% Tous les suspects de prête-nom
lister_prete_noms :-
    write('=== Suspects prête-nom (téléphone) ==='), nl,
    forall(
        suspect_prete_nom_telephone(X, Y),
        format("  -> ~w <--> ~w~n", [X, Y])
    ).

% Tous les conflits d'intérêts
lister_conflits :-
    write('=== Conflits d intérêts ==='), nl,
    forall(
        (auto_attribution(X) ; conflit_familial(X, _) ; notaire_conflit(X)),
        format("  -> ~w~n", [X])
    ).

% Score de risque synthétique par acteur
score_risque(X, Score) :-
    acteur(X),
    (accaparement_urbain(X)          -> S1 = 2 ; S1 = 0),
    (accaparement_familial(X)        -> S2 = 2 ; S2 = 0),
    (speculateur_confirme(X)         -> S3 = 3 ; S3 = 0),
    (auto_attribution(X)             -> S4 = 4 ; S4 = 0),
    (conflit_familial(X, _)          -> S5 = 3 ; S5 = 0),
    (suspect_prete_nom_telephone(X,_)-> S6 = 2 ; S6 = 0),
    (reseau_circulaire(X, _, _)      -> S7 = 4 ; S7 = 0),
    (fraude_composite(X)             -> S8 = 5 ; S8 = 0),
    Score is S1 + S2 + S3 + S4 + S5 + S6 + S7 + S8.

niveau_risque(X, 'CRITIQUE') :- score_risque(X, S), S >= 8.
niveau_risque(X, 'ÉLEVÉ')    :- score_risque(X, S), S >= 5, S < 8.
niveau_risque(X, 'MOYEN')    :- score_risque(X, S), S >= 2, S < 5.
niveau_risque(X, 'FAIBLE')   :- score_risque(X, S), S < 2.

rapport_risques :-
    write('=== RAPPORT DE RISQUES GLOBAL ==='), nl,
    findall(X, acteur(X), As), sort(As, Acteurs),
    forall(
        member(A, Acteurs),
        (
            score_risque(A, S), S > 0,
            niveau_risque(A, N),
            format("  ~w : score=~w, niveau=~w~n", [A, S, N])
        )
    ).
