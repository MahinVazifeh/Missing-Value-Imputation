function [Accuracy,Sensivity,Specificity] =...
    DecisionTree(Train,TargetTrain,Test,TargetTest)
MyTree = ...
    classregtree(Train,TargetTrain,'method','classification');

% MyTree.view();

DT_PredictedLabels = MyTree.eval(Test);
DT_PredictedLabels  = cell2mat(DT_PredictedLabels);
DT_PredictedLabels  = str2num(DT_PredictedLabels);
% True Positive
TP = sum(TargetTest == 1 & DT_PredictedLabels == 1);
% True Negative
TN = sum(TargetTest == 2 & DT_PredictedLabels == 2);
% False Positive
FP = sum(TargetTest == 2 & DT_PredictedLabels == 1);
% False Negative
FN = sum(TargetTest == 1 & DT_PredictedLabels == 2);

% accuracy = sum(Target == svmPredictedLabels)/length(Target)
Accuracy = (TP+TN) / (TP+TN+FP+FN) * 100;
Sensivity = TP/(TP+FN) * 100;
Specificity = TN / (FP+TN) * 100;

end

