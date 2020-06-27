%   TODO:   Add desctructor.
%           Adjust loudness as appropriate to duos/solos (for cues).
%           Make cues.
%           Make probes.

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
        end
        
        function obj = makeMixes(obj)
            obj.MixNoVib = obj.x1 + obj.x2;
            obj.MixVib1 = obj.x1Vib + obj.x2;
            obj.MixVib2 = obj.x1 + obj.x2Vib;
            
            obj.MixNoVib = obj.MixNoVib/max(obj.MixNoVib);
            obj.MixVib1 = obj.MixVib1/max(obj.MixVib1);
            obj.MixVib2 = obj.MixVib2/max(obj.MixVib2);
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
            Mag1 = obj.calcPerceptMag(obj.x1);
            Mag2 = obj.calcPerceptMag(obj.x2);

            if Mag1 > Mag2
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