% ============================================================
% LandGuard Neuro-Symbolic AI
% explainability.pl — Module XAI (Explainable AI)
% Journalisation structurée de chaque inférence déclenchée
% ============================================================
:- encoding(utf8).
:- dynamic alerte_log/4.   % alerte_log(RegleID, Acteur, Vars, Motif)
:- dynamic trace_log/3.    % trace_log(Timestamp, Acteur, Message)

% ============================================================
% PRÉDICAT DE JOURNALISATION CENTRAL
% Appelé dans chaque règle de rules.pl
% log_alerte(+RegleID, +Acteur, +Variables, +Motif)
% ============================================================

log_alerte(RegleID, Acteur, Vars, Motif) :-
    get_time(TS),
    assertz(alerte_log(RegleID, Acteur, Vars, Motif)),
    assertz(trace_log(TS, Acteur, Motif)),
    format("[LOG] ~w | ~w | ~w | ~w~n", [RegleID, Acteur, Vars, Motif]).

% ============================================================
% GÉNÉRATION D'EXPLICATION TEXTUELLE PAR ACTEUR
% ============================================================

expliquer(X) :-
    format("~n╔══════════════════════════════════════════╗~n"),
    format("║  RAPPORT D'EXPLICATION — Acteur : ~w~n", [X]),
    format("╚══════════════════════════════════════════╝~n"),
    findall(
        alerte(R, V, M),
        alerte_log(R, X, V, M),
        Alertes
    ),
    (   Alertes = []
    ->  format("  ✓ Aucune violation détectée. Profil standard.~n")
    ;   length(Alertes, N),
        format("  ⚠ ~w violation(s) détectée(s) :~n~n", [N]),
        maplist(afficher_alerte, Alertes)
    ),
    nl.

afficher_alerte(alerte(RegleID, Vars, Motif)) :-
    format("  ▸ [~w]~n", [RegleID]),
    format("    Justification : ~w~n", [Motif]),
    format("    Variables     : ~w~n~n", [Vars]).

% ============================================================
% EXTRACTION DU CHEMIN D'INFÉRENCE LOGIQUE
% Retrace les règles activées dans l'ordre chronologique
% ============================================================

chemin_inference(X) :-
    format("~n=== Chemin d'inférence pour : ~w ===~n", [X]),
    findall(R-M, alerte_log(R, X, _, M), Etapes),
    (   Etapes = []
    ->  write("  Aucun chemin d'inférence (aucune règle déclenchée).")
    ;   forall(
            member(R-M, Etapes),
            format("  ~w → ~w~n", [R, M])
        )
    ), nl.

% ============================================================
% RAPPORT GLOBAL DE TOUTES LES ALERTES
% ============================================================

rapport_alertes_global :-
    write('╔═══════════════════════════════════════════════╗'), nl,
    write('║   RAPPORT GLOBAL DES ALERTES — LandGuard AI  ║'), nl,
    write('╚═══════════════════════════════════════════════╝'), nl, nl,
    findall(R-A-M, alerte_log(R, A, _, M), Toutes),
    (   Toutes = []
    ->  write('  Aucune alerte enregistrée.')
    ;   length(Toutes, N),
        format("  Total : ~w alerte(s)~n~n", [N]),
        forall(
            member(R-A-M, Toutes),
            format("  [~w] ~w : ~w~n", [R, A, M])
        )
    ), nl.

% ============================================================
% EXPORT DES ALERTES EN FORMAT CSV (pour rapport Python)
% ============================================================

exporter_alertes_csv(Fichier) :-
    open(Fichier, write, Stream),
    write(Stream, 'regle_id,acteur,variables,motif\n'),
    forall(
        alerte_log(R, A, V, M),
        (
            term_to_atom(V, VAtom),
            format(Stream, '~w,~w,~w,~w\n', [R, A, VAtom, M])
        )
    ),
    close(Stream),
    format("Export CSV réalisé : ~w~n", [Fichier]).

% ============================================================
% NETTOYAGE DES LOGS (réinitialisation)
% ============================================================

vider_logs :-
    retractall(alerte_log(_, _, _, _)),
    retractall(trace_log(_, _, _)),
    write('Logs effacés.'), nl.

% ============================================================
% EXPLICATION EN LANGAGE NATUREL (simplifié)
% Génère un texte lisible par un juriste ou agent administratif
% ============================================================

explication_juridique(X) :-
    format("~n=== AVIS JURIDIQUE AUTOMATIQUE — ~w ===~n~n", [X]),
    findall(R-M, alerte_log(R, X, _, M), Alertes),
    (   Alertes = []
    ->  format("L'acteur ~w ne présente aucun indicateur de fraude selon les règles en vigueur.~n", [X])
    ;   format("L'acteur ~w fait l'objet de ~w signalement(s) automatique(s) :~n~n", [X, _]),
        forall(
            member(R-M, Alertes),
            format("  • En vertu de la règle ~w : ~w~n", [R, M])
        ),
        nl,
        write("  → Il est recommandé d'ouvrir une procédure d'instruction approfondie."), nl,
        write("  → Ces éléments constituent des présomptions, non des preuves définitives."), nl
    ), nl.
