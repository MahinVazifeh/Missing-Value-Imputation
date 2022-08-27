function [Accuracy,Sensivity,Specificity] = ...
    MyKNN(Train,TargetTrain,Test,TargetTest,num_neighbors)
%MyKNN is a KNN classifier 

knn_mdl = fitcknn(Train,TargetTrain);
knn_mdl.NumNeighbors = num_neighbors;
% knn_mdl.Distance = 'correlation';
KNN_PredictedLabels=predict(knn_mdl,Test);

% True Positive
TP = sum(TargetTest == 1 & KNN_PredictedLabels == 1);
% True Negative
TN = sum(TargetTest == 2 & KNN_PredictedLabels == 2);
% False Positive
FP = sum(TargetTest == 2 & KNN_PredictedLabels == 1);
% False Negative
FN = sum(TargetTest == 1 & KNN_PredictedLabels == 2);


Accuracy = (TP+TN) / (TP+TN+FP+FN) * 100;
Sensivity = TP/(TP+FN) * 100;
Specificity = TN / (FP+TN) * 100;


end

