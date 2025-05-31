%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projet Telecommunications : Codage Canal
% Implantation d'une chaine de transmission BPSK
% Auteur: BALOT Louise VIGNAUX Adrien
% Groupe: M
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe=24000;       %Fréquence d'échantillonnage
Te=1/Fe;        %Période d'échantillonnage
Rb=3000;        %Débit binaire souhaité
N=1000;         %Nombre de bits générés

M= 2;         %Ordre de la modulation(BPSK est binaire donc M=2)
Rs= Rb;         %Débit symbole
Ns=1/(Rs*Te);         %Facteur de suréchantillonnage

%tableau des valeurs de SNR par bit souhaité à l'entrée du récpeteur en dB
tab_Eb_N0_dB=[0:6];
%Passage au SNR en linéaire
tab_Eb_N0=10.^(tab_Eb_N0_dB/10);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BOUCLE SUR LES NIVEAUX DE Eb/N0 A TESTER POUR OBTENTION DU TES ET DU TEB
% SIMULES DE LA CHAINE IMPLANTEE
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
    TES=0;          %Initialisation du taux d'erreur symbole pour le cumul
    TEB=0;          %Initialisation du taux d'erreur binaire pour le cumul

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BOUCLE POUR PRECISION TEB MESURE : COMPTAGE NOMBRE ERREURS
    % (voir annexe texte TP)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(nb_erreurs<100)

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %GENERATION DE L'INFORMATION BINAIRE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits=randi([0,1],1,N);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles= 2*bits-1;     % A COMPLETER
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SURECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        somme_Diracs_ponderes=kron(symboles,[1 zeros(1,Ns-1)]);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE MISE EN FORME 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Génération de la réponse impulsionnelle du filtre de mise en forme
        h= ones(1,Ns);             % A COMPLETER 
        %Filtrage de mise en forme
        Signal_emis=filter(h,1,somme_Diracs_ponderes);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CANAL DE PROPAGATION AWGN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %POUR MODULATION BPSK
        %Calcul de la puissance du signal émis
        P_signal= mean(abs(Signal_emis).^2);

        %Calcul de la puissance du bruit à ajouter au signal pour obtenir la valeur
        %souhaité pour le SNR par bit à l'entrée du récepteur (Eb/N0)
        P_bruit= (P_signal*Ns)/(2*log2(M)*Eb_N0);
        %Génération du bruit gaussien à la bonne puissance en utilisant la fonction
        %randn de Matlab
        Bruit=sqrt(P_bruit)*(randn(1,length(Signal_emis)));
        %Bruit =0;
        %Ajout du bruit canal au signal émis => signal à l'entrée du récepteur
        Signal_recu=Signal_emis+Bruit;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE RECEPTION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hr=ones(1,Ns);
        Signal_recu_filtre=filter(hr,1,Signal_recu);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Choix de n0
        n0=Ns;
        %Echantillonnage à n0+mNs
        Signal_echantillonne=Signal_recu_filtre(n0:Ns:end);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECISIONS SUR LES SYMBOLES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles_recus=sign(Signal_echantillonne/Ns);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR SYMBOLE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TES=TES+ numel(find(symboles_recus ~= symboles))/length(symboles_recus);  % A COMPLETER
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DEMAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits_recus= (symboles_recus+1)/2;  % A COMPLETER
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR BINAIRE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TEB=TEB+ numel(find(bits_recus ~= bits))/length(bits_recus);  % A COMPLETER
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CUMUL DU NOMBRE D'ERREURS ET NOMBRE DE CUMUL REALISES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nb_erreurs=nb_erreurs+ numel(find(bits_recus ~= bits));  % A COMPLETER
        nb_cumul=nb_cumul+1;

    end  %fin boucle sur comptage nombre d'erreurs

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CALCUL DU TAUX D'ERREUR SYMBOLE ET DU TAUX D'ERREUR BINAIRE POUR LA
    %VALEUR TESTEE DE Eb/N0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TES_simule(indice_bruit)=TES/nb_cumul;
    TEB_simule(indice_bruit)=TEB/nb_cumul;

end  %fin boucle sur les valeurs testées de Eb/N0

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CALCUL DU TES ET DU TEB THEORIQUE DE LA CHAINE IMPLANTEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TES_THEO= 2*((M - 1)/M)*qfunc(sqrt((6*log2(M)*tab_Eb_N0)/(M^2 - 1)));
TEB_THEO=TES_THEO/log2(M);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TRACES DES TES ET TEB OBTENUS EN FONCTION DE Eb/N0
%COMPARAISON AVEC LES TES et TEBs THEORIQUES DE LA CHAINE IMPLANTEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
semilogy(tab_Eb_N0_dB, TES_THEO,'r-x')
hold on
semilogy(tab_Eb_N0_dB, TES_simule,'b-o')
legend('TES théorique','TES simulé')
xlabel('E_b/N_0 (dB)')
ylabel('TES')
%Ajouter un titre à la figure fonction de la chaine implantée

figure
semilogy(tab_Eb_N0_dB, TEB_THEO,'r-x')
hold on
semilogy(tab_Eb_N0_dB, TEB_simule,'b-o')
legend('TEB théorique','TEB simulé')
xlabel('E_b/N_0 (dB)')
ylabel('TEB')
%Ajouter un titre à la figure fonction de la chaine implantée