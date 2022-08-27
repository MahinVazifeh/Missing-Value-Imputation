function converted = convert2categoricalvalues( Idataset,dataset)
converted = Idataset;
[n1,n2]= size(dataset);
for j=1:n2
   u = unique(dataset(:,j));
   for i=1:n1
       x = Idataset(i,j);
       Dis = Mydist(repmat(x,size(u,1),1),u);
       [~,Imin]=min(Dis);
       converted(i,j) = u(Imin);
   end
end

end

