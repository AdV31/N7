%%  Application de la SVD : compression d'images

clear all
close all

% Lecture de l'image
I = imread('BD_Asterix_Colored.jpg');
I = rgb2gray(I);
I = double(I);

[q, p] = size(I)

% Décomposition par SVD
fprintf('Décomposition en valeurs singulières\n')
tic
[U, S, V] = svd(I);
toc

l = min(p,q);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% On choisit de ne considérer que 200 vecteurs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 200 vecteurs utilisés pour la reconstruction et on affiche l'image tous les 40 vecteurs (pas)
inter = 1:40:(200+40);
inter(end) = 200;

% vecteur pour stocker la différence entre l'image et l'image reconstruite

differenceSVD = zeros(size(inter,2), 1);

% images reconstruites en utilisant de 1 à 200 vecteurs
ti = 0;
td = 0;
for k = inter

    % Calcul de l'image de rang k
    Im_k = U(:, 1:k)*S(1:k, 1:k)*V(:, 1:k)';

    % Affichage de l'image reconstruite
    ti = ti+1;
    figure(ti)
    colormap('gray')
    imagesc(Im_k), axis equal
    
    % Calcul de la différence entre les 2 images (RMSE : Root Mean Square Error)
    td = td + 1;
    differenceSVD(td) = sqrt(sum(sum((I-Im_k).^2)));
end

% Figure des différences entre l'image réelle et les images reconstruites
ti = ti+1;
figure(ti)
hold on
plot(inter, differenceSVD, 'rx')
ylabel('RMSE')
xlabel('rank k')


% Plugger les différentes méthodes : eig, puissance itérée et les 4 versions de la "subspace iteration method" 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUELQUES VALEURS PAR DÉFAUT DE PARAMÈTRES,
% VALEURS QUE VOUS DEVEZ FAIRE ÉVOLUER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tolérance
eps = 1e-8;
% nombre d'itérations max pour atteindre la convergence
maxit = 10000;

% taille de l'espace de recherche (m)
search_space = 400;

% pourcentage que l'on se fixe
percentage = 0.999;

% p pour les versions 2 et 3 (attention p déjà utilisé comme taille)
puiss = 1;
%%%%%%%%%%%%%
% À COMPLÉTER
%%%%%%%%%%%%%

%%
% calcul des couples propres : décommenter la fonction désirée
%%
A = I'*I;
%[V,S] = power_v12(A,search_space,eps,maxit,percentage);
%[V,S] = subspace_iter_v0(A,search_space,eps,maxit,percentage);
%[V,S] = subspace_iter_v1(A,search_space,eps,maxit,percentage,puiss);
%[V,S] = subspace_iter_v2(A,search_space,eps,maxit,percentage,puiss);
%[V,S] = subspace_iter_v3(A,search_space,eps,maxit,percentage,puiss);
[V,S] = eig(A);
[S,ind] = sort(diag(S),'descend');
S = diag(S);
V = V(:,ind);
V = V(:,1:200);
S = S(1:200,1:200);
%%
% calcul des valeurs singulières
%%
sigma = sqrt(S);
%%
% calcul de l'autre ensemble de vecteurs
%%
U = zeros(size(I,1),size(V,2));
U = (I*V)*inv(sigma);
% calcul des meilleures approximations de rang faible
%%
td = 0;
for k = inter

    % Calcul de l'image de rang k
    Im_k = U(:, 1:k)*sigma(1:k, 1:k)*V(:, 1:k)';

    % Affichage de l'image reconstruite
    ti = ti+1;
    figure(ti)
    colormap('gray')
    imagesc(Im_k), axis equal
    
    % Calcul de la différence entre les 2 images (RMSE : Root Mean Square Error)
    td = td + 1;
    differencevp(td) = sqrt(sum(sum((I-Im_k).^2)));

end
% Figure des différences entre l'image réelle et les images reconstruites
ti = ti+1;
figure(ti)
hold on 
plot(inter, differenceSVD, 'rx')
ylabel('RMSE')
xlabel('rank k')