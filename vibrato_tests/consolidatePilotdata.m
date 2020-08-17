clearvars

Path = 'rendered/';
Ext = '.txt';

Filenames = dir([Path '*' Ext]);

df = readtable(Filenames(1).name);
df.Date = string(df.Date);

for k = 2:length(Filenames)
    if Filenames(k).name(1) == '.'
        continue
    end

    Temp = readtable(Filenames(k).name);
    Temp.Date = string(Temp.Date);

    df = [df; Temp];
end

Inst1Data = df(findgroups(df.Inst) == 1, 7:8);
Inst2Data = df(findgroups(df.Inst) == 2, 7:8);

TotalProportions = grpstats(df(:, 7:end), 'VibDepth');
Inst1Props = grpstats(Inst1Data, 'VibDepth');
Inst2Props = grpstats(Inst2Data, 'VibDepth');

%% Plots

ft = fittype('1/(1 + exp(-4*log(3)*(x-xmid)/xscale80))','indep','x');

subplot(1, 3, 1);
hold on;
plot(TotalProportions.VibDepth, TotalProportions.mean_Accuracy);
mdl = fit(TotalProportions.VibDepth, TotalProportions.mean_Accuracy, ft, 'start', [0.5, 3]);
plot(mdl);
ylim([0.5, 1]);
xlabel('depth (cents)');
ylabel('% correct');
title('Combined');
hold off;

subplot(1, 3, 2);
plot(Inst1Props.VibDepth, Inst1Props.mean_Accuracy);
ylim([0.5, 1]);
title('Tpt');
xlabel('depth (cents)');
ylabel('\% correct');

subplot(1, 3, 3);
plot(Inst2Props.VibDepth, Inst2Props.mean_Accuracy);
ylim([0.5, 1]);
title('Violin');
xlabel('depth (cents)');
ylabel('\% correct');

%%

ft = fittype('1/(1 + exp(-4*log(3)*(x-xmid)/xscale80))','indep','x');
mdl = fit(TotalProportions.VibDepth, TotalProportions.mean_Accuracy, ft, 'start', [0.5, 2.9]);
plot(mdl)