%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projet Telecommunications : Codage Canal
% Comparaison des performances des deux codages et décodages
% Auteur: BALOT Louise VIGNAUX Adrien
% Groupe: M
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe=12000;       %Fréquence d'échantillonnage
Te=1/Fe;        %Période d'échantillonnage
Rb=3000;        %Débit binaire souhaité
N=20;         %Nombre de bits générés

M= 2;         %Ordre de la modulation(BPSK est binaire donc M=2)
Rs= Rb;         %Débit symbole
Ns=1/(Rs*Te);         %Facteur de suréchantillonnage

k=4;          %Nombre de bits par mot d'information
n=7;          %Nombre de bits par mot codé
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
    nb_erreurs_Hamming=0; %Variable permettant de compter le nombre d'erreurs cumulées pour le codage Hamming
    nb_erreurs_Convo=0;   %Variable permettant de compter le nombre d'erreurs cumulées pour le codage Convolutif
    nb_cumul=0;     %Variables permettant de compter le nombre de cumuls réalisés
    TES_BPSK_Hamming=0;          %Initialisation du TES pour le cumul
    TES_BPSK_Convo=0;   %Initialisation du TES souple pour le cumul
    TEB_BPSK_Hamming=0;          %Initialisation du TEB pour le cumul
    TEB_BPSK_Souple_Hamming=0;   %Initialisation du TEB souple pour le cumul
    TEB_BPSK_Convo=0;          %Initialisation du TEB pour le cumul
    TEB_BPSK_Souple_Convo=0;   %Initialisation du TEB souple pour le cumul
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BOUCLE POUR PRECISION TES ET TEBS MESURES :COMPTAGE NOMBRE ERREURS
    % (voir annexe texte TP)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(nb_erreurs<100)

        if nb_cumul > 100000
            if nb_erreurs < 100
                break;
            end
        end

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %GENERATION DE L'INFORMATION BINAIRE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %bits=randi([0,1],1,N);
        %bits=reshape(bits,k,N/k)'; %Reshape pour avoir 250 mots de 4 bits

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Codage
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Codage Hamming
        bits_Hamming = reshape(bits,N/k,k); %Reshape pour avoir 250 mots de 4 bits
        Codes = mod(bits_Hamming*G,2); %Codage de la séquence d'information
        Codes= Codes(:)';
        B_vect = B(:)';

        % Codage Convolutif
        bits_codage = [0 0 bits]; %intialisation pour le codage
        code = []; %Initialisation du code vide

        for i=3:N + 2
            code = [code, bits_codage(i) + bits_codage(i-2), bits_codage(i) + bits_codage(i-1) + bits_codage(i-2)];
            
        end
        code = mod(code, 2);

        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        symboles_BPSK_Hamming= 2*Codes-1; %Mapping BPSK
        symboles_dico = 2.*B_vect-1;
        symboles_BPSK_Convo= 2*code-1; %Mapping BPSK

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SURECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        somme_Diracs_ponderes_BPSK_Hamming=kron(symboles_BPSK_Hamming,[1 zeros(1,Ns-1)]);
        somme_Diracs_ponderes_BPSK_Convo=kron(symboles_BPSK_Convo,[1 zeros(1,Ns-1)]);
        somme_Diracs_ponderes_dico=kron(symboles_dico,[1 zeros(1,Ns-1)]);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE MISE EN FORME
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Génération de la réponse impulsionnelle du filtre de mise en forme
        h=  ones(1,Ns);
        %Filtrage de mise en forme
        Signal_emis_BPSK_Hamming=filter(h,1,somme_Diracs_ponderes_BPSK_Hamming);
        Signal_emis_BPSK_Convo=filter(h,1,somme_Diracs_ponderes_BPSK_Convo);
        Signal_emis_dico=filter(h,1,somme_Diracs_ponderes_dico);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CANAL DE PROPAGATION AWGN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %POUR MODULATION BPSK
        %Calcul de la puissance du signal émis
        P_signal_Hamming= mean(abs(Signal_emis_BPSK_Hamming).^2);
        P_signal_Convo= mean(abs(Signal_emis_BPSK_Convo).^2);

        %Calcul de la puissance du bruit à ajouter au signal pour obtenir la valeur
        %souhaité pour le SNR par bit à l'entrée du récepteur (Eb/N0)
        P_bruit_Hamming= (P_signal_Hamming*Ns)/(2*log2(M)*Eb_N0);
        P_bruit_Convo= (P_signal_Convo*Ns)/(2*log2(M)*Eb_N0);
        %Génération du bruit gaussien à la bonne puissance en utilisant la fonction
        %randn de Matlab
        Bruit_Hamming=sqrt(P_bruit_Hamming)*(randn(1,length(Signal_emis_BPSK_Hamming)));
        Bruit_Convo=sqrt(P_bruit_Convo)*(randn(1,length(Signal_emis_BPSK_Convo)));
        %Bruit =0;
        %Ajout du bruit canal au signal émis => signal à l'entrée du récepteur
        Signal_recu_BPSK_Hamming=Signal_emis_BPSK_Hamming+Bruit_Hamming;
        Signal_recu_BPSK_Convo=Signal_emis_BPSK_Convo+Bruit_Convo;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE RECEPTION ADAPTE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Réponse impulsionnelle du filtre de réception
        hr= ones(1,Ns);
        %Filtrage de réception
        Signal_recu_filtre_BPSK_Hamming=filter(hr,1,Signal_recu_BPSK_Hamming);
        Signal_recu_filtre_BPSK_Convo=filter(hr,1,Signal_recu_BPSK_Convo);
        Signal_recu_filtre_dico=filter(hr,1,Signal_emis_dico);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Choix de n0
        n0=Ns;
        %Echantillonnage à n0+mNs
        Signal_echantillonne_BPSK_Hamming=Signal_recu_filtre_BPSK_Hamming(n0:Ns:end);
        Signal_echantillonne_BPSK_Convo=Signal_recu_filtre_BPSK_Convo(n0:Ns:end);
        Signal_echantillonne_dico=Signal_recu_filtre_dico(n0:Ns:end);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Decodage Souple
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % DECODAGE SOUPLE BPSK Hamming
        bits_recus_BPSK_souple_Hamming=zeros(N/k,k);
        Signal_echantillonne_BPSK_Hamming=reshape(Signal_echantillonne_BPSK_Hamming,N/k,n);
        Signal_echantillonne_dico=reshape(Signal_echantillonne_dico,2^k,n);
        for i=1:N/k
            %Calcul de la distance de Hamming entre le mot reçu et tous les mots codés possibles
            distances_souple= zeros(1,2^k);
            for j=1:2^k
                distances_souple(j) = norm(Signal_echantillonne_BPSK_Hamming(i,:) - Signal_echantillonne_dico(j,:));
            end
            [mini,indmin] = min(distances_souple);
            bits_recus_BPSK_souple_Hamming(i,:)= T(indmin,:);
        end
        bits_recus_BPSK_souple_Hamming=bits_recus_BPSK_souple_Hamming(:);
        Signal_echantillonne_BPSK_Hamming=Signal_echantillonne_BPSK_Hamming(:).';

        % DECODAGE SOUPLE BPSK Viterbi
        poids_souple = [0 36 36 36];
        chemin_souple = zeros(4,N); %Initialisation du tableau de chemin
        chemin_partiel_souple = zeros(4,N); %Initialisation du tableau de chemin partiel
        dico_symb = [ -1, -1; 1, 1; -1, 1; 1, -1; 1, 1; -1, -1; 1, -1; -1, 1]; %Dictionnaire des codes

        signal_souple = Signal_echantillonne_BPSK_Convo/mean(abs(Signal_echantillonne_BPSK_Convo));

        for i = 1:2:numel(signal_souple)
            code_courant_souple = signal_souple(i:i+1); %On prend 2 bits à la fois

            distance_souple = zeros(1,8); %On réinitialise le tableau de distance
            for j = 1:8
                distance_souple(j) = sum((code_courant_souple - dico_symb(j,:)).^2);
            end

            poids_totaux_souple = repmat(poids_souple,1,2) + distance_souple;
            v = 1;
            for j = 1:4
                tab_poids = [poids_totaux_souple(v), poids_totaux_souple(v+1)];
                [poids_min, ind_min] = min(tab_poids);
                poids_souple(j) = poids_min;

                if (j==1 || j==3)
                    chemin_partiel_souple(j,:) = chemin_souple(ind_min,:);
                    chemin_partiel_souple(j,(i+1)/2) = ind_min;
                else
                    chemin_partiel_souple(j,:) = chemin_souple(ind_min+2,:);
                    chemin_partiel_souple(j,(i+1)/2) = ind_min+2;
                end
                v = v+2;
            end
            %On met à jour le tableau de chemin
            chemin_souple = chemin_partiel_souple;

        end
        
        %On récupère le chemin le plus court
        [~, ind_min_final_souple] = min(poids_souple);
        chemin_final_souple = [chemin_souple(ind_min_final_souple,:) ind_min_final_souple];
        chemin_final_souple = chemin_final_souple(2:end); %On enlève le premier bit qui est toujours 0


        %On récupère les bits du chemin final
        bits_recus_BPSK_souple_Convo = sign(chemin_final_souple - 2.5);
        bits_recus_BPSK_souple_Convo = (bits_recus_BPSK_souple_Convo + 1)/2;



        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECISIONS SUR LES SYMBOLES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles_recus_BPSK_Hamming=sign(Signal_echantillonne_BPSK_Hamming);
        symboles_recus_BPSK_Convo=sign(Signal_echantillonne_BPSK_Convo);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR SYMBOLE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TES_BPSK_Hamming=TES_BPSK_Hamming + numel(find(symboles_BPSK_Hamming ~= symboles_recus_BPSK_Hamming))/numel(symboles_BPSK_Hamming);
        TES_BPSK_Convo=TES_BPSK_Convo + numel(find(symboles_BPSK_Convo ~= symboles_recus_BPSK_Convo))/numel(symboles_BPSK_Convo);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DEMAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Codes_recus_BPSK_Hamming=(1+symboles_recus_BPSK_Hamming)/2; %Demapping BPSK
        Codes_recus_BPSK_Convo=(1+symboles_recus_BPSK_Convo)/2; %Demapping BPSK

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECODAGE DUR
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % DECODAGE DUR BPSK Hamming
        Codes_recus_BPSK_Hamming=reshape(Codes_recus_BPSK_Hamming,N/k,n);
        bits_recus_BPSK_Hamming=zeros(N/k,k);
        for i=1:N/k
            %Calcul de la distance de Hamming entre le mot reçu et tous les mots codés possibles
            distances= zeros(1,2^k);
            for j=1:2^k
                distances(j)=numel(find(mod(Codes_recus_BPSK_Hamming(i,:) + B(j,:), 2) == 1));
            end
            [mini,indmin] = min(distances);
            bits_recus_BPSK_Hamming(i,:)=T(indmin,:);
        end
        bits_recus_BPSK_Hamming=bits_recus_BPSK_Hamming(:);
        bits_Hamming = bits_Hamming(:);

        % DECODAGE DUR BPSK Viterbi
        poids = [0 8 8 8];
        chemin = zeros(4,N); %Initialisation du tableau de chemin
        chemin_partiel = zeros(4,N); %Initialisation du tableau de chemin partiel
        dico_bits = [0 0; 1 1; 0 1; 1 0; 1 1; 0 0; 1 0; 0 1]; %Dictionnaire des codes
        distance = zeros(1,8); %Initialisation du tableau de distance
        for i = 1:2:numel(Codes_recus_BPSK_Convo)
            code_courant = Codes_recus_BPSK_Convo(i:i+1); %On prend 2 bits à la fois

            distance = zeros(1,8); %On réinitialise le tableau de distance
            for j = 1:8
                distance(j) = sum(abs(code_courant - dico_bits(j,:)));
            end

            poids_totaux = [poids poids] + distance;
            v = 1;
            for j = 1:4
                tab_poids = [poids_totaux(v), poids_totaux(v+1)];
                [poids_min, ind_min] = min(tab_poids);
                poids(j) = poids_min;

                if (j==1 || j==3)
                    chemin_partiel(j,:) = chemin(ind_min,:);
                    chemin_partiel(j,(i+1)/2) = ind_min;
                else
                    chemin_partiel(j,:) = chemin(ind_min+2,:);
                    chemin_partiel(j,(i+1)/2) = ind_min+2;
                end
                v = v+2;
            end
            %On met à jour le tableau de chemin
            chemin = chemin_partiel;

        end
        
        %On récupère le chemin le plus court
        [~, ind_min_final] = min(poids);
        chemin_final = [chemin(ind_min_final,:) ind_min_final];
        chemin_final = chemin_final(2:end); %On enlève le premier bit qui est toujours 0


        %On récupère les bits du chemin final
        bits_recus_BPSK_Convo = sign(chemin_final - 2.5);
        bits_recus_BPSK_Convo = (bits_recus_BPSK_Convo + 1)/2;


        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR BINAIRE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TEB_BPSK_Hamming=TEB_BPSK_Hamming+numel(find(bits.' ~= bits_recus_BPSK_Hamming))/numel(bits);
        TEB_BPSK_Convo=TEB_BPSK_Convo+numel(find(bits ~= bits_recus_BPSK_Convo))/numel(bits);
        TEB_BPSK_Souple_Hamming =TEB_BPSK_Souple_Hamming+numel(find(bits.' ~= bits_recus_BPSK_souple_Hamming))/numel(bits);
        TEB_BPSK_Souple_Convo =TEB_BPSK_Souple_Convo+numel(find(bits ~= bits_recus_BPSK_souple_Convo))/numel(bits);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CUMUL DU NOMBRE D'ERREURS ET NOMBRE DE CUMUL REALISES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nb_erreurs_Hamming= nb_erreurs+numel(find(bits ~= bits_recus_BPSK_Hamming));
        nb_erreurs_Convo= nb_erreurs+numel(find(bits ~= bits_recus_BPSK_Convo));
        nb_erreurs=min(nb_erreurs_Hamming, nb_erreurs_Convo);
        nb_cumul=nb_cumul+1;

    end  %fin boucle sur comptage nombre d'erreurs

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CALCUL DU TAUX D'ERREUR SYMBOLE ET DU TAUX D'ERREUR BINAIRE POUR LA
    %VALEUR TESTEE DE Eb/N0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TES_simule_BPSK_Hamming(indice_bruit)=TES_BPSK_Hamming/nb_cumul;
    TES_simule_BPSK_Convo(indice_bruit)=TES_BPSK_Convo/nb_cumul;
    TEB_simule_BPSK_Hamming(indice_bruit)=TEB_BPSK_Hamming/nb_cumul;
    TEB_simule_BPSK_Convo(indice_bruit)=TEB_BPSK_Convo/nb_cumul;
    TEB_simule_BPSK_Souple_Hamming(indice_bruit)=TEB_BPSK_Souple_Hamming/nb_cumul;
    TEB_simule_BPSK_Souple_Convo(indice_bruit)=TEB_BPSK_Souple_Convo/nb_cumul;

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
semilogy(tab_Eb_N0_dB, TES_simule_BPSK_Hamming,'b-o')
legend('TES théorique BPSK','TES simulé BPSK')
xlabel('E_b/N_0 (dB)')
ylabel('TES')

figure
semilogy(tab_Eb_N0_dB, TEB_THEO_BPSK,'r-x')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK_Hamming,'g-o')
legend('TES théorique BPSK','TES simulé BPSK Convolutif')
xlabel('E_b/N_0 (dB)')
ylabel('TES')

figure
semilogy(tab_Eb_N0_dB, TEB_THEO_BPSK,'r-x')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK_Hamming,'b-o')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK_Convo,'g-o')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK_Souple_Hamming,'m-o')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule_BPSK_Souple_Convo,'c-o')
legend('TEB théorique BPSK','TEB simulé dur BPSK Hamming', 'TEB simulé dur BPSK Convolutif', 'TEB simulé souple Hamming', 'TEB simulé souple Convolutif')
xlabel('E_b/N_0 (dB)')
ylabel('TEB')