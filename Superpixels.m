%% Segmenter l'image en superpixels
% INPUTS :
%  - I : L'image
%  - k : le nombre de superpixels souhaités
%  - m : le poids donné à la distance géométrique
%  - fusion_percent : le pourcentage à partir duquel fusionner les
%  superpixels
%  - seuil_couleur : La distance maximale colorimétrique acceptée pour
%  fusionner deux régions
%  - rgb : true si on veut utiliser la couleur rgb, false si on veut
%  utiliser lab
%  - draw : si true, dessine les résultats
%
% OUTPUTS :
%  - spx : Matrice de la taille de l'image, qui, à chaque pixel, attribue un
%  superpixel
%  - centres : matrice de taille k*5, dont chaque ligne correspond à un
%  centre de superpixel. A chaque ligne, on trouve la position en X, en Y,
%  et les 3 canaux de couleur rgb.
function [spx, centres] = Superpixels(I, k, m, fusion_percent, seuil_couleur, rgb, draw)
	% Charger l'image
	[nb_lignes, nb_colonnes, ~] = size(I);
	N = nb_lignes * nb_colonnes;
	I = double(I);
	if (~rgb)
		I = rgb2lab(I);
	end

	% Constantes
	taille_moy = N/k;
	S = sqrt(taille_moy);
	m_sur_S = m/S;
	[start] = Germes(I, k);
	
	% Afficher les germes
    if draw
        figure('Name','Germes générés');
        if (rgb)
            imagesc(I / 255);
        else
            imagesc(lab2rgb(I) / 255);
        end
        hold on;
        plot(start(:, 2), start(:, 1), 'r*');
    end

	% Construire X
	X = zeros(N, 5);
	X(:, 1) = repmat(1:nb_lignes, 1, nb_colonnes)';
	for i=1:nb_colonnes
		indMin = (i-1) * nb_lignes + 1;
		indMax = i * nb_lignes;
		X(indMin:indMax, 2) = i;
	end
	X(:, 3) = reshape(I(:, :, 1), N, 1);
	X(:, 4) = reshape(I(:, :, 2), N, 1);
	X(:, 5) = reshape(I(:, :, 3), N, 1);

	% Appeler KmeansSlic
	[IDX, centres] = KmeansSlic(X, k, m_sur_S, 'Distance', 'slic', 'start', start);
    if (~rgb)
		centres = [centres(:, 1:2), lab2rgb(centres(:, 3:5))];
    end
    
    % Afficher le résultat
    if draw
        figure('Name', 'Appel à kmeans');
        img = centres(:, 3:5);
        img = img(IDX, :);
        img = reshape(img, nb_lignes, nb_colonnes, 3);
        imagesc(img/255);
    end
	
	% Calculer la distance géométrique entre chaque région
	distance_geo = zeros(k);
	for i=1:k
		distance_geo(i, :) = sqrt((centres(i, 1) - centres(:, 1)).^2 + (centres(i, 2) - centres(:, 2)).^2)';
    end
    
    % Calculer la distance colorimétrique entre chaque région
	distance_col = zeros(k);
	for i=1:k
        distance_col(i, :) = sqrt((centres(i, 3) - centres(:, 3)).^2 + (centres(i, 4) - centres(:, 4)).^2 + (centres(i, 5) - centres(:, 5)).^2)';
    end
    
	% Compter le nombre de px par région
	taille = zeros(k, 1);
	for i=1:k
		taille(i) = length(find(IDX == i));
	end

	% Fusionner les petites régions avec leur plus grande région voisine
	taille_min = (fusion_percent/100) * taille_moy;
	petites_regions = find(taille <= taille_min);
	nb_petites_regions = length(petites_regions);
	for i=1:nb_petites_regions
		[~, regions_voisines] = sort(distance_geo(petites_regions(i), :), 'ascend');

		j = 2;
		while (j ~= k) && (taille(regions_voisines(j)) < taille_min) ...
                       && (distance_col(petites_regions(i), regions_voisines(j)) > seuil_couleur)
			j = j + 1;
        end

		IDX(IDX == petites_regions(i)) = regions_voisines(j);
		taille(petites_regions(i)) = 0;
		taille(regions_voisines(j)) = length(find(IDX == regions_voisines(j)));
	end
	
	% Calculer les valeurs à renvoyer
	spx = reshape(IDX, nb_lignes, nb_colonnes);
	
	% Afficher la segmentation post fusion
    if draw
        figure('Name', 'Après fusion');
        img = centres(:, 3:5);
        img = img(IDX, :);
        img = reshape(img, nb_lignes, nb_colonnes, 3);
        imagesc(img/255);
    end
end
