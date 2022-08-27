load matlab.mat;
[N , d]= size(withoutmissing);

% Normalizing dataset
% MIN = min(withoutmissing);
% MAX = max(withoutmissing);
% withoutmissing = (withoutmissing - repmat(MIN,N,1))...
%     ./(repmat(MAX,N,1)-repmat(MIN,N,1));


numexperiments = 5;
K = 10;
Accuracy=zeros(numexperiments,K);
Sensivity=zeros(numexperiments,K);
Specificity=zeros(numexperiments,K);
for i=1:numexperiments
    % Crossvalidation with k-fold
    % making Crossvalidation indices
    cv_index= crossvalind('Kfold',N,K);
    for k=1:K
        % Partitioning dataset as train and test
        Train = withoutmissing(cv_index~=k,:);
        TargetTrain = CTarget(cv_index~=k);
        
        Test = withoutmissing(cv_index==k,:);
        TargetTest = CTarget(cv_index==k);
        % Classification with Decision_Tree
        [acc,sens,spec]=...
            DecisionTree(Train,TargetTrain,Test,TargetTest);
        Accuracy(i,k) = acc;
        Sensivity(i,k)= sens;
        Specificity(i,k) = spec;
    end
end
disp(mean(Accuracy(:)));
disp(mean(Sensivity(:)));
disp(mean(Specificity(:)));