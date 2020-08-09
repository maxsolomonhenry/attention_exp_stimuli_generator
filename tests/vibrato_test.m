%   Random vibrato test script.
%
%   For use in the experiment "Directing attention in contemporary
%   composition with timbre," Henry, Bao and Regnier for the Music
%   Perception and Cognition Lab, McGill University. June 24, 2020.

clearvars;

%
%   Generate test signal.
%

fs = 44100;
Dur = 2;
N = Dur*fs;
f = 440;
t = (0:N-1)/fs;

x = zeros(N, 1);
for i = 1:5
    x = x + (1/i) * sin(2*pi*i*f*t + 2*pi*rand())';
end

%
%   Example implementation.
%

Delta = 2;
fm = 11;
NumCycles = 3;


Alpha = 2 ^ (Delta/12) - 1;
VibGenerator = RandomVibrato(fs, fm, Alpha, NumCycles, 0.5);

Out = VibGenerator.addVibrato(x);

spectrogram(Out, hamming(1024), [], [], fs, 'yaxis');
sound(Out/max(abs(Out))*0.5, fs);