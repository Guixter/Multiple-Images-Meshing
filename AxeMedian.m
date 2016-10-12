%% Calcul de l'axe médian du dinosaure
% INPUTS :
%  - img : l'image, segmentée fond/forme
%  - pas_frontiere : le pas d'échantillonnage de la frontière
%  - draw : si true, dessine les résultats
%
% OUTPUTS :
%  - frontiere : une liste de pts représentant la frontière du dinosaure
%  - squelette : une liste de lignes contenant la position en X et Y, et le rayon
%  - adjacence : la matrice d'adjacence du squelette
function [frontiere, squelette, adjacence] = AxeMedian(img, pas_frontiere, draw)
	% Constantes
	[nb_lignes, nb_colonnes] = size(img);
	
	% Estimation de la frontière
	x = floor(nb_lignes/2);
	y = find(img(x, :));
	P = [x, y(1)];
	frontiere = bwtraceboundary(img, P, 'N');
	frontiere = frontiere(1:pas_frontiere:end, :);
	nb_pts_frontiere = size(frontiere, 1);
	
	% Affichage de la frontière
    if draw
        figure('Name', 'Frontière du dinosaure');
        imagesc(img);
        hold on;
        plot(frontiere(:, 2), frontiere(:, 1), 'LineWidth', 2, 'Color', 'green');
        plot(P(2), P(1), 'rx', 'LineWidth', 2);
    end

	% Estimation des points du squelette
	[vx, vy] = voronoi(frontiere(:, 1), frontiere(:, 2));
    pts_x = [vx(1, :), vx(2, :)]';
    pts_y = [vy(1, :), vy(2, :)]';
	forme = find(img);
	voronoi_ind = unique(sub2ind([nb_lignes, nb_colonnes], min(max(1, floor(pts_x)), nb_lignes), min(max(1, floor(pts_y)), nb_colonnes)));
	voronoi_ind = intersect(forme, voronoi_ind);
	[voronoi_x, voronoi_y] = ind2sub([nb_lignes, nb_colonnes], voronoi_ind);
	nb_pts_voronoi = length(voronoi_ind);
    nb_segments_voronoi = size(vx, 2);
	
	% Affichage des points du squelette
	if draw
        figure('Name', 'Points du squelette');
        imagesc(img);
        hold on;
        plot(voronoi_y, voronoi_x, 'm.');
    end

	% Calcul des rayons
	distance_voronoi = zeros(nb_pts_voronoi, nb_pts_frontiere);
	for i=1:nb_pts_voronoi
		x = voronoi_x(i);
		y = voronoi_y(i);
		distance_voronoi(i, :) = sqrt((x - frontiere(:, 1)).^2 + (y - frontiere(:, 2)).^2)';
	end
	rayon_voronoi = min(distance_voronoi, [], 2);
    squelette = [voronoi_x, voronoi_y, rayon_voronoi];

	% Affichage des cercles
    if draw
        figure('Name', 'Rayons attribués aux points du squelette');
        imagesc(img);
        hold on;
        angle = 0:0.01:2*pi;
        for i=1:nb_pts_voronoi
            x = voronoi_x(i) + rayon_voronoi(i) * cos(angle);
            y = voronoi_y(i) + rayon_voronoi(i) * sin(angle);
            plot(y, x, 'LineWidth', 1, 'Color', 'g');
        end
    end

	% Estimation de la topologie du squelette
    adjacence = zeros(nb_pts_voronoi);
    for i=1:nb_segments_voronoi
        x1 = min(max(1, floor(vx(1, i))), nb_lignes);
        x2 = min(max(1, floor(vx(2, i))), nb_lignes);
        y1 = min(max(1, floor(vy(1, i))), nb_colonnes);
        y2 = min(max(1, floor(vy(2, i))), nb_colonnes);
        ind1 = sub2ind([nb_lignes, nb_colonnes], x1, y1);
        ind2 = sub2ind([nb_lignes, nb_colonnes], x2, y2);
        adjacence((voronoi_ind == ind1), (voronoi_ind == ind2)) = 1;
    end
    
    % Affichage de l'axe médian
    if draw
        figure('Name', 'Axe médian');
        imagesc(img);
        hold on;
        gplot(adjacence, squelette(:, 2:-1:1), 'r');
    end
end
