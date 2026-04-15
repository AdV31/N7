function [Q,N]=matrix_representation(A,n)
% Représentation sous forme de matrice du graphe Internet
% A contient les arcs du graphe orienté.
% n représente le nombre de sommets.
% Q est la matrice du graphe Internet.

    % Initialisation
    Q = sparse(n,n);

    N = zeros(n,1);

    for i = 1:n
        N(i) = sum(ismember(A(:,1),i));
    end

    nb_arcs = size(A,1);
    for idx = 1:nb_arcs
        i = A(idx,2);
        j = A(idx,1);
        if N(j) ~= 0
            Q(i,j) = 1/N(j);
        end
    end
end