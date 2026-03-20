close all;
clear all;

load mat3;

n = size(A,1);

%%%%% Analyse

% 1. Matrice Originale

% affichage de la structure de la matrice originale
subplot(2, 3, 1);
spy(A);
title('Original matrix A');

% factorisation symbolique de la matrice originale
[count, h, parent, post, R] = symbfact(A);
ALU = R+R';

% affichage de la structure des facteurs de la matrice originale
subplot(2, 3, 2)
spy(ALU);
title('Factors of A')
fillin = nnz(ALU) - nnz(A)

% visualisation du fill-in
A_ones = spones(A);
ALU_ones = spones(ALU);
FILL = ALU_ones - A_ones;
subplot(2, 3, 3)
spy(FILL)
title('Fill on A')

% 2. Matrice Permutée

% Aucune
%P = [1:n];
%minimum degree
%P = amd(A);
%column approximate minimum degree
%P = colamd(A);
%minimum degree symétrique
%P = symamd(A);
%reverse Cuthill-McKee
%P = symrcm(A);
%column permutation basée sur le nombre de non-zéros
P = colperm(A);
%Nested dissection
%P = dissect(A);
%Dulmage-Mendelsohn permutation
%P = dmperm(A);

B = A(P, P);
% affichage de la structure de la matrice permutée
subplot(2, 3, 4)
spy(B);
title('Permuted matrix B');

% factorisation symbolique de la matrice permutée
[count, h, parent, post, R] = symbfact(B);

% affichage de la structure des facteurs de la matrice permutée
BLU = R+R';
subplot(2, 3, 5)
spy(BLU);
title('Factors of B')
fillin = nnz(BLU) - nnz(A)

% visualisation du fill-in
B_ones = spones(B);
BLU_ones = spones(BLU);
FILLB = BLU_ones - B_ones;
subplot(2, 3, 6)
spy(FILLB);
title('Fill on B')

%%%%% Factorisation

L = chol(B);
figure;
spy(L);
%%%%% Résolution

b = [1:n]';
b = b(P);

y = L'\b;

x = L\y;
x(P) = x;
b(P) = b;

norm(A*x - b)/norm(b)