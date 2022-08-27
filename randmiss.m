% Miss some values of dataset.

MAXLEN = numel(cdataset);
R = randperm(MAXLEN);

misscount = 0;
CDATASET = cdataset;
cdataset = cdataset(:);
i=0;
numNAN = floor(MAXLEN*PERCENT);
MISSIDX = zeros(numNAN,1);
while(misscount ~=numNAN)
    i=i+1;
    if ~isnan(cdataset(R(i)))
        cdataset(R(i)) = NaN;
        misscount = misscount +1;
        MISSIDX(misscount) = R(i);
    end
end
cdataset=vec2mat(cdataset,size(CDATASET,2));
