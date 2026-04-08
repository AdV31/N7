clear; close all;
%Data_mat = load('./DonneesTP2/ToyExample.mat');
%Data_mat = Data_mat.Data;
%S = Data_mat;
%k = 8;
%sigma = 0.5;

%cluster = classification_spectrale(S,k,sigma);

%gscatter(S(:,1),S(:,2),cluster);
%title('Classification spectrale');

Image_Data_S = load('./DonneesTP2/DataSagittale.mat');
Image_Data_S = Image_Data_S.Image_DataS;
DataTemps_S=reshape(Image_Data_S,64*54,20);

Image_ROI_Sag = load('./DonneesTP2/DataSagittale.mat');
Image_ROI_Sag = Image_ROI_Sag.Image_ROI_S;



Image_Data_T = load('./DonneesTP2/DataTransverse.mat');
Image_Data_T = Image_Data_T.Image_DataT;
DataTemps_T=reshape(Image_Data_T,64*54,20);

Image_ROI_Tra = load('./DonneesTP2/DataTransverse.mat');
Image_ROI_Tra = Image_ROI_Tra.Image_ROI_T;

clusters_S = classification_spectrale(DataTemps_S,6,0.4325);
clusters_T = classification_spectrale(DataTemps_T,5,0.35);

figure;
subplot(2,2,1);
Image_T = reshape(clusters_T,64,54);
imagesc(Image_T);
axis image;
title('Classification spectrale - Transverse');

subplot(2,2,2);
Image_S = reshape(clusters_S,64,54);
imagesc(Image_S);
axis image;
title('Classification spectrale - Sagittale');

subplot(2,2,3);
imagesc(Image_ROI_Tra);
axis image;
title('Verité terrain - Transverse');

subplot(2,2,4);
imagesc(Image_ROI_Sag);
axis image;
title('Verité terrain - Sagittale');

function clusters = classification_spectrale(S,k,sigma)
    
    A = zeros(size(S,1));
    for i=1:size(S,1)
        for j=1:size(S,1)
            if i ~= j
                A(i,j) = exp(-norm(S(i,:)-S(j,:))^2/(2*sigma^2));
            end
        end
    end
    d = sum(A,2);
    D = spdiags(d,0,size(A,1),size(A,2));

    [X,~] = eigs(A,D,k,"largestreal","SubspaceDimension",500);
    
    V = X.*X;
    V_sqrt_inv = 1./sqrt(sum(V,2));
    Y = X.*V_sqrt_inv;

    clusters = kmeans(Y,k);
end