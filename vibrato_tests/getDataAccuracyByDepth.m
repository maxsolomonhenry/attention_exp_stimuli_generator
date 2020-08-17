function [Main, Inst1Mean, Inst2Mean] = getDataAccuracyByDepth(csv_)

%     [~, Base, ~] = fileparts(csv_);
%     renderVibData(csv_, filekey);
    Tab = readtable(csv_);
    Inst1Data = Tab(findgroups(Tab.Inst) == 1, 7:8);
    Inst2Data = Tab(findgroups(Tab.Inst) == 2, 7:8);
    Main = grpstats(Tab(:, 7:end), 'VibDepth');
    
    Inst1Mean = mean(Inst1Data.Accuracy);
    Inst2Mean = mean(Inst2Data.Accuracy);
end