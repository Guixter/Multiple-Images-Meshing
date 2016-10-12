close all;
clear;
load donnees;

%% Construction de l'ensemble total des faces
nb_tetra = size(tri, 1);
Nf = nb_tetra * 4;
FACES = zeros(Nf, 3);
for i=1:nb_tetra
    FACES(i*4 + 1, :) = [tri(i, 1), tri(i, 2), tri(i, 3)];
    FACES(i*4 + 2, :) = [tri(i, 1), tri(i, 3), tri(i, 4)];
    FACES(i*4 + 3, :) = [tri(i, 1), tri(i, 2), tri(i, 4)];
    FACES(i*4 + 4, :) = [tri(i, 2), tri(i, 3), tri(i, 4)];
end

%% Tri des faces
FACES = sortrows(FACES);

%% Suppression des faces apparaissant plus d'une fois
doubles = [];
for i=1:Nf-1
    if (FACES(i, :) == FACES(i+1, :))
        doubles = [doubles ; i ; i+1];
    end
end
FACES = FACES(setdiff(1:Nf, doubles), :);

fprintf('Calcul du maillage final terminé : %d faces. \n',size(FACES,1));

%% Affichage du maillage final
figure;
hold on
for i = 1:size(FACES,1)
   plot3([X(1,FACES(i,1)) X(1,FACES(i,2))],[X(2,FACES(i,1)) X(2,FACES(i,2))],[X(3,FACES(i,1)) X(3,FACES(i,2))],'r');
   plot3([X(1,FACES(i,1)) X(1,FACES(i,3))],[X(2,FACES(i,1)) X(2,FACES(i,3))],[X(3,FACES(i,1)) X(3,FACES(i,3))],'r');
   plot3([X(1,FACES(i,3)) X(1,FACES(i,2))],[X(2,FACES(i,3)) X(2,FACES(i,2))],[X(3,FACES(i,3)) X(3,FACES(i,2))],'r');
end;