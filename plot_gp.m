


Prob = result.Prob;
Test_Label = result.Test_Label;
Predict_Label = result.Predict_Label;

figure(1)
hold on

accuri = []
confidences = []

for confidence = 0.2:0.1:0.9
    tmp = max(Prob, [],2);
    inx = find(tmp>confidence&tmp<=confidence+0.1);
    
    tmp_label = Test_Label(inx,:);
    tmp_predict = Predict_Label(inx,:);
    
    accuri = [accuri, sum(sum(tmp_label.*tmp_predict)) / size(tmp_label,1)];
    confidences = [confidences, confidence];
    
end

plot(confidences+0.05, accuri, '--r+');