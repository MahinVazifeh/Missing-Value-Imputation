%Test classification in DBN in MNIST data set
clc;
clear;
% clear all;
res={};
more off;
addpath(genpath('DeepLearnToolboxGPU'));
addpath('DeeBNet');
load CarEvaluation.mat
numexperiments=5;
K=5;
Data_last=car_data;
Target_ds=target_car;

kimpute=3;
PERCENT=0.15;
[Data_last,MISIDX]=Create_randmiss(Data_last,PERCENT);
MISIDX=MISIDX';
[N,d]=size(Data_last);
error=zeros(d,1);
for j=1:d 
    % set variable for test
     k_test=1;
    %set variable for train
     k_train=1;
     for i=1:N
        if isnan(Data_last(i,j))
            test_j(k_test,:)=Data_last(i,:);
            misidx_test(k_test)=i;
            k_test=k_test+1;    
        else 
            train_j(k_train,:)=Data_last(i,:);
            misidx_train(k_train)=i;
            k_train=k_train+1;
        end       
     end
     misidx_test=misidx_test';
     misidx_train=misidx_train';
     
     %the main target of test and train for j
     maintarget_test_j=car_data(misidx_test,j);
     target_train_j=train_j(:,j);
     
     %empty the target_train from train dataset and target_test from test
     %dataset
     train_j(:,j)=[];
     test_j(:,j)=[];
     
     
     %calc mode of each variable for missing cells corresponding variable
     %in train and test dataset
     for mj=1:d-1
%      train
%      train_j=knnimpute(train_j,kimpute);
     mode_train_j = mode(train_j(isnan(train_j(:,mj))==0,mj));
     train_j(isnan(train_j(:,mj))==1,mj)= mode_train_j;
%      test
     mode_test_j=mode(test_j(isnan(test_j(:,mj))==0,mj));
     test_j(isnan(test_j(:,mj))==1,mj)= mode_test_j;
%        test_j=knnimpute(test_j,kimpute);
     end
     
    %deepimputation
    [N_train,d_train]=size(train_j);
    [N_test,d_test]=size(test_j);
    [N D]=size(Data_last);
    
    % DBN with keyvanrad toolbox
    % start dbn
	%get data
     data=DataClasses.DataStore();
     data.valueType=ValueType.gaussian;
    %set test and train
    %increase train matrix and target vector
%      train_j= vertcat(train_j,train_j,train_j,train_j,train_j,train_j,train_j);
%      target_train_j=vertcat(target_train_j,target_train_j,target_train_j,target_train_j,target_train_j,target_train_j,target_train_j);
     data.trainData=train_j;
     data.trainLabels=target_train_j;
     data.testData=test_j;
     data.testLabels=maintarget_test_j;
     data.normalize('meanvar');
     data.shuffle();
     data.validationData=data.testData;
     data.validationLabels=data.testLabels;
     dbn=DBN('classifier');
     
     %define RBMS
    % RBM1% RBM1
rbmParams=RbmParameters(500,ValueType.binary);
rbmParams.gpu=1;
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.PCD;
dbn.addRBM(rbmParams);
% RBM2
rbmParams=RbmParameters(500,ValueType.binary);
rbmParams.gpu=1;
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.PCD;
dbn.addRBM(rbmParams);
% RBM3
rbmParams=RbmParameters(2000,ValueType.binary);
rbmParams.gpu=1;
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.PCD;
rbmParams.rbmType=RbmType.discriminative;
rbmParams.performanceMethod='classification';
dbn.addRBM(rbmParams);
%train
ticID=tic;
dbn.train(data);
toc(ticID)
%test train
classNumber=dbn.getOutput(data.testData,'bySampling');
errorBeforeBP=sum(classNumber~=data.testLabels)/length(classNumber)

error(j)=sqrt(mean((target_train_j(:)- classNumber(:)).^2));
% error(j)=sum(classNumber~=data.testLabels)/length(classNumber);

test_j=[];
train_j=[];
misidx_test=[];
misidx_train=[];
end

% disp(mean(error))
