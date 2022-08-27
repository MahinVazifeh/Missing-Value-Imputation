%%%%%%%%%%%%%%% This program will use a Tensor factorization to pridict missing data in a medical questionaire
clc
clear all;
P = genpath('bnt-master');
addpath(P,'csda-dataimputation-master');
%%%%%%%%%%%%%%%%%%%%%%%Defining useful constants
tic
load womissing_Last.mat
omidwomissing=Data_last;
[N , d]= size(omidwomissing);
omidwomissing(:,4)=[];
omidwomissing=round(omidwomissing);
% Making missing values
PERCENT=0.05;
[missingDS,MISSIDX ] = Create_randmiss( omidwomissing,PERCENT);
MISSIDX_ForB=find(isnan(missingDS));
% impute smallnumber using bayesian
% To change num to cell Matrix + 1
missingDS = num2cell(missingDS);
for i=1:size(missingDS,1)
    for j=1:size(missingDS,2)
        if isnan(missingDS{i,j})
            missingDS{i,j} =[];
        else
            missingDS{i,j} = missingDS{i,j}+1;
        end
    end
end
RMSEForRvalueFB=zeros(1,size(missingDS,2));
NRMSEForRvalueFB=zeros(1,size(missingDS,2));
for bdeu=1:size(missingDS,2)
[bnet,l1,temp,~] = structureEM(missingDS',bdeu,20,20,'EM',1);
WOmissingForB=temp';
WOmissingForB=cell2mat(WOmissingForB);
WOmissingForB=WOmissingForB - 1 ;
[mean_RMSE,mean_NRMSE,missing_number ] = RMSE_NRMSE(omidwomissing,WOmissingForB);
RMSEForRvalue(bdeu)=mean_RMSE;
NRMSEForRvalue(bdeu)=mean_NRMSE;
end
RMSEForRvalueFB=mean(RMSEForRvalue);
NRMSEForRvalueFB=mean(NRMSEForRvalue);
disp(RMSEForRvalueFB)
disp(NRMSEForRvalueFB)







