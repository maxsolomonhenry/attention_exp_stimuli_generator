%   Testing out StimulusGenerator class.
%
%   For use in the experiment "Directing attention in contemporary
%   composition with timbre," Henry, Bao and Regnier for the Music
%   Perception and Cognition Lab, McGill University. June 27, 2020.
%

try
    delete(Tester);
catch
    warning('Tester has not been initiated yet.');
end

clearvars;

Tester = StimulusGenerator('Melody1_Tpt.wav', 'Melody1_Vl.wav');

Tester.auditionStimuli();