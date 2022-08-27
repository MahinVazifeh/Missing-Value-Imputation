function [mean_RMSE,mean_NRMSE,missing_number ] = NRMSE(Realdataset,imputeddataset)
% This funtion calculating NRMSE and RMSE for each culumn of dataset,finally
% calculating mean of the NRMSE and mean of the RMSE
[N d]=size(Realdataset);
RMSE=zeros(1,d);%RMSE for each column
NRMSE=zeros(1,d);%NRMSE for each column
missing_number=zeros(1,d); %Number of missing items of any column
for i=1:d
matrix_error=Realdataset(:,i) - imputeddataset(:,i);
missing_number(i)=nnz(matrix_error);
if missing_number(i)~=0
matrix_error=matrix_error .^ 2;
sum_MError=sum(matrix_error);
mean_SumMError=sum_MError/missing_number(i);
RMSE(i)=sqrt(mean_SumMError);
min_MError=min(Realdataset(:,i));
max_MError=max(Realdataset(:,i));
NRMSE(i)=RMSE(i)/(max_MError-min_MError);
end
end
mean_RMSE=mean(RMSE);
mean_NRMSE=mean(NRMSE);
end

