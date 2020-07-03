%   TODO:   Add desctructor.
%           Adjust loudness as appropriate to duos/solos (for cues).-
%           Make probes. (string parsing? maybe external)
%           √   Method to audition everything // then:
%           Method to export wavfiles.
%           FIX: Playback is clipping.

classdef StimulusGenerator < handle
    %
    %   Class for generating loudness-matched stimuli with random vibrato.
    %
    %   For use in the experiment "Directing attention in contemporary
    %   composition with timbre," Henry, Bao and Regnier for the Music
    %   Perception and Cognition Lab, McGill University. June 27, 2020.
    %
    
    properties
        
        Filename1;
        Filename2;
        
        x1;
        x2;
        fs;
        
        x1Vib;
        x2Vib;
        
        MixNoVib;
        MixVib1;
        MixVib2;
        
        Cue1;
        Cue2;
        
        Probe1;
        Probe2;
        
    end
    
    properties (Constant)
        
        %   Settings for artificial vibrato.        
        VibRate = 11;
        VibDepth = 15;
        VibCycles = 3;
        NoVibBuffer = 1.5;
        
        %   Settings for cues.
        CueLength = 1.5;
        CueFade = 0.1;
        
        %   Output ceiling
        EPS = 0.01;
    end
    
    methods
        
        function obj = StimulusGenerator(Filename1, Filename2)
            obj.Filename1 = Filename1;
            obj.Filename2 = Filename2;
            
            [obj.x1, obj.fs] = audioread(Filename1);
            [obj.x2, ~] = audioread(Filename2);
            
            obj.inputCheck();
            obj.matchLoudness();
            
            obj.makeVibStim();
            obj.makeMixes();
            obj.makeCues();
        end
        
        function obj = makeMixes(obj)
            obj.MixNoVib = obj.x1 + obj.x2;
            obj.MixVib1 = obj.x1Vib + obj.x2;
            obj.MixVib2 = obj.x1 + obj.x2Vib;
        end
        
        function obj = makeCues(obj)
            CueLengthInSamps = floor(obj.CueLength * obj.fs);
            FadeSamps = floor(obj.CueFade * obj.fs);
            Window = hamming(2 * FadeSamps);
            
            obj.Cue1 = obj.x1(1:CueLengthInSamps);
            obj.Cue2 = obj.x2(1:CueLengthInSamps);
            
            %   Apply fade-out
            obj.Cue1(end-FadeSamps + 1:end) = ...
                obj.Cue1(end-FadeSamps+1:end) .* Window(FadeSamps+1:end);
            obj.Cue2(end-FadeSamps + 1:end) = ...
                obj.Cue2(end-FadeSamps+1:end) .* Window(FadeSamps+1:end);
        end

        function auditionStimuli(obj)
            CuePause = length(obj.Cue1)/obj.fs + 0.5;
            StimPause = length(obj.x1)/obj.fs;
            
            disp('Auditioning cues...')
            sound(obj.Cue1, obj.fs);
            pause(CuePause);

            sound(obj.Cue2, obj.fs);
            pause(CuePause);

            disp('Auditioning vibrato...')
            sound(obj.x1Vib, obj.fs);
            pause(StimPause);

            sound(obj.x2Vib, obj.fs);
            pause(StimPause);

            disp('Auditioning mixes...')
            sound(obj.MixNoVib, obj.fs);
            pause(StimPause);

            sound(obj.MixVib1, obj.fs);
            pause(StimPause);

            sound(obj.MixVib2, obj.fs);
            pause(StimPause);
        end

        function obj = inputCheck(obj) 
            obj.makeColumns();
            obj.checkMono();
            obj.matchLength();
        end
        
        function obj = makeColumns(obj)
            if size(obj.x1, 1) < size(obj.x1, 2)
                obj.x1 = obj.x1';
            end
            
            if size(obj.x2, 1) < size(obj.x2, 2)
                obj.x2 = obj.x2';
            end
        end
        
        function obj = checkMono(obj)
            if size(obj.x1, 2) ~= 1
                warning('%s is not a mono file. Taking first channel.', obj.Filename1);
                obj.x1 = obj.x1(:, 1);
            end
            
            if size(obj.x2, 2) ~= 1
                warning('%s is not a mono file. Taking first channel.', obj.Filename2);
                obj.x2 = obj.x2(:, 1);
            end
        end
        
        function obj = matchLength(obj)
            if length(obj.x1) > length(obj.x2)
                obj.x2 = [obj.x2; zeros(length(obj.x1) - length(obj.x2), 1)];
            else
                obj.x1 = [obj.x1; zeros(length(obj.x2) - length(obj.x1), 1)];
            end
        end
        
        function obj = matchLoudness(obj)
            %   Lower gain on louder sound to match quieter one.
            Mag1 = obj.calcPerceptMag(obj.x1);
            Mag2 = obj.calcPerceptMag(obj.x2);

            if Mag1 < Mag2
                obj.x2 = obj.x2 * Mag1/Mag2;
            else
                obj.x1 = obj.x1 * Mag2/Mag1;
            end
        end
        
        function obj = makeVibStim(obj)
            obj.x1Vib = randomVibrato(obj.x1, obj.fs, obj.VibRate, obj.VibDepth, ...
                obj.VibCycles, obj.NoVibBuffer);
            
            obj.x2Vib = randomVibrato(obj.x2, obj.fs, obj.VibRate, obj.VibDepth, ...
                obj.VibCycles, obj.NoVibBuffer);
        end
        
        function PerceptMag = calcPerceptMag(obj, x)
            Sones = acousticLoudness(x, obj.fs);
            Phons = obj.sones2phons(Sones);
            PerceptMag = db2mag(Phons);
        end
        
    end
    
    methods(Static)
        
        function Phons = sones2phons(Sones)
            Phons = 40 + 10*log2(Sones);
        end
        
    end
end