function  X = wknnimpute( X,k )
%this fuction imputes NaN characters based on weighted k neighboring of X
% input:
% X: digite data matrix
% k: number of neighbors
% output:
% X: imputed digited dataset
[N,d] = size(X);
XnoNaN = X(sum(isnan(X),2)==0,:);
N2 = size(XnoNaN,1);
for i = 1 : N
    if sum(isnan(X(i,:)))==0
        continue
    end
    for j=1:d
        if isnan(X(i,j))==0
            continue
        end
        XnoNaN2 = XnoNaN;
        XnoNaN2(:,isnan(X(i,:)))=[];
        X2 = X(i,~isnan(X(i,:)));
        D= Mydist(repmat(X2,N2,1) , XnoNaN2);
        
        [D,nn_idx]=sort(D);
        D = max(D,0.01*ones(length(D),1));
        KNN = nn_idx(1:k);
        W = 1./D(1:k);
        % normalize w in order to have sum=1
        W = W/sum(W);
        % imputation
        X(i,j) = sum(W .* XnoNaN(KNN,j));
    end
end
end