% ============================================================
% LandGuard Neuro-Symbolic AI
% queries.pl — Requêtes d'inférence probabiliste (ProbLog)
% Partie 3 | Contexte : Burkina Faso — 50 dossiers
% ============================================================
%
% Usage CLI  : problog queries.pl
% Usage Python : python3 run_problog.py
%
% 23 requêtes couvrant les 5 catégories de fraude :
%   Q01-Q05 : Prête-nom & Accaparement
%   Q06-Q08 : Spéculation foncière
%   Q09-Q12 : Conflits d'intérêts
%   Q13-Q15 : Réseaux & Blanchiment
%   Q16-Q17 : Fraudes composites
%   Q18-Q23 : Suspicion globale multi-signaux
% ============================================================

:- [probabilistic_rules].

% ============================================================
% BLOC 1 : Prête-Nom & Accaparement (Ouagadougou — Secteur 30 / Tampouy)
% ============================================================

% Q01 — Idrissa Kaboré et Aziz Compaoré partagent téléphone + sont propriétaires
query(prete_nom(idrissa_kabore, aziz_compaore)).

% Q02 — Prête-nom familial entre Idrissa et Aziz (adresse + lien familial)
query(prete_nom_familial(idrissa_kabore, aziz_compaore)).

% Q03 — Prête-nom entre Kassoum Ouédraogo et Mariam Sawadogo (réseau fraude)
query(prete_nom(kassoum_ouedraogo, mariam_sawadogo)).

% Q04 — Accaparement urbain d'Idrissa Kaboré (4 parcelles urb., Secteur 30)
query(accapareur_urbain(idrissa_kabore)).

% Q05 — Réseau familial coordonné : Idrissa / Aziz / Noël Sawadogo
query(reseau_familial(idrissa_kabore, aziz_compaore, noel_sawadogo)).

% ============================================================
% BLOC 2 : Spéculation foncière
% ============================================================

% Q06 — Revente rapide de Romuald Sawadogo (30 jours, Pissy)
query(revente_rapide(romuald_sawadogo)).

% Q07 — Plus-value anormale de Gaoussou Traoré (+133%, Bobo-Dioulasso)
query(plus_value_anormale(gaoussou_traore)).

% Q08 — Spéculateur confirmé : Romuald Sawadogo (rapide + plus-value)
query(speculateur(romuald_sawadogo)).

% ============================================================
% BLOC 3 : Conflits d'intérêts
% ============================================================

% Q09 — Conflit familial : Paul Sawadogo instruit dossier de Kassoum (parent)
query(conflit_familial(paul_sawadogo, kassoum_ouedraogo)).

% Q10 — Conflit familial : Paul Sawadogo / Mariam Sawadogo
query(conflit_familial(paul_sawadogo, mariam_sawadogo)).

% Q11 — Auto-attribution : Ramata Kaboré (agent public, Zone du Bois)
query(auto_attribution(ramata_kabore)).

% Q12 — Auto-attribution : Luc Traoré (notaire, Koulouba)
query(auto_attribution(luc_traore)).

% Q13 — Conflit notaire : Saidou Kaboré instrumente sa propre parcelle
query(notaire_conflit(saidou_kabore)).

% ============================================================
% BLOC 4 : Réseaux & Blanchiment
% ============================================================

% Q14 — Réseau circulaire : Kassoum → Ramata → Adama → Kassoum (blanchiment)
query(reseau_circulaire(kassoum_ouedraogo, ramata_kabore, adama_compaore)).

% Q15 — Réseau IBAN étendu : Kassoum / Ramata / Adama
query(reseau_financier_etendu(kassoum_ouedraogo, ramata_kabore, adama_compaore)).

% Q16 — Promoteur fantôme : Marcelline Traoré (Koulouba, sans contacts tracables)
query(promoteur_fantome(marcelline_traore)).

% ============================================================
% BLOC 5 : Fraudes composites & sophistiquées
% ============================================================

% Q17 — Fraude composite : Kassoum Ouédraogo (cumul 4 signaux forts)
query(fraude_composite(kassoum_ouedraogo)).

% Q18 — Fraude sophistiquée : Kassoum (circulaire + prête-nom + auto-attr.)
query(fraude_sophistiquee(kassoum_ouedraogo)).

% ============================================================
% BLOC 6 : Suspicion globale multi-signaux
% ============================================================

% Q19 — Suspicion globale : Idrissa Kaboré (accaparement + réseau familial)
query(suspicion_globale(idrissa_kabore)).

% Q20 — Suspicion globale : Kassoum Ouédraogo (fraude composite)
query(suspicion_globale(kassoum_ouedraogo)).

% Q21 — Suspicion globale : Ramata Kaboré (auto-attribution + réseau)
query(suspicion_globale(ramata_kabore)).

% Q22 — Suspicion globale : Romuald Sawadogo (spéculation)
query(suspicion_globale(romuald_sawadogo)).

% Q23 — Suspicion globale : Adama Ouédraogo (cas sain — contrôle)
query(suspicion_globale(adama_ouedraogo)).
