close all;
clear;

%% Paramètres
nb_images = 36;
m = 1500;
nb_superpixels = 100;
fusion_percent = 20;
rgb = false;
seuil_couleur = 30;
seuil_bleu = 90;
seuil_blanc = 150;
seuil_noir = 50;

%% Chargement des images :
% im est de taille : nb_lignes x nb_colonnes x nb_canaux x nb_images
for i = 1:nb_images
    if i<=10
        nom = sprintf('images/viff.00%d.ppm',i-1);
    else
        nom = sprintf('images/viff.0%d.ppm',i-1);
    end;
    im(:, :, :, i) = imread(nom); 
end

%% Création des masques
for i=1:nb_images
    % Segmentation en superpixels
    [spx, centres] = Superpixels(im(:,:,:,i), nb_superpixels, m, fusion_percent, seuil_couleur, rgb, false);
    % Segmentation fond/forme
    im_mask(:, :, i) = Segmentation(spx, centres(:, 3:5), seuil_bleu, seuil_blanc, seuil_noir, false);
    disp(i);
end

im_mask = not(im_mask);

save mask;