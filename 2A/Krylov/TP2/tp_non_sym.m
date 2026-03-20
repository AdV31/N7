close all;
clear all;

load hydcar20;

n = size(A,1);

%%%%% Factorisation

subplot(2,4,1);
spy(A);
title('Original matrix A');
 
% 2. Matrice Permutée

% Aucune
P = [1:n];
%minimum degree
%P = amd(A);
%column approximate minimum degree
%P = colamd(A);
%minimum degree symétrique
%P = symamd(A);
%reverse Cuthill-McKee
%P = symrcm(A);
%column permutation basée sur le nombre de non-zéros
%P = colperm(A);
%Nested dissection
%P = dissect(A);
%Dulmage-Mendelsohn permutation
%P = dmperm(A);

% Permutation symetrique de la matrice
B = A(P, P);

% Permutation des colonnes de la matrice
%B = A(:,P);

% affichage de la structure de la matrice permutée
subplot(2,4,5)
spy(B);
title('Permuted matrix B');


[L, U, Pn] = lu(A);
subplot(2,4,2)
spy(Pn*A);
title('Pn*A');

subplot(2,4,3)
ALU = L+U;
spy(ALU);
title('Factors of Pn*A')

[L_B, U_B, Pn_B] = lu(B);
subplot(2,4,6)
spy(Pn_B*B);
title('Pn*B');

subplot(2,4,7)
BLU = L_B+U_B;
spy(BLU);
title('Factors of Pn*B')
fillin = nnz(BLU)-nnz(A)

% visualisation du fill
C = spones(Pn*A);
CLU = spones(ALU);
FILLA = CLU-C;
subplot(2,4,4)
spy(FILLA)
title('Fill on Pn*A')

C = spones(Pn_B*B);
CLU = spones(BLU);
FILLB = CLU-C;
subplot(2,4,8)
spy(FILLB)
title('Fill on Pn*B')

%%%%% Résolution

b = [1:n]';

d = Pn_B*b;
y = L_B\d;
x = U_B\y;

% Permutation inverse de la solution(pour permutation symetrique et permutation de colonnes)
x(P) = x;
% Permutation inverse de la solution(pour permutation symetrique et permutation de lignes)
b(P) = b;

norm(A*x-b)/norm(b)