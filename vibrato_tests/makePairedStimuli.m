%   This script generates all the pairs of stimuli for the vibrato depth 
%   pilot experiment.
%
%   For use in the experiment "Directing attention in contemporary
%   composition with timbre," Henry, Bao and Regnier for the Music
%   Perception and Cognition Lab, McGill University. Summer, 2020.

clearvars;

% Generate 4*4 matrix of all possible melody pairs.
AllMelodyPairs = fullfact([4, 4]);

% Inter-stimulus gap, in seconds.
GapInSecs = 1.0;

StimPath = 'raw_audio/';

for InstIdx = 1:2
    for DepthIdx = 2:10
        for CorrectResponse = 0:1            
            % Randomly sample one of 16 possible melody pairs.
            MelodyPair = AllMelodyPairs(randi(16), :);

            % Switch on/off which stimulus has vibrato.
            Depth1 = DepthIdx^(1 - CorrectResponse);
            Depth2 = DepthIdx^(CorrectResponse);
            
            Filename1 = findStimFilename(InstIdx, MelodyPair(1), Depth1);
            Filename2 = findStimFilename(InstIdx, MelodyPair(2), Depth2);
            
            Path1 = [StimPath Filename1];
            Path2 = [StimPath Filename2];
            
            join2Wavs(Path1, Path2, GapInSecs, CorrectResponse);
        end
    end
end