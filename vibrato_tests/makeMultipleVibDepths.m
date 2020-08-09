%   This script generates multiple vibrato'd stimuli, at depths specified
%   in "Deltas," for use in a pilot experiment determining vibrato-depth
%   detection threshold in isolated streams.
%
%   Each new pool of generated stimuli will sit in a directory labeled by
%   the vibrato depth, e.g.: "25" for Delta = 0.25. Vibrato are randomly
%   placed in the stimulus where the amplitude envelope is above a given
%   threshold.
%
%   For use in the experiment "Directing attention in contemporary
%   composition with timbre," Henry, Bao and Regnier for the Music
%   Perception and Cognition Lab, McGill University. Summer, 2020.

clearvars;


StimPath = '../raw_audio/four_mels/';
Filenames = dir([StimPath '*.wav']);
[~, fs] = audioread(Filenames(1).name);     % Read first file to get sample rate.

Deltas = {0.1, 0.2, 0.3, 0.4, 0.5};
fm = 11;
NumCycles = 3;

VibsDir = StimPath;
mkdir(VibsDir);
fileID = fopen([VibsDir '/vib_log.txt'],'w');

for i = 1:length(Deltas)
    disp(['Processing Delta = ' num2str(Deltas{i})]);

    Alpha = 2 ^ (Deltas{i}/12) - 1;
    VibGenerator = RandomVibrato(fs, fm, Alpha, NumCycles, 0.75);

    for k = 1:length(Filenames)
        [x, fs_] = audioread(Filenames(k).name);

        if fs_ ~= fs
            continue
        end

        Out = VibGenerator.addVibrato(x);

        [~, Basename, ~] = fileparts(Filenames(k).name);

        OutFilename = [Basename '_vib' num2str(Deltas{i}*100) '.wav'];
        OutFilepath = [VibsDir '/' OutFilename];

        fprintf(fileID,'%s\t%f\n', OutFilename, VibGenerator.VibStart/fs);

        audiowrite(OutFilepath, Out, fs);
    end
end
    
    fclose(fileID);