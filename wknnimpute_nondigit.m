function  [IDdataset,INDdataset] =...
    wknnimpute_nondigit( X,mapedND,k,NDdataset,map )
%this fuction imputes NaN characters in C based on k neighboring of X
% input:
% X: digit data matrix
% mapedND: having NaN maped character vector to double
% k: number of neighbors
% NDdataset : non digited vector of dataset
% map: map of conversion
% output:
% IDdataset: imputed digited dataset
% INDdataset: imputed non digit dataset
IDdataset = mapedND;
INDdataset = NDdataset;

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
    [D,nn_idx]=sort(D);
    D = max(D,0.01*ones(length(D),1));
    KNN = nn_idx(1:min(k,length(D~=inf)));
    W = 1./D(1:k);
    UNIQUEKNN = unique(mapedND(KNN));
    scores = zeros(length(UNIQUEKNN),1);
    for m=1:length(mapedND(KNN))
        scores(mapedND(KNN(m))==UNIQUEKNN) = ...
            scores(mapedND(KNN(m))==UNIQUEKNN)+W(m);
        
    end
    [~,IMAX]=max(scores);
    IDdataset(i) = UNIQUEKNN(IMAX);
    INDdataset(i) = map(IDdataset(i));
end


end