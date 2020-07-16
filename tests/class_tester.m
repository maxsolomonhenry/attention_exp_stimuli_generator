%   Testing out StimulusGenerator class.
%
%   For use in the experiment "Directing attention in contemporary
%   composition with timbre," Henry, Bao and Regnier for the Music
%   Perception and Cognition Lab, McGill University. Summer, 2020.
%

try
    delete(Tester);
catch
    warning('Tester has not been initiated yet.');
end

clearvars;

Tester = StimulusGenerator('M1_p1_Tpt.wav', 'M1_P2_Vln.wav');
Tester.auditionStimuli()

disp('Yolo');