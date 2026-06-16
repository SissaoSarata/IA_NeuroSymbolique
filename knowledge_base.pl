% ============================================================
% LandGuard Neuro-Symbolic AI
% knowledge_base.pl — Base de faits fonciers
% Jeu de données : 50 dossiers — Contexte Burkina Faso
% Généré automatiquement depuis dataset.csv
% ============================================================
:- encoding(utf8).
:- discontiguous citoyen/1, agent_public/1, promoteur/1, notaire/1.
:- discontiguous parcelle_urbaine/1, parcelle_rurale/1.
:- discontiguous possede/2, traite/2, beneficiaire/2.
:- discontiguous lien_familial/2, vend_a/4, partage_telephone/2.
:- discontiguous partage_adresse/2, partage_iban/2.
:- discontiguous concerne/2, prix_achat/3, date_achat/3.

% ============================================================
% SECTION 1 : ACTEURS (50 dossiers + agents traitants)
% ============================================================

% --- CITOYEN ---
citoyen(adama_ouedraogo). % Adama Ouédraogo | Ouagadougou / Pissy [STANDARD]
citoyen(mariam_kabore). % Mariam Kaboré | Ouagadougou / Gounghin [STANDARD]
citoyen(salif_traore). % Salif Traoré | Bobo-Dioulasso / Secteur 22 [STANDARD]
citoyen(fatimata_sawadogo). % Fatimata Sawadogo | Koudougou / Centre [STANDARD]
citoyen(issouf_compaore). % Issouf Compaoré | Ouagadougou / Dapoya [STANDARD]
citoyen(aminata_diallo). % Aminata Diallo | Fada N'Gourma / Centre [STANDARD]
citoyen(rasmane_zongo). % Rasmané Zongo | Ouagadougou / Tampouy [STANDARD]
citoyen(bintou_nikiema). % Bintou Nikiema | Ouagadougou / Wemtenga [STANDARD]
citoyen(dramane_ouedraogo). % Dramane Ouédraogo | Banfora / Centre [STANDARD]
citoyen(safi_kabore). % Safi Kaboré | Ouagadougou / Balkuy [STANDARD]
citoyen(wendyam_compaore). % Wendyam Compaoré | Ouagadougou / Cissin [STANDARD]
citoyen(hawa_sawadogo). % Hawa Sawadogo | Tenkodogo / Centre [STANDARD]
citoyen(lassane_traore). % Lassané Traoré | Ouagadougou / Niogsin [STANDARD]
citoyen(roukiata_zongo). % Roukiata Zongo | Dédougou / Centre [STANDARD]
citoyen(moussa_ouedraogo). % Moussa Ouédraogo | Ouagadougou / Zone du Bois [STANDARD]
citoyen(aissata_kabore). % Aïssata Kaboré | Bobo-Dioulasso / Secteur 15 [STANDARD]
citoyen(karim_compaore). % Karim Compaoré | Ouagadougou / Paspanga [STANDARD]
citoyen(oumou_diallo). % Oumou Diallo | Koupèla / Centre [STANDARD]
citoyen(youssouf_nikiema). % Youssouf Nikiema | Ouagadougou / Gounghin [STANDARD]
citoyen(kadiatou_traore). % Kadiatou Traoré | Ouagadougou / Secteur 30 [STANDARD]
citoyen(noufou_sawadogo). % Noufou Sawadogo | Ouagadougou / Pissy [STANDARD]
citoyen(bibata_compaore). % Bibata Compaoré | Manga / Centre [STANDARD]
citoyen(inoussa_kabore). % Inoussa Kaboré | Ouagadougou / Koulouba [STANDARD]
citoyen(pelagie_ouedraogo). % Pélagie Ouédraogo | Réo / Centre [STANDARD]
citoyen(seydou_zongo). % Seydou Zongo | Ouagadougou / Wemtenga [STANDARD]
citoyen(issa_compaore). % Issa Compaoré | Ouagadougou / Tampouy [STANDARD]
citoyen(fatoumata_nikiema). % Fatoumata Nikiema | Ouagadougou / Dapoya [STANDARD]
citoyen(bassirou_traore). % Bassirou Traoré | Bobo-Dioulasso / Secteur 8 [STANDARD]
citoyen(marietou_sawadogo). % Mariétou Sawadogo | Ouagadougou / Balkuy [STANDARD]
citoyen(hamidou_diallo). % Hamidou Diallo | Ouagadougou / Niogsin [STANDARD]
citoyen(souleymane_kabore). % Souleymane Kaboré | Ouagadougou / Cissin [SPECULATEUR]
citoyen(aicha_compaore). % Aicha Compaoré | Ouagadougou / Zone du Bois [SPECULATEUR]
citoyen(gaoussou_traore). % Gaoussou Traoré | Bobo-Dioulasso / Secteur 25 [SPECULATEUR]
citoyen(romuald_sawadogo). % Romuald Sawadogo | Ouagadougou / Pissy [SPECULATEUR]
citoyen(clarisse_ouedraogo). % Clarisse Ouédraogo | Ouagadougou / Paspanga [SPECULATEUR]
citoyen(idrissa_kabore). % Idrissa Kaboré | Ouagadougou / Secteur 30 [ACCAPAREUR]
citoyen(aziz_compaore). % Aziz Compaoré | Ouagadougou / Tampouy [ACCAPAREUR]
citoyen(noel_sawadogo). % Noël Sawadogo | Bobo-Dioulasso / Secteur 10 [ACCAPAREUR]
citoyen(yakubu_ouedraogo). % Yakubu Ouédraogo | Ouagadougou / Gounghin [ACCAPAREUR]
citoyen(hamza_diallo). % Hamza Diallo | Ouagadougou / Dapoya [LIMITE]
citoyen(flore_compaore). % Flore Compaoré | Koudougou / Centre [LIMITE]
citoyen(roukia_sawadogo). % Roukia Sawadogo | Ouagadougou / Tampouy [LIMITE]
citoyen(kassoum_ouedraogo). % Kassoum Ouédraogo | Ouagadougou / Cissin [FRAUDE]
citoyen(mariam_sawadogo). % Mariam Sawadogo | Ouagadougou / Gounghin [FRAUDE]
citoyen(sarata_sissao). % Sarata Sissao | Ouagadougou / Tampouy [FRAUDE]
possede(sarata_sissao, p_urb_999).
possede(sarata_sissao, p_urb_998).
possede(sarata_sissao, p_urb_997).
possede(sarata_sissao, p_urb_996).     % 4 parcelles urbaines → AX-01
parcelle_urbaine(p_urb_996). parcelle_urbaine(p_urb_997).
parcelle_urbaine(p_urb_998). parcelle_urbaine(p_urb_999).
partage_telephone(sarata_sissao, kassoum_ouedraogo).  % CI-5
% --- AGENT_PUBLIC ---
agent_public(saidou_kabore). % Saidou Kaboré | Ouagadougou / Wemtenga [LIMITE]
agent_public(ramata_kabore). % Ramata Kaboré | Ouagadougou / Zone du Bois [FRAUDE]
agent_public(moussa_konate). % Konaté Moussa
agent_public(paul_sawadogo). % Sawadogo Paul
agent_public(brice_coulibaly). % Coulibaly Brice
agent_public(ines_zongo). % Zongo Inès
agent_public(henri_tapsoba). % Tapsoba Henri

% --- PROMOTEUR ---
promoteur(marcelline_traore). % Marcelline Traoré | Ouagadougou / Koulouba [ACCAPAREUR]
promoteur(adama_compaore). % Adama Compaoré | Bobo-Dioulasso / Secteur 20 [FRAUDE]

% --- NOTAIRE ---
notaire(cheick_traore). % Cheick Traoré | Ouagadougou / Pissy [LIMITE]
notaire(luc_traore). % Luc Traoré | Ouagadougou / Koulouba [FRAUDE]

% ============================================================
% SECTION 2 : PARCELLES
% ============================================================

% Parcelles urbaines
parcelle_urbaine(p_urb_001).
parcelle_urbaine(p_urb_002).
parcelle_urbaine(p_urb_003).
parcelle_urbaine(p_urb_004).
parcelle_urbaine(p_urb_005).
parcelle_urbaine(p_urb_006).
parcelle_urbaine(p_urb_007).
parcelle_urbaine(p_urb_008).
parcelle_urbaine(p_urb_009).
parcelle_urbaine(p_urb_010).
parcelle_urbaine(p_urb_011).
parcelle_urbaine(p_urb_012).
parcelle_urbaine(p_urb_013).
parcelle_urbaine(p_urb_014).
parcelle_urbaine(p_urb_015).
parcelle_urbaine(p_urb_016).
parcelle_urbaine(p_urb_017).
parcelle_urbaine(p_urb_018).
parcelle_urbaine(p_urb_019).
parcelle_urbaine(p_urb_020).
parcelle_urbaine(p_urb_021).
parcelle_urbaine(p_urb_022).
parcelle_urbaine(p_urb_023).
parcelle_urbaine(p_urb_024).
parcelle_urbaine(p_urb_025).
parcelle_urbaine(p_urb_026).
parcelle_urbaine(p_urb_027).
parcelle_urbaine(p_urb_028).
parcelle_urbaine(p_urb_029).
parcelle_urbaine(p_urb_030).
parcelle_urbaine(p_urb_031).
parcelle_urbaine(p_urb_032).
parcelle_urbaine(p_urb_033).
parcelle_urbaine(p_urb_034).
parcelle_urbaine(p_urb_035).
parcelle_urbaine(p_urb_036).
parcelle_urbaine(p_urb_037).
parcelle_urbaine(p_urb_038).
parcelle_urbaine(p_urb_039).
parcelle_urbaine(p_urb_040).
parcelle_urbaine(p_urb_041).
parcelle_urbaine(p_urb_042).
parcelle_urbaine(p_urb_043).
parcelle_urbaine(p_urb_044).
parcelle_urbaine(p_urb_045).
parcelle_urbaine(p_urb_046).
parcelle_urbaine(p_urb_047).
parcelle_urbaine(p_urb_048).
parcelle_urbaine(p_urb_049).
parcelle_urbaine(p_urb_050).
parcelle_urbaine(p_urb_051).
parcelle_urbaine(p_urb_052).
parcelle_urbaine(p_urb_053).
parcelle_urbaine(p_urb_054).
parcelle_urbaine(p_urb_055).
parcelle_urbaine(p_urb_056).
parcelle_urbaine(p_urb_057).
parcelle_urbaine(p_urb_058).
parcelle_urbaine(p_urb_059).
parcelle_urbaine(p_urb_060).
parcelle_urbaine(p_urb_061).
parcelle_urbaine(p_urb_062).
parcelle_urbaine(p_urb_063).
parcelle_urbaine(p_urb_064).
parcelle_urbaine(p_urb_065).
parcelle_urbaine(p_urb_066).
parcelle_urbaine(p_urb_067).
parcelle_urbaine(p_urb_068).
parcelle_urbaine(p_urb_069).
parcelle_urbaine(p_urb_070).
parcelle_urbaine(p_urb_071).
parcelle_urbaine(p_urb_072).
parcelle_urbaine(p_urb_073).
parcelle_urbaine(p_urb_074).
parcelle_urbaine(p_urb_075).
parcelle_urbaine(p_urb_076).
parcelle_urbaine(p_urb_077).
parcelle_urbaine(p_urb_078).
parcelle_urbaine(p_urb_079).
parcelle_urbaine(p_urb_080).
parcelle_urbaine(p_urb_081).
parcelle_urbaine(p_urb_082).

% Parcelles rurales
parcelle_rurale(p_rur_001).
parcelle_rurale(p_rur_002).
parcelle_rurale(p_rur_003).
parcelle_rurale(p_rur_004).
parcelle_rurale(p_rur_005).
parcelle_rurale(p_rur_006).
parcelle_rurale(p_rur_007).
parcelle_rurale(p_rur_008).
parcelle_rurale(p_rur_009).
parcelle_rurale(p_rur_010).
parcelle_rurale(p_rur_011).
parcelle_rurale(p_rur_012).
parcelle_rurale(p_rur_013).
parcelle_rurale(p_rur_014).
parcelle_rurale(p_rur_015).
parcelle_rurale(p_rur_016).
parcelle_rurale(p_rur_017).
parcelle_rurale(p_rur_018).
parcelle_rurale(p_rur_019).
parcelle_rurale(p_rur_020).
parcelle_rurale(p_rur_021).
parcelle_rurale(p_rur_022).
parcelle_rurale(p_rur_023).
parcelle_rurale(p_rur_024).
parcelle_rurale(p_rur_025).
parcelle_rurale(p_rur_026).
parcelle_rurale(p_rur_027).
parcelle_rurale(p_rur_028).
parcelle_rurale(p_rur_029).
parcelle_rurale(p_rur_030).
parcelle_rurale(p_rur_031).
parcelle_rurale(p_rur_032).
parcelle_rurale(p_rur_033).
parcelle_rurale(p_rur_034).
parcelle_rurale(p_rur_035).
parcelle_rurale(p_rur_036).
parcelle_rurale(p_rur_037).
parcelle_rurale(p_rur_038).
parcelle_rurale(p_rur_039).
parcelle_rurale(p_rur_040).
parcelle_rurale(p_rur_041).

% ============================================================
% SECTION 3 : PROPRIÉTÉS (possede/2)
% ============================================================

% Adama Ouédraogo (Ouagadougou) [STANDARD]
possede(adama_ouedraogo, p_urb_001).

% Mariam Kaboré (Ouagadougou) [STANDARD]
possede(mariam_kabore, p_rur_001).

% Salif Traoré (Bobo-Dioulasso) [STANDARD]
possede(salif_traore, p_urb_002).
possede(salif_traore, p_rur_002).

% Fatimata Sawadogo (Koudougou) [STANDARD]
possede(fatimata_sawadogo, p_rur_003).
possede(fatimata_sawadogo, p_rur_004).

% Issouf Compaoré (Ouagadougou) [STANDARD]
possede(issouf_compaore, p_urb_003).
possede(issouf_compaore, p_urb_004).

% Aminata Diallo (Fada N'Gourma) [STANDARD]
possede(aminata_diallo, p_rur_005).

% Rasmané Zongo (Ouagadougou) [STANDARD]
possede(rasmane_zongo, p_urb_005).

% Bintou Nikiema (Ouagadougou) [STANDARD]
possede(bintou_nikiema, p_rur_006).
possede(bintou_nikiema, p_rur_007).

% Dramane Ouédraogo (Banfora) [STANDARD]
possede(dramane_ouedraogo, p_urb_006).

% Safi Kaboré (Ouagadougou) [STANDARD]
possede(safi_kabore, p_rur_008).

% Wendyam Compaoré (Ouagadougou) [STANDARD]
possede(wendyam_compaore, p_urb_007).
possede(wendyam_compaore, p_urb_008).
possede(wendyam_compaore, p_rur_009).

% Hawa Sawadogo (Tenkodogo) [STANDARD]
possede(hawa_sawadogo, p_rur_010).
possede(hawa_sawadogo, p_rur_011).

% Lassané Traoré (Ouagadougou) [STANDARD]
possede(lassane_traore, p_urb_009).

% Roukiata Zongo (Dédougou) [STANDARD]
possede(roukiata_zongo, p_rur_012).

% Moussa Ouédraogo (Ouagadougou) [STANDARD]
possede(moussa_ouedraogo, p_urb_010).

% Aïssata Kaboré (Bobo-Dioulasso) [STANDARD]
possede(aissata_kabore, p_urb_011).
possede(aissata_kabore, p_urb_012).

% Karim Compaoré (Ouagadougou) [STANDARD]
possede(karim_compaore, p_rur_013).

% Oumou Diallo (Koupèla) [STANDARD]
possede(oumou_diallo, p_rur_014).
possede(oumou_diallo, p_rur_015).

% Youssouf Nikiema (Ouagadougou) [STANDARD]
possede(youssouf_nikiema, p_urb_013).

% Kadiatou Traoré (Ouagadougou) [STANDARD]
possede(kadiatou_traore, p_urb_014).
possede(kadiatou_traore, p_rur_016).

% Noufou Sawadogo (Ouagadougou) [STANDARD]
possede(noufou_sawadogo, p_urb_015).
possede(noufou_sawadogo, p_urb_016).

% Bibata Compaoré (Manga) [STANDARD]
possede(bibata_compaore, p_rur_017).

% Inoussa Kaboré (Ouagadougou) [STANDARD]
possede(inoussa_kabore, p_urb_017).
possede(inoussa_kabore, p_urb_018).
possede(inoussa_kabore, p_rur_018).

% Pélagie Ouédraogo (Réo) [STANDARD]
possede(pelagie_ouedraogo, p_rur_019).
possede(pelagie_ouedraogo, p_rur_020).

% Seydou Zongo (Ouagadougou) [STANDARD]
possede(seydou_zongo, p_urb_019).

% Issa Compaoré (Ouagadougou) [STANDARD]
possede(issa_compaore, p_urb_020).

% Fatoumata Nikiema (Ouagadougou) [STANDARD]
possede(fatoumata_nikiema, p_urb_021).
possede(fatoumata_nikiema, p_urb_022).

% Bassirou Traoré (Bobo-Dioulasso) [STANDARD]
possede(bassirou_traore, p_rur_021).

% Mariétou Sawadogo (Ouagadougou) [STANDARD]
possede(marietou_sawadogo, p_urb_023).

% Hamidou Diallo (Ouagadougou) [STANDARD]
possede(hamidou_diallo, p_rur_022).

% Souleymane Kaboré (Ouagadougou) [SPECULATEUR]
possede(souleymane_kabore, p_urb_024).
possede(souleymane_kabore, p_urb_025).

% Aicha Compaoré (Ouagadougou) [SPECULATEUR]
possede(aicha_compaore, p_urb_026).

% Gaoussou Traoré (Bobo-Dioulasso) [SPECULATEUR]
possede(gaoussou_traore, p_urb_027).
possede(gaoussou_traore, p_urb_028).
possede(gaoussou_traore, p_urb_029).

% Romuald Sawadogo (Ouagadougou) [SPECULATEUR]
possede(romuald_sawadogo, p_urb_030).
possede(romuald_sawadogo, p_urb_031).
possede(romuald_sawadogo, p_rur_023).

% Clarisse Ouédraogo (Ouagadougou) [SPECULATEUR]
possede(clarisse_ouedraogo, p_urb_032).

% Idrissa Kaboré (Ouagadougou) [ACCAPAREUR]
possede(idrissa_kabore, p_urb_033).
possede(idrissa_kabore, p_urb_034).
possede(idrissa_kabore, p_urb_035).
possede(idrissa_kabore, p_urb_036).

% Aziz Compaoré (Ouagadougou) [ACCAPAREUR]
possede(aziz_compaore, p_urb_037).
possede(aziz_compaore, p_urb_038).
possede(aziz_compaore, p_urb_039).
possede(aziz_compaore, p_urb_040).
possede(aziz_compaore, p_urb_041).
possede(aziz_compaore, p_rur_024).

% Marcelline Traoré (Ouagadougou) [ACCAPAREUR]
possede(marcelline_traore, p_urb_042).
possede(marcelline_traore, p_urb_043).
possede(marcelline_traore, p_urb_044).
possede(marcelline_traore, p_urb_045).
possede(marcelline_traore, p_urb_046).
possede(marcelline_traore, p_urb_047).

% Noël Sawadogo (Bobo-Dioulasso) [ACCAPAREUR]
possede(noel_sawadogo, p_urb_048).
possede(noel_sawadogo, p_urb_049).
possede(noel_sawadogo, p_urb_050).
possede(noel_sawadogo, p_urb_051).
possede(noel_sawadogo, p_rur_025).
possede(noel_sawadogo, p_rur_026).

% Yakubu Ouédraogo (Ouagadougou) [ACCAPAREUR]
possede(yakubu_ouedraogo, p_urb_052).
possede(yakubu_ouedraogo, p_urb_053).
possede(yakubu_ouedraogo, p_urb_054).
possede(yakubu_ouedraogo, p_rur_027).
possede(yakubu_ouedraogo, p_rur_028).
possede(yakubu_ouedraogo, p_rur_029).

% Hamza Diallo (Ouagadougou) [LIMITE]
possede(hamza_diallo, p_urb_055).
possede(hamza_diallo, p_urb_056).

% Saidou Kaboré (Ouagadougou) [LIMITE]
possede(saidou_kabore, p_urb_057).
possede(saidou_kabore, p_urb_058).
possede(saidou_kabore, p_rur_030).

% Flore Compaoré (Koudougou) [LIMITE]
possede(flore_compaore, p_urb_059).
possede(flore_compaore, p_rur_031).
possede(flore_compaore, p_rur_032).

% Cheick Traoré (Ouagadougou) [LIMITE]
possede(cheick_traore, p_urb_060).
possede(cheick_traore, p_urb_061).
possede(cheick_traore, p_urb_062).

% Roukia Sawadogo (Ouagadougou) [LIMITE]
possede(roukia_sawadogo, p_urb_063).
possede(roukia_sawadogo, p_urb_064).
possede(roukia_sawadogo, p_rur_033).

% Kassoum Ouédraogo (Ouagadougou) [FRAUDE]
possede(kassoum_ouedraogo, p_urb_065).
possede(kassoum_ouedraogo, p_urb_066).
possede(kassoum_ouedraogo, p_urb_067).
possede(kassoum_ouedraogo, p_urb_068).
possede(kassoum_ouedraogo, p_rur_034).
possede(kassoum_ouedraogo, p_rur_035).

% Ramata Kaboré (Ouagadougou) [FRAUDE]
possede(ramata_kabore, p_urb_069).
possede(ramata_kabore, p_urb_070).
possede(ramata_kabore, p_urb_071).

% Adama Compaoré (Bobo-Dioulasso) [FRAUDE]
possede(adama_compaore, p_urb_072).
possede(adama_compaore, p_urb_073).
possede(adama_compaore, p_urb_074).
possede(adama_compaore, p_urb_075).
possede(adama_compaore, p_urb_076).
possede(adama_compaore, p_rur_036).
possede(adama_compaore, p_rur_037).
possede(adama_compaore, p_rur_038).

% Luc Traoré (Ouagadougou) [FRAUDE]
possede(luc_traore, p_urb_077).
possede(luc_traore, p_urb_078).
possede(luc_traore, p_rur_039).

% Mariam Sawadogo (Ouagadougou) [FRAUDE]
possede(mariam_sawadogo, p_urb_079).
possede(mariam_sawadogo, p_urb_080).
possede(mariam_sawadogo, p_urb_081).
possede(mariam_sawadogo, p_urb_082).
possede(mariam_sawadogo, p_rur_040).
possede(mariam_sawadogo, p_rur_041).

% ============================================================
% SECTION 4 : TRANSACTIONS vend_a(Vendeur, Acheteur, Prix, Jour)
% ============================================================

vend_a(souleymane_kabore, acheteur_d031, 9500000, 185). % Souleymane Kaboré D031
vend_a(aicha_compaore, acheteur_d032, 14500000, 210). % Aicha Compaoré D032
vend_a(gaoussou_traore, acheteur_d033, 35000000, 230). % Gaoussou Traoré D033
vend_a(romuald_sawadogo, acheteur_d034, 28500000, 205). % Romuald Sawadogo D034
vend_a(clarisse_ouedraogo, acheteur_d035, 11200000, 235). % Clarisse Ouédraogo D035
vend_a(hamza_diallo, acheteur_d041, 14000000, 250). % Hamza Diallo D041
vend_a(flore_compaore, acheteur_d043, 13000000, 305). % Flore Compaoré D043
vend_a(roukia_sawadogo, acheteur_d045, 19500000, 300). % Roukia Sawadogo D045
vend_a(ramata_kabore, acheteur_d047, 32000000, 275). % Ramata Kaboré D047
vend_a(luc_traore, acheteur_d049, 29000000, 278). % Luc Traoré D049
vend_a(mariam_sawadogo, acheteur_d050, 55000000, 275). % Mariam Sawadogo D050
vend_a(kassoum_ouedraogo, ramata_kabore, 22000000, 280).     % réseau circulaire fraude
vend_a(ramata_kabore, adama_compaore, 23000000, 290). % réseau circulaire fraude
vend_a(adama_compaore, kassoum_ouedraogo, 21500000, 300). % réseau circulaire fraude

% ============================================================
% SECTION 5 : PRIX D'ACHAT prix_achat(Acteur, Parcelle, Prix)
% ============================================================

prix_achat(adama_ouedraogo, p_urb_001, 4500000).
prix_achat(mariam_kabore, p_rur_001, 1200000).
prix_achat(salif_traore, p_urb_002, 6000000).
prix_achat(fatimata_sawadogo, p_rur_003, 2400000).
prix_achat(issouf_compaore, p_urb_003, 9000000).
prix_achat(aminata_diallo, p_rur_005, 800000).
prix_achat(rasmane_zongo, p_urb_005, 5500000).
prix_achat(bintou_nikiema, p_rur_006, 1800000).
prix_achat(dramane_ouedraogo, p_urb_006, 3200000).
prix_achat(safi_kabore, p_rur_008, 1100000).
prix_achat(wendyam_compaore, p_urb_007, 11000000).
prix_achat(hawa_sawadogo, p_rur_010, 2100000).
prix_achat(lassane_traore, p_urb_009, 4800000).
prix_achat(roukiata_zongo, p_rur_012, 950000).
prix_achat(moussa_ouedraogo, p_urb_010, 6200000).
prix_achat(aissata_kabore, p_urb_011, 13000000).
prix_achat(karim_compaore, p_rur_013, 1400000).
prix_achat(oumou_diallo, p_rur_014, 1900000).
prix_achat(youssouf_nikiema, p_urb_013, 5100000).
prix_achat(kadiatou_traore, p_urb_014, 7500000).
prix_achat(noufou_sawadogo, p_urb_015, 9500000).
prix_achat(bibata_compaore, p_rur_017, 700000).
prix_achat(inoussa_kabore, p_urb_017, 14000000).
prix_achat(pelagie_ouedraogo, p_rur_019, 2200000).
prix_achat(seydou_zongo, p_urb_019, 4700000).
prix_achat(issa_compaore, p_urb_020, 5000000).
prix_achat(fatoumata_nikiema, p_urb_021, 10500000).
prix_achat(bassirou_traore, p_rur_021, 1050000).
prix_achat(marietou_sawadogo, p_urb_023, 5300000).
prix_achat(hamidou_diallo, p_rur_022, 1300000).
prix_achat(souleymane_kabore, p_urb_024, 8500000).
prix_achat(aicha_compaore, p_urb_026, 6000000).
prix_achat(gaoussou_traore, p_urb_027, 15000000).
prix_achat(romuald_sawadogo, p_urb_030, 12000000).
prix_achat(clarisse_ouedraogo, p_urb_032, 4500000).
prix_achat(idrissa_kabore, p_urb_033, 18000000).
prix_achat(aziz_compaore, p_urb_037, 25000000).
prix_achat(marcelline_traore, p_urb_042, 30000000).
prix_achat(noel_sawadogo, p_urb_048, 22000000).
prix_achat(yakubu_ouedraogo, p_urb_052, 20000000).
prix_achat(hamza_diallo, p_urb_055, 9000000).
prix_achat(saidou_kabore, p_urb_057, 13000000).
prix_achat(flore_compaore, p_urb_059, 9500000).
prix_achat(cheick_traore, p_urb_060, 16000000).
prix_achat(roukia_sawadogo, p_urb_063, 11000000).
prix_achat(kassoum_ouedraogo, p_urb_065, 22000000).
prix_achat(ramata_kabore, p_urb_069, 15500000).
prix_achat(adama_compaore, p_urb_072, 38000000).
prix_achat(luc_traore, p_urb_077, 14000000).
prix_achat(mariam_sawadogo, p_urb_079, 26000000).

% ============================================================
% SECTION 6 : DATES D'ACHAT date_achat(Acteur, Parcelle, Jour)
% ============================================================

date_achat(adama_ouedraogo, p_urb_001, 10).
date_achat(mariam_kabore, p_rur_001, 15).
date_achat(salif_traore, p_urb_002, 20).
date_achat(fatimata_sawadogo, p_rur_003, 25).
date_achat(issouf_compaore, p_urb_003, 30).
date_achat(aminata_diallo, p_rur_005, 35).
date_achat(rasmane_zongo, p_urb_005, 40).
date_achat(bintou_nikiema, p_rur_006, 45).
date_achat(dramane_ouedraogo, p_urb_006, 50).
date_achat(safi_kabore, p_rur_008, 55).
date_achat(wendyam_compaore, p_urb_007, 60).
date_achat(hawa_sawadogo, p_rur_010, 65).
date_achat(lassane_traore, p_urb_009, 70).
date_achat(roukiata_zongo, p_rur_012, 75).
date_achat(moussa_ouedraogo, p_urb_010, 80).
date_achat(aissata_kabore, p_urb_011, 85).
date_achat(karim_compaore, p_rur_013, 90).
date_achat(oumou_diallo, p_rur_014, 95).
date_achat(youssouf_nikiema, p_urb_013, 100).
date_achat(kadiatou_traore, p_urb_014, 105).
date_achat(noufou_sawadogo, p_urb_015, 110).
date_achat(bibata_compaore, p_rur_017, 115).
date_achat(inoussa_kabore, p_urb_017, 120).
date_achat(pelagie_ouedraogo, p_rur_019, 125).
date_achat(seydou_zongo, p_urb_019, 130).
date_achat(issa_compaore, p_urb_020, 135).
date_achat(fatoumata_nikiema, p_urb_021, 140).
date_achat(bassirou_traore, p_rur_021, 145).
date_achat(marietou_sawadogo, p_urb_023, 150).
date_achat(hamidou_diallo, p_rur_022, 155).
date_achat(souleymane_kabore, p_urb_024, 160).
date_achat(aicha_compaore, p_urb_026, 165).
date_achat(gaoussou_traore, p_urb_027, 170).
date_achat(romuald_sawadogo, p_urb_030, 175).
date_achat(clarisse_ouedraogo, p_urb_032, 180).
date_achat(idrissa_kabore, p_urb_033, 185).
date_achat(aziz_compaore, p_urb_037, 190).
date_achat(marcelline_traore, p_urb_042, 195).
date_achat(noel_sawadogo, p_urb_048, 200).
date_achat(yakubu_ouedraogo, p_urb_052, 205).
date_achat(hamza_diallo, p_urb_055, 210).
date_achat(saidou_kabore, p_urb_057, 215).
date_achat(flore_compaore, p_urb_059, 220).
date_achat(cheick_traore, p_urb_060, 225).
date_achat(roukia_sawadogo, p_urb_063, 230).
date_achat(kassoum_ouedraogo, p_urb_065, 235).
date_achat(ramata_kabore, p_urb_069, 240).
date_achat(adama_compaore, p_urb_072, 245).
date_achat(luc_traore, p_urb_077, 250).
date_achat(mariam_sawadogo, p_urb_079, 255).

% ============================================================
% SECTION 7 : LIENS FAMILIAUX lien_familial(X, Y)
% ============================================================

lien_familial(yakubu_ouedraogo, moussa_konate).
lien_familial(moussa_konate, yakubu_ouedraogo).
lien_familial(hamza_diallo, paul_sawadogo).
lien_familial(paul_sawadogo, hamza_diallo).
lien_familial(saidou_kabore, saidou_kabore).
lien_familial(cheick_traore, cheick_traore).
lien_familial(kassoum_ouedraogo, paul_sawadogo).
lien_familial(paul_sawadogo, kassoum_ouedraogo).
lien_familial(ramata_kabore, ramata_kabore).
lien_familial(adama_compaore, brice_coulibaly).
lien_familial(brice_coulibaly, adama_compaore).
lien_familial(luc_traore, luc_traore).
lien_familial(mariam_sawadogo, paul_sawadogo).
lien_familial(paul_sawadogo, mariam_sawadogo).
lien_familial(idrissa_kabore, aziz_compaore).
lien_familial(aziz_compaore, idrissa_kabore).
lien_familial(idrissa_kabore, marcelline_traore).
lien_familial(marcelline_traore, idrissa_kabore).
lien_familial(idrissa_kabore, noel_sawadogo).
lien_familial(noel_sawadogo, idrissa_kabore).
lien_familial(idrissa_kabore, yakubu_ouedraogo).
lien_familial(yakubu_ouedraogo, idrissa_kabore).
lien_familial(aziz_compaore, marcelline_traore).
lien_familial(marcelline_traore, aziz_compaore).
lien_familial(aziz_compaore, noel_sawadogo).
lien_familial(noel_sawadogo, aziz_compaore).
lien_familial(aziz_compaore, yakubu_ouedraogo).
lien_familial(yakubu_ouedraogo, aziz_compaore).
lien_familial(marcelline_traore, noel_sawadogo).
lien_familial(noel_sawadogo, marcelline_traore).
lien_familial(marcelline_traore, yakubu_ouedraogo).
lien_familial(yakubu_ouedraogo, marcelline_traore).
lien_familial(noel_sawadogo, yakubu_ouedraogo).
lien_familial(yakubu_ouedraogo, noel_sawadogo).

% ============================================================
% SECTION 8 : CONTACTS PARTAGÉS
% ============================================================

% Téléphones partagés
partage_telephone(idrissa_kabore, aziz_compaore).
partage_telephone(aziz_compaore, idrissa_kabore).
partage_telephone(noel_sawadogo, idrissa_kabore).
partage_telephone(idrissa_kabore, noel_sawadogo).
partage_telephone(yakubu_ouedraogo, idrissa_kabore).
partage_telephone(idrissa_kabore, yakubu_ouedraogo).
partage_telephone(kassoum_ouedraogo, ramata_kabore).
partage_telephone(ramata_kabore, kassoum_ouedraogo).
partage_telephone(adama_compaore, kassoum_ouedraogo).
partage_telephone(kassoum_ouedraogo, adama_compaore).
partage_telephone(luc_traore, kassoum_ouedraogo).
partage_telephone(kassoum_ouedraogo, luc_traore).
partage_telephone(mariam_sawadogo, kassoum_ouedraogo).
partage_telephone(kassoum_ouedraogo, mariam_sawadogo).

% Adresses partagées
partage_adresse(idrissa_kabore, aziz_compaore).
partage_adresse(aziz_compaore, idrissa_kabore).
partage_adresse(noel_sawadogo, idrissa_kabore).
partage_adresse(idrissa_kabore, noel_sawadogo).
partage_adresse(yakubu_ouedraogo, idrissa_kabore).
partage_adresse(idrissa_kabore, yakubu_ouedraogo).
partage_adresse(kassoum_ouedraogo, ramata_kabore).
partage_adresse(ramata_kabore, kassoum_ouedraogo).
partage_adresse(adama_compaore, kassoum_ouedraogo).
partage_adresse(kassoum_ouedraogo, adama_compaore).
partage_adresse(luc_traore, kassoum_ouedraogo).
partage_adresse(kassoum_ouedraogo, luc_traore).
partage_adresse(mariam_sawadogo, kassoum_ouedraogo).
partage_adresse(kassoum_ouedraogo, mariam_sawadogo).

% IBAN partagés
partage_iban(aziz_compaore, idrissa_kabore).
partage_iban(idrissa_kabore, aziz_compaore).
partage_iban(noel_sawadogo, idrissa_kabore).
partage_iban(idrissa_kabore, noel_sawadogo).
partage_iban(kassoum_ouedraogo, ramata_kabore).
partage_iban(ramata_kabore, kassoum_ouedraogo).
partage_iban(adama_compaore, kassoum_ouedraogo).
partage_iban(kassoum_ouedraogo, adama_compaore).
partage_iban(luc_traore, kassoum_ouedraogo).
partage_iban(kassoum_ouedraogo, luc_traore).
partage_iban(mariam_sawadogo, kassoum_ouedraogo).
partage_iban(kassoum_ouedraogo, mariam_sawadogo).

% ============================================================
% SECTION 9 : DOSSIERS ET TRAITEMENT
% ============================================================

% Dossier D001 — Adama Ouédraogo
traite(moussa_konate, d001).
concerne(d001, p_urb_001).
beneficiaire(adama_ouedraogo, d001).

% Dossier D002 — Mariam Kaboré
traite(paul_sawadogo, d002).
concerne(d002, p_rur_001).
beneficiaire(mariam_kabore, d002).

% Dossier D003 — Salif Traoré
traite(brice_coulibaly, d003).
concerne(d003, p_urb_002).
beneficiaire(salif_traore, d003).

% Dossier D004 — Fatimata Sawadogo
traite(ines_zongo, d004).
concerne(d004, p_rur_003).
beneficiaire(fatimata_sawadogo, d004).

% Dossier D005 — Issouf Compaoré
traite(moussa_konate, d005).
concerne(d005, p_urb_003).
beneficiaire(issouf_compaore, d005).

% Dossier D006 — Aminata Diallo
traite(henri_tapsoba, d006).
concerne(d006, p_rur_005).
beneficiaire(aminata_diallo, d006).

% Dossier D007 — Rasmané Zongo
traite(paul_sawadogo, d007).
concerne(d007, p_urb_005).
beneficiaire(rasmane_zongo, d007).

% Dossier D008 — Bintou Nikiema
traite(brice_coulibaly, d008).
concerne(d008, p_rur_006).
beneficiaire(bintou_nikiema, d008).

% Dossier D009 — Dramane Ouédraogo
traite(ines_zongo, d009).
concerne(d009, p_urb_006).
beneficiaire(dramane_ouedraogo, d009).

% Dossier D010 — Safi Kaboré
traite(moussa_konate, d010).
concerne(d010, p_rur_008).
beneficiaire(safi_kabore, d010).

% Dossier D011 — Wendyam Compaoré
traite(paul_sawadogo, d011).
concerne(d011, p_urb_007).
beneficiaire(wendyam_compaore, d011).

% Dossier D012 — Hawa Sawadogo
traite(henri_tapsoba, d012).
concerne(d012, p_rur_010).
beneficiaire(hawa_sawadogo, d012).

% Dossier D013 — Lassané Traoré
traite(brice_coulibaly, d013).
concerne(d013, p_urb_009).
beneficiaire(lassane_traore, d013).

% Dossier D014 — Roukiata Zongo
traite(ines_zongo, d014).
concerne(d014, p_rur_012).
beneficiaire(roukiata_zongo, d014).

% Dossier D015 — Moussa Ouédraogo
traite(moussa_konate, d015).
concerne(d015, p_urb_010).
beneficiaire(moussa_ouedraogo, d015).

% Dossier D016 — Aïssata Kaboré
traite(brice_coulibaly, d016).
concerne(d016, p_urb_011).
beneficiaire(aissata_kabore, d016).

% Dossier D017 — Karim Compaoré
traite(paul_sawadogo, d017).
concerne(d017, p_rur_013).
beneficiaire(karim_compaore, d017).

% Dossier D018 — Oumou Diallo
traite(henri_tapsoba, d018).
concerne(d018, p_rur_014).
beneficiaire(oumou_diallo, d018).

% Dossier D019 — Youssouf Nikiema
traite(ines_zongo, d019).
concerne(d019, p_urb_013).
beneficiaire(youssouf_nikiema, d019).

% Dossier D020 — Kadiatou Traoré
traite(moussa_konate, d020).
concerne(d020, p_urb_014).
beneficiaire(kadiatou_traore, d020).

% Dossier D021 — Noufou Sawadogo
traite(henri_tapsoba, d021).
concerne(d021, p_urb_015).
beneficiaire(noufou_sawadogo, d021).

% Dossier D022 — Bibata Compaoré
traite(brice_coulibaly, d022).
concerne(d022, p_rur_017).
beneficiaire(bibata_compaore, d022).

% Dossier D023 — Inoussa Kaboré
traite(paul_sawadogo, d023).
concerne(d023, p_urb_017).
beneficiaire(inoussa_kabore, d023).

% Dossier D024 — Pélagie Ouédraogo
traite(ines_zongo, d024).
concerne(d024, p_rur_019).
beneficiaire(pelagie_ouedraogo, d024).

% Dossier D025 — Seydou Zongo
traite(moussa_konate, d025).
concerne(d025, p_urb_019).
beneficiaire(seydou_zongo, d025).

% Dossier D026 — Issa Compaoré
traite(paul_sawadogo, d026).
concerne(d026, p_urb_020).
beneficiaire(issa_compaore, d026).

% Dossier D027 — Fatoumata Nikiema
traite(henri_tapsoba, d027).
concerne(d027, p_urb_021).
beneficiaire(fatoumata_nikiema, d027).

% Dossier D028 — Bassirou Traoré
traite(brice_coulibaly, d028).
concerne(d028, p_rur_021).
beneficiaire(bassirou_traore, d028).

% Dossier D029 — Mariétou Sawadogo
traite(ines_zongo, d029).
concerne(d029, p_urb_023).
beneficiaire(marietou_sawadogo, d029).

% Dossier D030 — Hamidou Diallo
traite(moussa_konate, d030).
concerne(d030, p_rur_022).
beneficiaire(hamidou_diallo, d030).

% Dossier D031 — Souleymane Kaboré
traite(paul_sawadogo, d031).
concerne(d031, p_urb_024).
beneficiaire(souleymane_kabore, d031).

% Dossier D032 — Aicha Compaoré
traite(henri_tapsoba, d032).
concerne(d032, p_urb_026).
beneficiaire(aicha_compaore, d032).

% Dossier D033 — Gaoussou Traoré
traite(brice_coulibaly, d033).
concerne(d033, p_urb_027).
beneficiaire(gaoussou_traore, d033).

% Dossier D034 — Romuald Sawadogo
traite(ines_zongo, d034).
concerne(d034, p_urb_030).
beneficiaire(romuald_sawadogo, d034).

% Dossier D035 — Clarisse Ouédraogo
traite(moussa_konate, d035).
concerne(d035, p_urb_032).
beneficiaire(clarisse_ouedraogo, d035).

% Dossier D036 — Idrissa Kaboré
traite(paul_sawadogo, d036).
concerne(d036, p_urb_033).
beneficiaire(idrissa_kabore, d036).

% Dossier D037 — Aziz Compaoré
traite(henri_tapsoba, d037).
concerne(d037, p_urb_037).
beneficiaire(aziz_compaore, d037).

% Dossier D038 — Marcelline Traoré
traite(brice_coulibaly, d038).
concerne(d038, p_urb_042).
beneficiaire(marcelline_traore, d038).

% Dossier D039 — Noël Sawadogo
traite(ines_zongo, d039).
concerne(d039, p_urb_048).
beneficiaire(noel_sawadogo, d039).

% Dossier D040 — Yakubu Ouédraogo
traite(moussa_konate, d040).
concerne(d040, p_urb_052).
beneficiaire(yakubu_ouedraogo, d040).

% Dossier D041 — Hamza Diallo
traite(paul_sawadogo, d041).
concerne(d041, p_urb_055).
beneficiaire(hamza_diallo, d041).

% Dossier D042 — Saidou Kaboré
traite(saidou_kabore, d042).
concerne(d042, p_urb_057).
beneficiaire(saidou_kabore, d042).

% Dossier D043 — Flore Compaoré
traite(henri_tapsoba, d043).
concerne(d043, p_urb_059).
beneficiaire(flore_compaore, d043).

% Dossier D044 — Cheick Traoré
traite(cheick_traore, d044).
concerne(d044, p_urb_060).
beneficiaire(cheick_traore, d044).

% Dossier D045 — Roukia Sawadogo
traite(ines_zongo, d045).
concerne(d045, p_urb_063).
beneficiaire(roukia_sawadogo, d045).

% Dossier D046 — Kassoum Ouédraogo
traite(paul_sawadogo, d046).
concerne(d046, p_urb_065).
beneficiaire(kassoum_ouedraogo, d046).

% Dossier D047 — Ramata Kaboré
traite(ramata_kabore, d047).
concerne(d047, p_urb_069).
beneficiaire(ramata_kabore, d047).

% Dossier D048 — Adama Compaoré
traite(brice_coulibaly, d048).
concerne(d048, p_urb_072).
beneficiaire(adama_compaore, d048).

% Dossier D049 — Luc Traoré
traite(luc_traore, d049).
concerne(d049, p_urb_077).
beneficiaire(luc_traore, d049).

% Dossier D050 — Mariam Sawadogo
traite(paul_sawadogo, d050).
concerne(d050, p_urb_079).
beneficiaire(mariam_sawadogo, d050).

% ============================================================
% SECTION 10 : PRÉDICATS AUXILIAIRES
% ============================================================

acteur(X) :- citoyen(X).
acteur(X) :- agent_public(X).
acteur(X) :- promoteur(X).
acteur(X) :- notaire(X).

parcelle(X) :- parcelle_urbaine(X).
parcelle(X) :- parcelle_rurale(X).

% Date courante simulée (en jours depuis référence 01/01/2020)
date_courante(800).

% Métadonnée label ground-truth pour validation
% label_gt(ActeurSlug, Label).
label_gt(adama_ouedraogo, standard).
label_gt(mariam_kabore, standard).
label_gt(salif_traore, standard).
label_gt(fatimata_sawadogo, standard).
label_gt(issouf_compaore, standard).
label_gt(aminata_diallo, standard).
label_gt(rasmane_zongo, standard).
label_gt(bintou_nikiema, standard).
label_gt(dramane_ouedraogo, standard).
label_gt(safi_kabore, standard).
label_gt(wendyam_compaore, standard).
label_gt(hawa_sawadogo, standard).
label_gt(lassane_traore, standard).
label_gt(roukiata_zongo, standard).
label_gt(moussa_ouedraogo, standard).
label_gt(aissata_kabore, standard).
label_gt(karim_compaore, standard).
label_gt(oumou_diallo, standard).
label_gt(youssouf_nikiema, standard).
label_gt(kadiatou_traore, standard).
label_gt(noufou_sawadogo, standard).
label_gt(bibata_compaore, standard).
label_gt(inoussa_kabore, standard).
label_gt(pelagie_ouedraogo, standard).
label_gt(seydou_zongo, standard).
label_gt(issa_compaore, standard).
label_gt(fatoumata_nikiema, standard).
label_gt(bassirou_traore, standard).
label_gt(marietou_sawadogo, standard).
label_gt(hamidou_diallo, standard).
label_gt(souleymane_kabore, speculateur).
label_gt(aicha_compaore, speculateur).
label_gt(gaoussou_traore, speculateur).
label_gt(romuald_sawadogo, speculateur).
label_gt(clarisse_ouedraogo, speculateur).
label_gt(idrissa_kabore, accapareur).
label_gt(aziz_compaore, accapareur).
label_gt(marcelline_traore, accapareur).
label_gt(noel_sawadogo, accapareur).
label_gt(yakubu_ouedraogo, accapareur).
label_gt(hamza_diallo, limite).
label_gt(saidou_kabore, limite).
label_gt(flore_compaore, limite).
label_gt(cheick_traore, limite).
label_gt(roukia_sawadogo, limite).
label_gt(kassoum_ouedraogo, fraude).
label_gt(ramata_kabore, fraude).
label_gt(adama_compaore, fraude).
label_gt(luc_traore, fraude).
label_gt(mariam_sawadogo, fraude).