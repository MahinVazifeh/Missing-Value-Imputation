function [GRP ,map,refineddata] = my_grp2idx( data )
%
for i=1:length(data)
    if isnumeric(data{i})
        data{i} = num2str(data{i});
        continue;
    end
    
    if strcmp(data{i},'1,1')
        data{i}='r1,l1';
    elseif strcmp(data{i},'1,2')
        data{i} = 'r1,l2';
    end
end
[GRP ,map] = grp2idx(data);
refineddata = data;
end