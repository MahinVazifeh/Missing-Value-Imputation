function  [IDdataset,INDdataset] =...
    knnimpute_nondigit( X,mapedND,k,NDdataset,map )
%this fuction imputes NaN characters in C based on k neighboring of X
% input:
% X: digite data matrix
% mapedND: having NaN maped character vector to double
% k: number of neighbors
% NDdataset : non digited vector of dataset
% map: map of conversion
% output:
% IDdataset: imputed digited dataset
% INDdataset: imputed non digit dataset
 N = length(mapedND);
for i = 1 : N
    if ~isnan(mapedND(i))
        continue
    end
    D = Mydist(repmat(X(i,:),N,1) , X);
    for j = 1:N
        if isnan(mapedND(j))
            D(j) = inf; % to eliminate that sample
        end
    end
    [~,nn_idx]=sort(D);
    KNN = nn_idx(1:min(k,length(D~=inf)));
    [MODE,]=mode(mapedND(KNN));
    mapedND(i) = MODE;
    
    NDdataset(i)= map(MODE);
end
IDdataset = mapedND;
INDdataset = NDdataset;


end