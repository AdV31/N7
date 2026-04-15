function [P]=columnstochastic_matrix(Q,N)
% Modification par une matrice de rang 1 afin d'obtenir une matrice
% stochastique par colonne
% Q est la matrice carr?e du graphe d'internet.
% P est la matrice carr?e du graphe d'internet modifi?.


% Initialisation
n=length(Q(:,1));
e = ones(n,1);
d = zeros(1,n);
idx = find(N==0);
d(idx)=1;
P = Q + (1/n)*e*d;
end