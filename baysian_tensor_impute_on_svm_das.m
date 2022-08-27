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
beforImputationDS = C;
column8 = C(:,8);
C(:,8) = [];
cdataset = C;

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

% column9 = cdataset(:,9);
% cdataset(:,9) = [];
bdeu = 2;
[bnet,ll,temp1,~] = structureEM(cdataset(cTarget==1,:)',bdeu,20,20,'EM',1);
[bnet,ll,temp2,~] = structureEM(cdataset(cTarget==2,:)',bdeu,20,20,'EM',1);
clc
cdataset(cTarget==1,:) = temp1';
cdataset(cTarget==2,:) = temp2';

cdataset = cell2mat(cdataset);
[digiteddataset,map,nondigitdataset]=my_grp2idx(nondigitdataset);

cdataset = [beforImputationDS(:,1:5),digiteddataset ...
    ,beforImputationDS(:,6:7),column8,beforImputationDS(:,8:end)];
% 
% beforImputationDS = [beforImputationDS(:,1:5),digiteddataset,...
%     beforImputationDS(:,6:end)];
C=cdataset;
%%  Read and Prepare data
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
i=randperm(414);
Train=cdataset(i(1:390),:);
TargetTrain=cTarget(i(1:390));        
Test = cdataset(i(350:end),:);
TargetTest = cTarget(i(350:end));
        % Classification with SVM
svmStruct = svmtrain(Train,TargetTrain,...
    'boxconstraint',0.9,'kernel_function','rbf','rbf_sigma',0.5);
svmPredictedLabels = svmclassify(svmStruct,Test);
err=svmPredictedLabels-TargetTest;
AA=0;
for i=1:length(err)
if err(i)==0
    AA=AA+1;
end
end
disp((AA/length(err))*100);

% dataMatrix = dataMatrix(:);
% CDATASET = CDATASET(:);
% 
% RMSE = sqrt(mean((CDATASET(MISSIDX)-cdataset(MISSIDX)).^2));
% disp(RMSE)

% convertedDS = convert2categoricalvalues( cdatasetBeforeSMOTE,beforImputationDS);
% xlswrite('Proposed_impute',convertedDS);
toc