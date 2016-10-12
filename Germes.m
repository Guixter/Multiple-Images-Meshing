%% Obtenir les germes pour kmeans
% INPUTS :
%  - I : l'image
%  - nb_germes : le nombre de germes souhaité
%
% OUTPUTS :
% - germes : 
function [germes] = Germes(I,nb_germes)
	% On prend le multiple de 10 superieur si mod(nb_germes,10)~=0
    k = nb_germes;
	if (mod(nb_germes,10)~=0)
		q = floor(nb_germes/10);
		nb_germes = (q+1)*10;
	end

	% Determination des parametres du pavage optimal
	[nb_lignes, nb_colonnes, ~] = size(I);
	N = nb_lignes * nb_colonnes;
	diviseurs = (divisors(nb_germes))';
	couples_div = [diviseurs, nb_germes./diviseurs];

	ratio_image = nb_lignes / nb_colonnes;
	ecart = abs(ratio_image - couples_div(:, 1)./couples_div(:, 2));
	[ecart_min, idx] = min(ecart);

	p = couples_div(idx, 1);
	q = couples_div(idx, 2);

	% Construction des germes
	germes = [];
	pas_lignes = floor(nb_lignes / p);
	pas_colonnes = floor(nb_colonnes / q);
	for i=floor(pas_lignes/2):pas_lignes:nb_lignes
		for j=floor(pas_colonnes/2):pas_colonnes:nb_colonnes
			germes = [germes; i, j, reshape(I(i, j, :), 1, 3)];
		end
    end
    
    germes = germes(1:k, :);
end

