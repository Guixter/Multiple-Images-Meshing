close all;
clear;

nb_images = 36;

%% Chargement des images :
% im est de taille : nb_lignes x nb_colonnes x nb_canaux x nb_images
for i = 1:nb_images
    if i<=10
        nom = sprintf('images/viff.00%d.ppm', i-1);
    else
        nom = sprintf('images/viff.0%d.ppm', i-1);
    end;
    im(:, :, :, i) = imread(nom); 
end;
nb_lignes = size(im, 1);
nb_colonnes = size(im, 2);
nb_canaux = size(im, 3);

%% Chargement des points 2D suivis :
% La matrice pts est de taille nb_points x (2 x nb_images), avec sur
% chaque ligne, tous les appariements possibles pour un point 3D donné
% On affiche les coordonnées (xi,yi) de Pi dans les colonnes 2i-1 et 2i
% tout le reste vaut -1
pts = load('viff.xy');

%% Chargement des matrices de projection :
% Chaque P{i} contient la matrice de projection associée a l'image i 
% RAPPEL : P{i} est de taille 3 x 4
load dino_Ps;

%% Chargement des masques (pour l'élimination des fonds bleus) :
% im_mask est taille nb_lignes x nb_colonnes x nb_images
load mask;
im_mask = not(im_mask);

% Affichage des images et des masques associés
figure; 
subplot(2, 2, 1); imshow(im(:, :, :, 1)); title('Image 1');
subplot(2, 2, 2); imshow(im(:, :, :, 9)); title('Image 9');
subplot(2, 2, 3); imshow(im(:, :, :, 17)); title('Image 17');
subplot(2, 2, 4); imshow(im(:, :, :, 25)); title('Image 25');

figure;
subplot(2, 2, 1); imshow(im_mask(:, :, 1)); title('Masque image 1');
subplot(2, 2, 2); imshow(im_mask(:, :, 9)); title('Masque image 9');
subplot(2, 2, 3); imshow(im_mask(:, :, 17)); title('Masque image 17');
subplot(2, 2, 4); imshow(im_mask(:, :, 25)); title('Masque image 25');

%% Reconstruction des points 3D :
% X contient les coordonnées des points en 3D
% color contient la couleur associée
X = [];
color = [];
for i = 1:size(pts, 1)
    % Récuperation des ensembles de points appariés :
    l = find(pts(i,1:2:end) ~= -1);
    % Vérification qu'il existe bien des points appariés dans cette image :
    if size(l,2) > 1 & max(l)-min(l) > 1 & max(l)-min(l) < 36
        A = [];
        R = 0;
        G = 0;
        B = 0;
        % Pour chaque point recupere, calcul des coordonnees en 3D :
        for j = l
            A = [A ; P{j}(1,:) - pts(i,(j-1)*2+1)*P{j}(3,:) ; 
                 P{j}(2,:) - pts(i,(j-1)*2+2)*P{j}(3,:)     ];
            R = R + double(im(int16(pts(i,(j-1)*2+1)), int16(pts(i,(j-1)*2+2)),1,j));
            G = G + double(im(int16(pts(i,(j-1)*2+1)), int16(pts(i,(j-1)*2+2)),2,j));
            B = B + double(im(int16(pts(i,(j-1)*2+1)), int16(pts(i,(j-1)*2+2)),3,j));
        end;
        [U, S, V] = svd(A);
        X = [X V(:,end)/V(end,end)];
        color = [color [R/size(l,2);G/size(l,2);B/size(l,2)]];
    end;
end;
fprintf('Calcul des points 3D terminé : %d points trouvés. \n', size(X,2));

% Affichage du nuage de points 3D :
figure;
hold on;
for i = 1:size(X,2)
    plot3(X(1,i), X(2,i), X(3,i), '.', 'col', color(:,i)/255);
end;
axis equal;

%% Tétraédrisation de Delaunay :
T = delaunayTriangulation(X(1:3, :)');
fprintf('Tétraédrisation terminée : %d tétraèdres trouvés. \n', size(T,1));

% Affichage de la tétraédrisation de Delaunay :
figure;
tetramesh(T);

%% Calcul des barycentres de chacun des tétraèdres
% TODO : faire une matrice de poids plus "complète"
poids = [ 0.25, 0.25, 0.25, 0.25 ;
          0.7 , 0.1 , 0.1 , 0.1  ;
          0.1 , 0.7 , 0.1 , 0.1  ;
          0.1 , 0.1 , 0.7 , 0.1  ;
          0.1 , 0.1 , 0.1 , 0.7  ];
nb_barycentres = size(poids, 1);
nb_tetra = size(T, 1);
C_g = zeros(4, nb_tetra, nb_barycentres);
for i = 1:nb_tetra
    % Calcul des barycentres différents
    pts_tetra = T.Points(T(i, :), :)';
    
    for k=1:nb_barycentres
        C_g(1:3, i, k) = sum(repmat(poids(k, :), 3, 1) .* pts_tetra, 2);
        C_g(4, i, k) = 1;
    end
end

% A DECOMMENTER POUR VERIFICATION 
% Visualisation pour vérifier le bon calcul des barycentres
% for i = 1:nb_images
%    for k = 1:nb_barycentres
%        o = P{i}*C_g(:,:,k);
%        o = o./repmat(o(3,:),3,1);
%        imshow(im_mask(:,:,i));
%        hold on;
%        plot(o(2,:),o(1,:),'rx');
%        pause;
%        close;
%    end
% end

%% Retrait des "mauvais" tétraèdres
% Copie de la triangulation pour pouvoir supprimer des tétraèdres
tri = T;

% Retrait des tetraedres dont au moins un des barycentres 
% ne se trouvent pas dans au moins un des masques des images de travail
for k=1:nb_barycentres
    nb_tetra = size(tri, 1);
    bary_dans_dino = [];
    for i=1:nb_tetra
        bary_valide = 1;
        for j=1:nb_images
            bary = P{j} * C_g(:, i, k);
            bary = bary / bary(3);
            bary = round(bary);

            if (bary(1) >= 1 && bary(1) <= nb_lignes && bary(2) >= 1 && bary(2) <= nb_colonnes)
                if (~(im_mask(bary(1), bary(2), j)))
                    bary_valide = 0;
                end
            else
                bary_valide = 0;
            end
        end
        
        if (bary_valide)
            bary_dans_dino = [bary_dans_dino, i];
        end
    end
    
    tri = tri(bary_dans_dino, :);
end

% Affichage des tétraèdres restants
fprintf('Retrait des tétraèdres extérieurs a la forme 3D terminé : %d tétraèdres restants. \n',size(tri,1));
figure;
trisurf(tri,X(1,:),X(2,:),X(3,:));

%% Sauvegarde des données
save donnees;