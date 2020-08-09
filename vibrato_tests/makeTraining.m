%   Quick script to generate training stimuli.


fs = 44100;
Dur = 2;
N = Dur*fs;
f = 440;
t = (0:N-1)/fs;

Gain = 0.1;

x = zeros(N, 1);
for i = 1:5
    x = x + (1/i) * sin(2*pi*i*f*t + 2*pi*rand())';
end

audiowrite('NoVib.wav', Gain * x, fs);

Delta = 0.6;
NumCycles = 3;
fm = 11;
Alpha = 2 ^ (Delta/12) - 1;
VibGenerator = RandomVibrato(fs, fm, Alpha, NumCycles, 0.5);

y = VibGenerator.addVibrato(x);
audiowrite('Vib.wav', Gain * y, fs);

join2Wavs('NoVib.wav', 'Vib.wav', 1.0, 1);

Path = 'raw_audio/Train/';

Files = {'Oboe_Train1.wav', 'Oboe_Train2.wav'};

for FileIdx = 1:2
    [x, fs] = audioread([Path Files{FileIdx}]);
    Out = VibGenerator.addVibrato(x);
    
    [~, Base, Ext] = fileparts(Files{FileIdx});
    
    OutFilename = Base + "_Vibdemo.wav";
    
    audiowrite(OutFilename, Out, fs);
end