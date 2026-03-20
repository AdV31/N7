% Ce programme est le script principal permettant d'illustrer
% un algorithme de reconnaissance de chiffres.

% Nettoyage de l'espace de travail
clear all; close all;

% Repertories contenant les donnees et leurs lectures
addpath('Data');
addpath('Utils')

rng('shuffle')


% Bruit
sig0=0.2;

%tableau des csores de classification
% intialisation al�atoire pour affichage
r=rand(6,5);
r2=rand(6,5);

for k=1:5
% Definition des donnees
file=['D' num2str(k)];

% Recuperation des donnees
sD=load(file);
D=sD.(file);
%

% Bruitage des donn�es
Db= D+sig0*randn(size(D));


%%%%%%%%%%%%%%%%%%%%%%%
% Analyse des donnees
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
PrecApprox=0.9;
n = size(Db, 1);
ni = size(Db, 2);
x_bar=mean(Db,2);
Db_centre=Db-x_bar;
sigma = (1/n)*(Db_centre*Db_centre');
[V, D] = eig(sigma);
[D, ind] = sort(diag(D), 'descend');
V = V(:, ind);
d1 = D(1);
t = 1;
while D(t) > d1*(1 - PrecApprox)^2
    t = t + 1;
end
U = V(:, 1:t);
D = D(1:t);

%%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
K = zeros(ni,ni);
for i = 1:ni
  x_i = Db(:,i);
    for j = 1:ni
      x_j = Db(:,j);
        K(i,j) = noyau(x_i, x_j);
    end
end
I_N = ones(ni, ni)*(1/ni);
K_tilde = K - I_N*K - K*I_N + I_N*K*I_N;

[V2, D2] = eig(K_tilde);
[D2, ind2] = sort(diag(D2), 'descend');
V2 = V2(:, ind2);
d1 = D2(1);
t = 1;
while D2(t) > d1*(1 - PrecApprox)^2
    t = t + 1;
end
U2 = V2(:, 1:t);
D2 = D2(1:t);
alpha = zeros(ni,t);
for i = 1:t
    alpha(:,i) = U2(:,i)*sqrt(D2(i));
end



%%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconnaissance de chiffres
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Lecture des chiffres � reconnaitre
 tes(:,1) = importerIm('test1.jpg',1,1,16,16);
 tes(:,2) = importerIm('test2.jpg',1,1,16,16);
 tes(:,3) = importerIm('test3.jpg',1,1,16,16);
 tes(:,4) = importerIm('test4.jpg',1,1,16,16);
 tes(:,5) = importerIm('test5.jpg',1,1,16,16);
 tes(:,6) = importerIm('test9.jpg',1,1,16,16);


 for tests=1:6
    % Bruitage
    tes(:,tests)=tes(:,tests)+sig0*randn(length(tes(:,tests)),1);
    
    % Classification depuis ACP
     %%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
     
     I = eye(n);
     d = norm((I -( U*U'))*(tes(:,tests)-x_bar))/norm(tes(:,tests)-x_bar);
     r(tests,k) = d;
     if(tests==k)
       figure(100+k)
       subplot(1,2,1);
       imshow(reshape(tes(:,tests),[16,16]));
       subplot(1,2,2);
       C = x_bar + U*U'*(tes(:,tests)-x_bar);
       imshow(reshape(C,[16,16]));
     end
    %%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%
  
   % Classification depuis kernel ACP
     %%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%
     x = tes(:,tests);
     s = 0;
     for i = 1:ni
       x_i = Db(:,i);
       k_xi = noyau(x,x_i);
        s = s + k_xi;
     end
     
     norm_pas_proj = noyau(x,x)+ (1/(ni^2))*sum(sum(K)) - (2/ni)*s;

     v_x = zeros(ni,1);
     for i = 1:ni
       x_i = Db(:,i);
       v_x(i) = noyau(x,x_i);
     end

     P_x = zeros(t,1);
     for j =1:t
      P_x(j) = alpha(:,j)'*v_x;
     end

     v_barre = zeros(ni,1);
     for i = 1:ni
       x_i = Db(:,i);
       for j = 1:ni
        x_j = Db(:,j);
         v_barre(i) = v_barre(i) + noyau(x_j,x_i);
       end
       v_barre(i) = v_barre(i)/ni;
      end
     P_barre = zeros(t,n);
     for j =1:t
       P_barre(j) = alpha(:,j)'*v_barre;
     end

     beta_p = zeros(ni,1);
     for j = 1:t
       beta_p = beta_p + (P_x(j) - P_barre(j))*alpha(:,j);
     end

     beta_p = beta_p/(10e+4);
     norm_proj = (beta_p')*K*beta_p

     d2 = sqrt(1 - norm_proj/norm_pas_proj);
     r2(tests,k) = d2;
    %%%%%%%%%%%%%%%%%%%%%%%%% FIN TO DO %%%%%%%%%%%%%%%%%%
 end
 
end


% Affichage du r�sultat de l'analyse par PCA
couleur = hsv(6);
figure(11)
for tests=1:6
     hold on
     plot(1:5, r(tests,:),  '+', 'Color', couleur(tests,:));
     hold off
 
     for i = 1:4
        hold on
         plot(i:0.1:(i+1),r(tests,i):(r(tests,i+1)-r(tests,i))/10:r(tests,i+1), 'Color', couleur(tests,:),'LineWidth',2)
         hold off
     end
     hold on
     if(tests==6)
       testa=9;
     else
       testa=tests;
     end
     text(5,r(tests,5),num2str(testa));
     hold off
 end

% Affichage du r�sultat de l'analyse par kernel PCA
figure(12)
for tests=1:6
     hold on
     plot(1:5, r2(tests,:),  '+', 'Color', couleur(tests,:));
     hold off
 
     for i = 1:4
        hold on
         plot(i:0.1:(i+1),r2(tests,i):(r2(tests,i+1)-r2(tests,i))/10:r2(tests,i+1), 'Color', couleur(tests,:),'LineWidth',2)
         hold off
     end
     hold on
     if(tests==6)
       testa=9;
     else
       testa=tests;
     end
     text(5,r2(tests,5),num2str(testa));
     hold off
end



function kern = noyau(x,y)
  kern = x'*y;
end
