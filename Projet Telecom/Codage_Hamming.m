clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe=12000;       %Fréquence d'échantillonnage
Te=1/Fe;        %Période d'échantillonnage
Rb=3000;        %Débit binaire souhaité
N=1000;         %Nombre de bits générés

M= 2;         %Ordre de la modulation(BPSK est binaire donc M=2)
Rs= Rb;         %Débit symbole
Ns=1/(Rs*Te);         %Facteur de suréchantillonnage

k=4;          %Nombre de bits par mot d'information
n=7;          %Nombre de bits par mot codé
Rs2=Rs*k/n; %Débit symbole
Ns2 = floor(1/((floor(Rs2))*Te));
P = [1 0 1 ; 1 1 1; 1 1 0; 0 1 1];
G = [eye(k) P]; %Matrice de codage

T = zeros(2^k,k);
for i =1:k^2
    T(i,:)= int2bit(i-1,k);
end
B = mod(T*G,2);

H = [P' eye(n-k)];

%tableau des valeurs de SNR par bit souhaité à l'entrée du récpeteur en dB
tab_Eb_N0_dB=[0:6];
%Passage au SNR en linéaire
tab_Eb_N0=10.^(tab_Eb_N0_dB/10);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GENERATION DE L'INFORMATION BINAIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Lecture de l'image
image = imread('dcode-image.png');
%Visualisation
figure
imshow(image)
%Transformation de l'image en un train binaire
vect_image=reshape(image,1,size(image,1)*size(image,2));
mat_image_binaire=de2bi(vect_image);
bits=double(reshape(mat_image_binaire,1,size(mat_image_binaire,1)*size(mat_image_binaire,2)));
N = numel(bits);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BOUCLE SUR LES NIVEAUX DE Eb/N0 A TESTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for indice_bruit=1:length(tab_Eb_N0_dB)

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VALEUR DE Eb/N0 TESTEE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Eb_N0_dB=tab_Eb_N0_dB(indice_bruit)
    Eb_N0=tab_Eb_N0(indice_bruit);

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INITIALISATIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nb_erreurs=0;   %Variable permettant de compter le nombre d'erreurs cumulées
    nb_cumul=0;     %Variables permettant de compter le nombre de cumuls réalisés
    TES_BPSK=0;          %Initialisation du TES pour le cumul
    TEB_BPSK=0;          %Initialisation du TEB pour le cumul
    TEB_BPSK_Souple=0;   %Initialisation du TEB souple pour le cumul
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BOUCLE POUR PRECISION TES ET TEBS MESURES :COMPTAGE NOMBRE ERREURS
    % (voir annexe texte TP)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(nb_erreurs<100)

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %GENERATION DE L'INFORMATION BINAIRE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %bits=randi([0,1],1,N);
        bits=reshape(bits,k,N/k)'; %Reshape pour avoir 250 mots de 4 bits

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Codage
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Codes = mod(bits*G,2); %Codage de la séquence d'information
        Codes= Codes(:)';
        B_vect = B(:)';
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        symboles_BPSK= 2*Codes-1; %Mapping BPSK
        symboles_dico = 2.*B_vect-1;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SURECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        somme_Diracs_ponderes_BPSK=kron(symboles_BPSK,[1 zeros(1,Ns-1)]);
        somme_Diracs_ponderes_utile=kron(symboles_BPSK,[1 zeros(1,Ns2-1)]);
        somme_Diracs_ponderes_dico=kron(symboles_dico,[1 zeros(1,Ns-1)]);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE MISE EN FORME
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Génération de la réponse impulsionnelle du filtre de mise en forme
        h=  ones(1,Ns);
        %Filtrage de mise en forme
        Signal_emis_BPSK=filter(h,1,somme_Diracs_ponderes_BPSK);
        Signal_emis_utile=filter(h,1,somme_Diracs_ponderes_utile);
        Signal_emis_dico=filter(h,1,somme_Diracs_ponderes_dico);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CANAL DE PROPAGATION AWGN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %POUR MODULATION BPSK
        %Calcul de la puissance du signal émis en 4-ASK
        P_signal= mean(abs(Signal_emis_BPSK).^2);

        %Calcul de la puissance du bruit à ajouter au signal pour obtenir la valeur
        %souhaité pour le SNR par bit à l'entrée du récepteur (Eb/N0)
        P_bruit= (P_signal*Ns)/(2*log2(M)*Eb_N0);
        %Génération du bruit gaussien à la bonne puissance en utilisant la fonction
        %randn de Matlab
        Bruit=sqrt(P_bruit)*(randn(1,length(Signal_emis_BPSK)));
        %Bruit =0;
        %Ajout du bruit canal au signal émis => signal à l'entrée du récepteur
        Signal_recu_BPSK=Signal_emis_BPSK+Bruit;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE RECEPTION ADAPTE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Réponse impulsionnelle du filtre de réception
        hr= ones(1,Ns);
        %Filtrage de réception
        Signal_recu_filtre_BPSK=filter(hr,1,Signal_recu_BPSK);
        Signal_recu_filtre_dico=filter(hr,1,Signal_emis_dico);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Choix de n0
        n0=Ns;
        %Echantillonnage à n0+mNs
        Signal_echantillonne_BPSK=Signal_recu_filtre_BPSK(n0:Ns:end);
        Signal_echantillonne_dico=Signal_recu_filtre_dico(n0:Ns:end);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Decodage Souple
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        bits_recus_BPSK_souple=zeros(N/k,k);
        Signal_echantillonne_BPSK=reshape(Signal_echantillonne_BPSK,N/k,n);
        Signal_echantillonne_dico=reshape(Signal_echantillonne_dico,2^k,n);
        for i=1:N/k
            %Calcul de la distance de Hamming entre le mot reçu et tous les mots codés possibles
            distances_souple= zeros(1,2^k);
            for j=1:2^k
                distances_souple(j) = norm(Signal_echantillonne_BPSK(i,:) - Signal_echantillonne_dico(j,:));
            end
            [mini,indmin] = min(distances_souple);
            bits_recus_BPSK_souple(i,:)= T(indmin,:);
        end
        bits_recus_BPSK_souple=bits_recus_BPSK_souple(:);
        Signal_echantillonne_BPSK=Signal_echantillonne_BPSK(:).';

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECISIONS SUR LES SYMBOLES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles_recus_BPSK=sign(Signal_echantillonne_BPSK);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR SYMBOLE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TES_BPSK=TES_BPSK + numel(find(symboles_BPSK ~= symboles_recus_BPSK))/numel(symboles_BPSK);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DEMAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Codes_recus_BPSK=(1+symboles_recus_BPSK)/2; %Demapping BPSK

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECODAGE DUR
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Codes_recus_BPSK=reshape(Codes_recus_BPSK,N/k,n);
        bits_recus_BPSK=zeros(N/k,k);
        for i=1:N/k
            %Calcul de la distance de Hamming entre le mot reçu et tous les mots codés possibles
            distances= zeros(1,2^k);
            for j=1:2^k
                distances(j)=numel(find(mod(Codes_recus_BPSK(i,:) + B(j,:), 2) == 1));
            end
            [mini,indmin] = min(distances);
            bits_recus_BPSK(i,:)=T(indmin,:);
        end
        bits_recus_BPSK=bits_recus_BPSK(:);
        bits = bits(:);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR BINAIRE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TEB_BPSK=TEB_BPSK+numel(find(bits ~= bits_recus_BPSK))/numel(bits);
        TEB_BPSK_Souple =TEB_BPSK_Souple+numel(find(bits ~= bits_recus_BPSK_souple))/numel(bits);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CUMUL DU NOMBRE D'ERREURS ET NOMBRE DE CUMUL REALISES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nb_erreurs=nb_erreurs+numel(find(bits ~= bits_recus_BPSK));
        nb_cumul=nb_cumul+1;

    end  %fin boucle sur comptage nombre d'erreurs

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CALCUL DU TAUX D'ERREUR SYMBOLE ET DU TAUX D'ERREUR BINAIRE POUR LA
    %VALEUR TESTEE DE Eb/N0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TES_simule_BPSK(indice_bruit)=TES_BPSK/nb_cumul;
    TEB_simule_BPSK(indice_bruit)=TEB_BPSK/nb_cumul;
    TEB_simule_BPSK_Souple(indice_bruit)=TEB_BPSK_Souple/nb_cumul;


end  %fin boucle sur les valeurs testées de Eb/N0

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TESs THEORIQUES CHAINES IMPLANTEES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TES_THEO_BPSK= 2*((M - 1)/M)*qfunc(sqrt((6*log2(M)*tab_Eb_N0)/(M^2 - 1)));
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TEBs THEORIQUES CHAINES IMPLANTEES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TEB_THEO_BPSK=TES_THEO_BPSK/log2(M);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DSP SIMULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DSP_simule = pwelch(Signal_emis_utile,[],[],[],Fe,"twosided");
taille = numel(DSP_simule);
freq = 0:Fe/taille:(taille-1)*Fe/taille;
maxi = max(DSP_simule);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DSP THEORIQUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ts = 1/Rs;
DSP_theorique = pwelch(Signal_emis_BPSK,[],[],[],Fe,"twosided");
taille2 = numel(DSP_theorique);
freq2 = 0:Fe/taille2:(taille2-1)*Fe/taille2;
maxt = max(DSP_theorique);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RECUPERATION DE L'IMAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reconstruction de l'image à partir de la suite binaire
mat_image_binaire_retrouvee=reshape(bits_recus_BPSK_souple,211*300,8);
mat_image_decimal_retrouvee=bi2de(mat_image_binaire_retrouvee);
image_retrouvee=reshape(mat_image_decimal_retrouvee,211,300);
%Visualisation
figure
imshow(uint8(image_retrouvee))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TRACES DES TES ET TEB OBTENUS EN FONCTION DE Eb/N0
%COMPARAISON AVEC LES TES et TEBs THEORIQUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
semilogy(tab_Eb_N0_dB, TES_THEO_BPSK,'r-x')
hold on
semilogy(tab_Eb_N0_dB, TES_simule_BPSK,'b-o')
legend('TES théorique BPSK','TES simulé BPSK')
xlabel('E_b/N_0 (dB)')
ylabel('TES')

figure
semilogy(tab_Eb_N0_dB, TEB_THEO_BPSK,'r-x')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK,'b-o')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK_Souple,'g-o')
legend('TEB théorique BPSK','TEB simulé dur BPSK', 'TEB simulé souple BPSK')
xlabel('E_b/N_0 (dB)')
ylabel('TEB')

figure
semilogy(freq, fftshift(DSP_simule)/maxi,'r')
title('DSP simule BPSK')
xlabel("Frequence (Hz)")
ylabel("DSP")

figure
semilogy(freq2, fftshift(DSP_theorique)/maxt,'b')
title('DSP théorique BPSK')
xlabel("Frequence (Hz)")
ylabel("DSP")