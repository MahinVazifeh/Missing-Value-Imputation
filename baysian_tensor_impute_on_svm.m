clc
clear
addpath('tensor_toolbox','poblano_toolbox');
P = genpath('bnt-master');
addpath(P,'csda-dataimputation-master');
% Loading dataset
tic
load cdataset.mat
[N , d]= size(cdataset);
nondigitdataset = cdataset(:,6);
cdataset(:,6)=[];
beforImputationDS = cdataset;
C = zeros(N,size(cdataset,2));
for i=1:N
    for j =1:size(cdataset,2)
        if strcmp(cell2mat(cdataset(i,j)),'')==1
            C(i,j) = NaN;
        else
            C(i,j) = cell2mat(cdataset(i,j));
        end
    end
end
beforImputationDS=C;

[digiteddataset,map,nondigitdataset]=my_grp2idx(nondigitdataset);
C = zeros(N,size(cdataset,2));
for i=1:N
    for j =1:size(cdataset,2)
        if strcmp(cell2mat(cdataset(i,j)),'')==1
            C(i,j) = NaN;
        else
            C(i,j) = cell2mat(cdataset(i,j));
        end
    end
end
cdataset = [C(:,1:5),digiteddataset,C(:,6:end)];
% Delete Momayez field
column9 = cdataset(:,9);
cdataset(:,9) = [];

cdataset = num2cell(cdataset);
for i=1:size(cdataset,1)
    for j=1:size(cdataset,2)
        if isnan(cdataset{i,j})
            cdataset{i,j} =[];
        else
            cdataset{i,j} = cdataset{i,j} + 1;
        end
    end
end

bdeu = 2;
[bnet,ll,temp1,~] = structureEM(cdataset(cTarget==1,:)',bdeu,20,20,'EM',1);
[bnet,ll,temp2,~] = structureEM(cdataset(cTarget==2,:)',bdeu,20,20,'EM',1);
clc
cdataset(cTarget==1,:) = temp1';
cdataset(cTarget==2,:) = temp2';
% finish nonodigit field by bayesian network
C = zeros(N,size(cdataset,2));
for i=1:N
    for j =1:size(cdataset,2)
        C(i,j) = cell2mat(cdataset(i,j));
    end
end
cdataset=C;
% return to original dataset for impute tensor
cdataset = [beforImputationDS(:,1:5),cdataset(:,6)...
    ,beforImputationDS(:,6:8),column9,beforImputationDS(:,9:end)];

%%  Read and Prepare data
C=cdataset;
dataMatrix=C(cTarget==1,:);
dataMatrix(isnan(dataMatrix)) = 0;
R = 3;
Ptmp = zeros(size(dataMatrix));
Ptmp(dataMatrix ~= 0) = 1;
X = tensor(dataMatrix);
P = tensor(Ptmp);
%Create initial guess using 'nvecs'
M_init = create_guess('Data', X, 'Num_Factors', R, ...
    'Factor_Generator', 'nvecs'); 
ncg_opts = ncg('defaults');
ncg_opts.StopTol = 1.0e-9;
ncg_opts.RelFuncTol = 1.0e-30; 
ncg_opts.MaxIters = 10^4;
ncg_opts.DisplayIters = 100;
ncg_opts;
[M,~,output] = cp_wopt(X, P, R, 'init', M_init, ...
    'alg', 'ncg', 'alg_options', ncg_opts);
exitflag1 = output.ExitFlag;
dataMatrixImput1 = double(M);
dataMatrixImput1(dataMatrix ~= 0) = dataMatrix(dataMatrix ~= 0);
C(cTarget==1,:)=dataMatrixImput1;
% tensor(Target==2)
dataMatrix= C(cTarget==2,:);
dataMatrix(isnan(dataMatrix)) = 0;
R = 3;
Ptmp = zeros(size(dataMatrix));
Ptmp(dataMatrix ~= 0) = 1;
X = tensor(dataMatrix);
P = tensor(Ptmp);
%Create initial guess using 'nvecs'
M_init = create_guess('Data', X, 'Num_Factors', R, ...
    'Factor_Generator', 'nvecs'); 
ncg_opts = ncg('defaults');
ncg_opts.StopTol = 1.0e-9;
ncg_opts.RelFuncTol = 1.0e-30; 
ncg_opts.MaxIters = 10^4;
ncg_opts.DisplayIters = 100;
ncg_opts;
[M,~,output] = cp_wopt(X, P, R, 'init', M_init, ...
    'alg', 'ncg', 'alg_options', ncg_opts);
exitflag = output.ExitFlag;
dataMatrixImput2 = double(M);
dataMatrixImput2(dataMatrix ~= 0) = dataMatrix(dataMatrix ~= 0);
C(cTarget==2,:)=dataMatrixImput2;% cdataset(cdataset<0)=0;

cdataset=C;
%% SMOTE
% cdatasetBeforeSMOTE = cdataset;
% [cdataset, cTarget] = SMOTE(cdataset,cTarget);
%%
% cross validation using K-fold
numexperiments = 3;
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
        Train = cdataset(cv_index~=k,:);
        TargetTrain = cTarget(cv_index~=k);
        
        Test = cdataset(cv_index==k,:);
        TargetTest = cTarget(cv_index==k);
        % Classification with SVM
        [acc,sens,spec]=...
            SVM(Train,TargetTrain,Test,TargetTest);
        Accuracy(i,k) = acc;
        Sensivity(i,k)= sens;
        Specificity(i,k) = spec;
    end
end
disp(mean(Accuracy(:)));
disp(mean(Sensivity(:)));
disp(mean(Specificity(:)));

% dataMatrix = dataMatrix(:);
% CDATASET = CDATASET(:);
% 
% RMSE = sqrt(mean((CDATASET(MISSIDX)-cdataset(MISSIDX)).^2));
% disp(RMSE)

% convertedDS = convert2categoricalvalues( cdatasetBeforeSMOTE,beforImputationDS);
% xlswrite('Proposed_impute',convertedDS);
toc