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

% % random missing PERCENT values for testing system
% PERCENT = 0.05;
% randmiss

% Read and Prepare data (Target==1)
Cdataset=C;
Cdataset1=Cdataset;
Cdataset1(sum(isnan(Cdataset1),2)>0)=[];
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
C(cTarget==2,:)=dataMatrixImput2;
% % finish tensor
% convert_to_unique_value
cdataset = convert2categoricalvalues...
    (C,Cdataset);
% impute by bayesian
CDATASET = cdataset;
[digiteddataset,map,nondigitdataset]=my_grp2idx(nondigitdataset);
cdataset = [cdataset(:,1:5),digiteddataset,cdataset(:,6:end)];
cdataset = round(max(cdataset,0)+1);
cdataset = num2cell(cdataset);
for i=1:length(digiteddataset)
    if ~isnan(digiteddataset(i))
        cdataset{i,6} = digiteddataset(i);
    else
        cdataset{i,6} =[];
    end
end

% column9 = cdataset(:,9);
% cdataset(:,9) = [];
bdeu = 2;
[bnet,ll,temp1,~] = structureEM(cdataset(cTarget==1,:)',bdeu,20,20,'EM',1);
[bnet,ll,temp2,~] = structureEM(cdataset(cTarget==2,:)',bdeu,20,20,'EM',1);
clc
cdataset(cTarget==1,:) = temp1';
cdataset(cTarget==2,:) = temp2';

C = zeros(N,size(cdataset,2));
for i=1:N
    for j =1:size(cdataset,2)
        if isempty(cdataset{i,j})
            C(i,j) = NaN;
        else
            C(i,j) = cell2mat(cdataset(i,j));
        end
    end
end
cdataset = C - 1;
cdataset=[CDATASET(:,1:5),cdataset(:,6),CDATASET(:,6:end)];
% cross validation using K-fold
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

toc