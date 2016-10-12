close all;
clear;

%% Paramètres
file = 'images/D001.ppm';
I = imread(file);
[nb_lignes, nb_colonnes, nb_canaux] = size(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation en superpixels
m = 1500;
nb_superpixels = 100;
fusion_percent = 20;
rgb = false;
seuil_couleur = 30;

[spx, centres] = Superpixels(I, nb_superpixels, m, fusion_percent, seuil_couleur, rgb, true);
pause();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation fond/forme
seuil_bleu = 90;
seuil_blanc = 150;
seuil_noir = 50;

img_segmentee = Segmentation(spx, centres(:, 3:5), seuil_bleu, seuil_blanc, seuil_noir, true);
pause();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calcul de l'axe médian
pas_frontiere = 2;

[frontiere_int, squelette_int, adjacence_int] = AxeMedian(img_segmentee, pas_frontiere, true);
pause();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filtrage de l'axe médian
pas_frontiere = 4;
s = 1.2;

[frontiere, squelette, adjacence] = Filtrage(img_segmentee, squelette_int, pas_frontiere, s, true);