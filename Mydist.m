function d = Mydist( x1,x2)
%this function calculates distance between x1 and x2

d = sqrt(sum((x1-x2).^2,2));


end

