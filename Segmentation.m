%% Segmentation fond/forme de l'image
% INPUTS :
%  - spx : la décomposition en superpixels de l'image
%  - rgb : les couleurs (rgb) des centres des superpixels (k*3)
%  - seuil_bleu : le seuil de refus d'un pixel bleu
%  - seuil_blanc : le seuil d'acceptation d'un pixel blanc
%  - seuil_noir : le seuil de refus d'un pixel noir
%  - draw : si true, dessine les résultats
%
% OUTPUTS :
%  - img_segmentee : une matrice de 0 (fond) et de 1 (forme), de la taille de l'image.
function [img_segmentee] = Segmentation(spx, rgb, seuil_bleu, seuil_blanc, seuil_noir, draw)
	% Constantes
	[nb_lignes, nb_colonnes] = size(spx);
	
	% Segmentation
	non_noir = max(rgb, [], 2) > seuil_noir;
	non_bleu = rgb(:, 3) < seuil_bleu;
	blanc = max(rgb(:, 1:2), [], 2) > seuil_blanc;
	centres_segmentes = non_noir & (non_bleu | blanc);

	% Création de l'image binaire
	img_segmentee = centres_segmentes(spx);
	img_segmentee = reshape(img_segmentee, nb_lignes, nb_colonnes);
	
	% Affichage de l'image binaire
    if draw
        figure('Name', 'Image segmentée');
        imagesc(img_segmentee);
    end
end
