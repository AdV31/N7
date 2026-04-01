A = [100; 200; 300; 400];
G = 












function minimum = parcours_C(Q,I_barre,Chi)

    R = chol(Q);
    n = length(I_barre);
    minimum = Chi;
    Seuil = Chi;
    I = [];

    gn = ceil(-sqrt(Chi)/R(n,n) + I_barre(n));
    dn = floor(sqrt(Chi)/R(n,n) + I_barre(n));

    minimum = boucle(R,I_barre,Chi,gn,dn,Seuil,1,I);
end

function minimum = boucle(R,I_barre,Chi,gn,dn,Seuil,j,I)
    n = length(I_barre);
    for in = dn:gn
        if Seuil < 0
            minimum = Chi;
        else
            gn = ceil(-sqrt(Chi - (R(n-j,n-j)*I_barre(n-j)*in)^2)/R(n-j,n-j) + I_barre(n-j) + R(n-j,n-j+1)*(in - I_barre(n-j+1))/R(n-j,n-j));
            dn = floor(sqrt(Chi - (R(n-j,n-j)*I_barre(n-j)*in)^2)/R(n-j,n-j) + I_barre(n-j) + R(n-j,n-j+1)*(in - I_barre(n-j+1))/R(n-j,n-j));
            oui = 0;
            I = [I; in];
            for k = j:n
                oui = oui + R(n-j,k)*(I(k) - I_barre(k));
            end
            Seuil = Seuil - oui^2;
            if j == n-1
                minimum = min(minimum, Chi - (R(n-j,n-j)*I_barre(n-j)*in)^2);
            else
                minimum = boucle(R,I_barre,Chi,gn,dn,Seuil,j+1,I);
            end
        end
    end
end