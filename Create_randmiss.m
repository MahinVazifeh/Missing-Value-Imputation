function [A1_miss,MISSIDX ] = Create_randmiss( A1,PERCENT)
% This funtion create miss items for dataset
% A1=full dataset
% PERCENT=missing rate
A3=A1;
[N d]=size(A1);
MAXLEN = numel(A1);
misscount = 0; %number of miss items
numNAN = floor(MAXLEN*PERCENT);
MISSIDX = zeros(2,numNAN);
while(misscount ~=numNAN)
    i=randi(N,1,1);
    j=randi(d,1,1);
    if ~isnan(A1(i,j))
        A1(i,j) = NaN;
        misscount = misscount +1;
        MISSIDX(1,misscount) =i;
        MISSIDX(2,misscount) =j;
    end
     
end
A1_miss=A1;
end

