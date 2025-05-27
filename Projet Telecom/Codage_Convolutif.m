clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe=12000;       %Fréquence d'échantillonnage
Te=1/Fe;        %Période d'échantillonnage
Rb=3000;        %Débit binaire souhaité
N=10;         %Nombre de bits générés

M= 2;         %Ordre de la modulation(BPSK est binaire donc M=2)
Rs= Rb;         %Débit symbole
Ns=1/(Rs*Te);         %Facteur de suréchantillonnage

%tableau des valeurs de SNR par bit souhaité à l'entrée du récpeteur en dB
tab_Eb_N0_dB=[0:6];
%Passage au SNR en linéaire
tab_Eb_N0=10.^(tab_Eb_N0_dB/10);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GENERATION DE L'INFORMATION BINAIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Lecture de l'image
%image = imread('dcode-image.png');
%%Visualisation
%figure
%imshow(image)
%%Transformation de l'image en un train binaire
%vect_image=reshape(image,1,size(image,1)*size(image,2));
%mat_image_binaire=de2bi(vect_image);
%bits=double(reshape(mat_image_binaire,1,size(mat_image_binaire,1)*size(mat_image_binaire,2)));
%N = numel(bits);

bits = randi([0,1],1,N);

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
        %bits=reshape(bits,k,N/k)'; %Reshape pour avoir 250 mots de 4 bits

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Codage
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits_codage = [0 0 bits]; %intialisation pour le codage
        code = []; %Initialisation du code vide

        for i=3:N + 2
            code = [code, bits_codage(i) + bits_codage(i-2), bits_codage(i) + bits_codage(i-1) + bits_codage(i-2)];
            
        end
        code = mod(code, 2);

        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        symboles_BPSK= 2*code-1; %Mapping BPSK
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SURECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        somme_Diracs_ponderes_BPSK=kron(symboles_BPSK,[1 zeros(1,Ns-1)]);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE MISE EN FORME
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Génération de la réponse impulsionnelle du filtre de mise en forme
        h=  ones(1,Ns);
        %Filtrage de mise en forme
        Signal_emis_BPSK=filter(h,1,somme_Diracs_ponderes_BPSK);
        
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
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Choix de n0
        n0=Ns;
        %Echantillonnage à n0+mNs
        Signal_echantillonne_BPSK=Signal_recu_filtre_BPSK(n0:Ns:end);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Decodage Souple
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        poids_souple = [0 8 8 8];
        chemin_souple = zeros(4,N); %Initialisation du tableau de chemin
        chemin_partiel_souple = zeros(4,N); %Initialisation du tableau de chemin partiel
        precedent_souple = zeros(1,4);
        dico_symb = [ -1, -1; 1,1; -1,1; 1, -1; 1,1; -1, -1; 1, -1; -1,1]; %Dictionnaire des codes

        signal_souple = Signal_echantillonne_BPSK/Ns;

        for i = 1:2:numel(signal_souple)
            code_courant_souple = signal_souple(i:i+1); %On prend 2 bits à la fois

            distance_souple = zeros(1,8); %On réinitialise le tableau de distance
            for j = 1:8
                distance_souple(j) = (code_courant_souple(1) + dico_symb(j,1)).^2 + (code_courant_souple(2) + dico_symb(j,2)).^2;
            end

            poids_totaux_souple = [poids_souple poids_souple] + distance_souple;
            k = 1;
            for j = 1:4
                tab_poids = [poids_totaux_souple(k), poids_totaux_souple(k+1)];
                [poids_min, ind_min] = min(tab_poids);
                poids_souple(j) = poids_min;

                if (j==1 || j==3)
                    chemin_partiel_souple(j,:) = chemin_souple(ind_min,:);
                    chemin_partiel_souple(j,(i+1)/2) = ind_min;
                else
                    chemin_partiel_souple(j,:) = chemin_souple(ind_min+2,:);
                    chemin_partiel_souple(j,(i+1)/2) = ind_min+2;
                end
                k = k+2;
            end
            %On met à jour le tableau de chemin
            chemin_souple = chemin_partiel_souple;

        end
        %On récupère le chemin le plus court
        [~, ind_min_final] = min(poids_souple);
        chemin_final_souple = [chemin_souple(ind_min_final,:) ind_min_final];
        chemin_final_souple = chemin_final_souple(2:end); %On enlève le premier bit qui est toujours 0


        %On récupère les bits du chemin final
        bits_recus_BPSK_souple = sign(chemin_final_souple - 2.5);
        bits_recus_BPSK_souple = (bits_recus_BPSK_souple + 1)/2;



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
        poids = [0 8 8 8];
        chemin = zeros(4,N); %Initialisation du tableau de chemin
        chemin_partiel = zeros(4,N); %Initialisation du tableau de chemin partiel
        precedent = zeros(1,4);
        dico_bits = [0 0; 1 1; 0 1; 1 0; 1 1; 0 0; 1 0; 0 1]; %Dictionnaire des codes
        distance = zeros(1,8); %Initialisation du tableau de distance
        for i = 1:2:numel(Codes_recus_BPSK)
            code_courant = Codes_recus_BPSK(i:i+1); %On prend 2 bits à la fois

            distance = zeros(1,8); %On réinitialise le tableau de distance
            for j = 1:8
                distance(j) = sum(abs(code_courant - dico_bits(j,:)));
            end

            poids_totaux = [poids poids] + distance;
            k = 1;
            for j = 1:4
                tab_poids = [poids_totaux(k), poids_totaux(k+1)];
                [poids_min, ind_min] = min(tab_poids);
                poids(j) = poids_min;

                if (j==1 || j==3)
                    chemin_partiel(j,:) = chemin(ind_min,:);
                    chemin_partiel(j,(i+1)/2) = ind_min;
                else
                    chemin_partiel(j,:) = chemin(ind_min+2,:);
                    chemin_partiel(j,(i+1)/2) = ind_min+2;
                end
                k = k+2;
            end
            %On met à jour le tableau de chemin
            chemin = chemin_partiel;

        end
        %On récupère le chemin le plus court
        [~, ind_min_final] = min(poids);
        chemin_final = [chemin(ind_min_final,:) ind_min_final];
        chemin_final = chemin_final(2:end); %On enlève le premier bit qui est toujours 0


        %On récupère les bits du chemin final
        bits_recus_BPSK = sign(chemin_final - 2.5);
        bits_recus_BPSK = (bits_recus_BPSK + 1)/2;


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
%TEB_THEO_BPSK= qfunc(sqrt(2*tab_Eb_N0));
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DSP SIMULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DSP THEORIQUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RECUPERATION DE L'IMAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Reconstruction de l'image à partir de la suite binaire
%mat_image_binaire_retrouvee=reshape(bits_recus_BPSK_souple,211*300,8);
%mat_image_decimal_retrouvee=bi2de(mat_image_binaire_retrouvee);
%image_retrouvee=reshape(mat_image_decimal_retrouvee,211,300);
%%Visualisation
%figure
%imshow(uint8(image_retrouvee))

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