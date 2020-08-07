%   Quick script to generate training stimuli.

Delta = 2.0;
NumCycles = 3;
fm = 11;
Alpha = 2 ^ (Delta/12) - 1;
VibGenerator = RandomVibrato(fs, fm, Alpha, NumCycles, 1.0);

Path = 'raw_audio/Train/';

Files = {'Oboe_Train1.wav', 'Oboe_Train2.wav'};

for FileIdx = 1:2
    [x, fs] = audioread([Path Files{FileIdx}]);
    Out = VibGenerator.addVibrato(x);
    
    [~, Base, Ext] = fileparts(Files{FileIdx});
    
    OutFilename = Base + "_Vibdemo.wav";
    
    audiowrite(OutFilename, Out, fs);
end