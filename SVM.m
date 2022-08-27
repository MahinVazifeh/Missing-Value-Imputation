function [Accuracy,Sensivity,Specificity]=SVM( Train,TargetTrain,Test,TargetTest )

svmStruct = svmtrain(Train,TargetTrain,...
    'boxconstraint',0.9,'kernel_function','rbf','rbf_sigma',2);
svmPredictedLabels = svmclassify(svmStruct,Test);
% True Positive
TP = sum(TargetTest == 1 & svmPredictedLabels == 1);
% True Negative
TN = sum(TargetTest == 2 & svmPredictedLabels == 2);
% False Positive
FP = sum(TargetTest == 2 & svmPredictedLabels == 1);
% False Negative
FN = sum(TargetTest == 1 & svmPredictedLabels == 2);

Accuracy = (TP+TN) / (TP+TN+FP+FN) * 100;
Sensivity = TP/(TP+FN) * 100;
Specificity = TN / (FP+TN) * 100;

end

