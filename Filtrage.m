%% Filtrage de l'axe médian par Scale Axis Transform
% INPUTS :
%  - img : l'image, segmentée fond/forme
%  - squelette_int : le squelette du dino (points et rayons)
%  - pas_frontiere : le pas d'échantillonnage de la frontière
%  - s : la valeur du paramètre pour la scale axis transform
%  - draw : si true, dessine les résultats
%
% OUTPUTS :
%  - frontiere : une liste de pts représentant la frontière du dinosaure
%  - squelette : une liste de lignes contenant la position en X et Y, et le rayon
%  - adjacence : la matrice d'adjacence du squelette
function [frontiere, squelette, adjacence] = Filtrage(img, squelette_int, pas_frontiere, s, draw)
    % Constantes
    [nb_lignes, nb_colonnes] = size(img);
    nb_pts_voronoi = size(squelette_int, 1);
    pos_x = repmat((1:nb_lignes)', 1, nb_colonnes);
    pos_y = repmat(1:nb_colonnes, nb_lignes, 1);
    
    % Grossissement de l'image
    img_grossie = zeros(nb_lignes, nb_colonnes);
    for i=1:nb_pts_voronoi
        x = squelette_int(i, 1);
        y = squelette_int(i, 2);
        rayon = squelette_int(i, 3) * s;
        distance = sqrt((pos_x - x).^2 + (pos_y - y).^2);
        img_grossie(distance <= rayon) = 1;
    end
    
    % Affichage de l'image grossie
    if draw
        figure('Name', 'Image grossie');
        imagesc(img_grossie);
    end
    
    [frontiere, squelette, adjacence] = AxeMedian(img_grossie, pas_frontiere, false);
    squelette(:, 3) = squelette(:, 3) / s;
    
    % Affichage du squelette filtré
    if draw
        figure('Name', 'Squelette filtré');
        imagesc(img);
        hold on;
        gplot(adjacence, squelette(:, 2:-1:1), 'r');
    end
end
