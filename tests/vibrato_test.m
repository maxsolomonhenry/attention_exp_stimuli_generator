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
N = 5*fs;
f = 440;
t = (0:N-1)/fs;

x = zeros(N, 1);
for i = 1:10
    x = x + (1/i^3) * sin(2*pi* i*f *t)';
end

%
%   Example implementation.
%

Out = randomVibrato(x, fs, 11, 10, 3, 1);
spectrogram(Out, hamming(1024), 'yaxis');
soundsc(Out, fs);