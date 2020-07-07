%   TODO:   Add desctructor.
%           Make probes. (string parsing? maybe external)
%           Onset detector for random vibrato (spec flux?)

classdef StimulusGenerator < handle
    %
    %   Class for generating loudness-matched stimuli with random vibrato.
    %
    %   For use in the experiment "Directing attention in contemporary
    %   composition with timbre," Henry, Bao and Regnier for the Music
    %   Perception and Cognition Lab, McGill University. July 6, 2020.
    %
    
    properties
        
        Filename1;
        Filename2;

        MelodyNum;
        PartNum1;
        PartNum2;
        Instrument1;
        Instrument2;
        
        x1;
        x2;
        fs;
        
        x1Vib;
        x2Vib;
        
        GainChange;
        x1VibStart;
        x2VibStart;
        
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
        
        StimDir = "stims/";
    end
    
    methods
        
        function obj = StimulusGenerator(Filename1, Filename2)
            obj.Filename1 = Filename1;
            obj.Filename2 = Filename2;
                        
            [obj.x1, obj.fs] = audioread(Filename1);
            [obj.x2, ~] = audioread(Filename2);
            
            obj.parseFilenames();
            
            obj.inputCheck();
            obj.matchLoudness();
            
            obj.makeVibStim();
            obj.makeMixes();
            obj.makeCues();
        end
        
        function obj = parseFilenames(obj)
            Basename1 = obj.getBasename(obj.Filename1);
            Basename2 = obj.getBasename(obj.Filename2);
            
            Split1 = split(Basename1, '_');
            Split2 = split(Basename2, '_');
            
            if string(Split1(1)) ~= string(Split2(1))
                error("Melody numbers don\'t match. Please check the files and try again.");
            end
            
            obj.MelodyNum = string(Split1(1));
            
            obj.PartNum1 = string(Split1(2));
            obj.Instrument1 = string(Split1(3));
            
            obj.PartNum2 = string(Split2(2));
            obj.Instrument2 = string(Split2(3));
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
            
            disp('Auditioning cues...')
            obj.auditionCues();

            disp('Auditioning vibrato...')
            obj.auditionVibStim();

            disp('Auditioning mixes...')
            obj.auditionMixes();
        end
        
        function auditionCues(obj, WhichCue)
            DoBoth = false;
            CuePause = length(obj.Cue1)/obj.fs + 0.5;
            
            if nargin == 1
                DoBoth = true;
                WhichCue = 0;
            end
            
            if (WhichCue == 1 || DoBoth)
                sound(obj.Cue1, obj.fs);
                pause(CuePause);
            end

            if (WhichCue == 2 || DoBoth)
                sound(obj.Cue2, obj.fs);
                pause(CuePause);
            end
        end
        
        function auditionVibStim(obj, WhichVib)
            DoBoth = false;            
            StimPause = length(obj.x1)/obj.fs;
            
            if nargin == 1
                DoBoth = true;
                WhichVib = 0;
            end
            
            if (WhichVib == 1 || DoBoth)
                sound(obj.x1Vib, obj.fs);
                pause(StimPause);
            end

            if (WhichVib == 2 || DoBoth)
                sound(obj.x2Vib, obj.fs);
                pause(StimPause);
            end
        end
        
        function auditionMixes(obj, WhichMix)
            DoAll = false;
            StimPause = length(obj.x1)/obj.fs;
            
            if nargin == 1
                DoAll = true;
                WhichMix = 0;
            end

            if (WhichMix == 1 || DoAll)
                sound(obj.MixVib1, obj.fs);
                pause(StimPause);
            end

            if (WhichMix == 2 || DoAll)
                sound(obj.MixVib2, obj.fs);
                pause(StimPause);
            end
            
            if (WhichMix == 3 || DoAll)
                sound(obj.MixNoVib, obj.fs);
                pause(StimPause);
            end
            
        end
        
        function writeStimuli(obj)
            disp('Writing files...')
            obj.writeCues();
            obj.writeMixes();
            
            obj.makeLog();
            disp('Done.')
        end
        
        function writeCues(obj, WhichCue)
            DoBoth = false;
            
            if nargin == 1
                DoBoth = true;
                WhichCue = 0;
            end
            
            if (WhichCue == 1 || DoBoth)
                Basename1 = obj.getBasename(obj.Filename1);
                audiowrite(obj.StimDir + Basename1 + "_q.wav", obj.Cue1, obj.fs);
            end
            
            if (WhichCue == 2 || DoBoth)
                Basename2 = obj.getBasename(obj.Filename2); 
                audiowrite(obj.StimDir + Basename2 + "_q.wav", obj.Cue2, obj.fs);
            end
        end
        
        function writeMixes(obj, WhichMix)
            DoAll = false;
            
            MixName = obj.MelodyNum + "_" + obj.PartNum1 + "_" + obj.Instrument1 + ...
                "_" + obj.PartNum2 + "_" + obj.Instrument2;
            
            
            if nargin == 1
                DoAll = true;
                WhichMix = 0;
            end
            
            if (WhichMix == 1 || DoAll)
                audiowrite(obj.StimDir + MixName + "_V_" + obj.PartNum1 + ".wav", ...
                    obj.MixVib1, obj.fs);
            end
            
            if (WhichMix == 2 || DoAll)
                audiowrite(obj.StimDir + MixName + "_V_" + obj.PartNum2 + ".wav", ...
                    obj.MixVib2, obj.fs);
            end
            
            if (WhichMix == 3 || DoAll)
                audiowrite(obj.StimDir + MixName + "_N.wav", obj.MixNoVib, obj.fs);
            end
            
            
        end

        function makeLog(obj)
            LogFilename = obj.MelodyNum + "_" + obj.Instrument1 + ...
                "_" + obj.Instrument2 + "_log.txt";
            Today = datestr(datetime);
            
            fid = fopen(LogFilename, 'wt');
            fprintf(fid, "Gain change:\t%s\n", obj.GainChange);
            fprintf(fid, obj.Filename1 + "\t vib start:\t%s\n", obj.x1VibStart);
            fprintf(fid, obj.Filename2 + "\t vib start:\t%s\n", obj.x2VibStart);
            fprintf(fid, "\nDate:\t" + Today);
            fclose(fid);
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
                obj.GainChange = obj.Filename2 + " * " + ...
                    num2str(Mag1/Mag2);
            else
                obj.x1 = obj.x1 * Mag2/Mag1;
                obj.GainChange = obj.Filename1 + " * " + ...
                    num2str(Mag2/Mag1);
            end
            
            %   Divide gain by half to avoid clipping in mixes.
            obj.x1 = obj.x1/2;
            obj.x2 = obj.x2/2;
        end
        
        function obj = makeVibStim(obj, WhichVib)
            DoBoth = false;
            
            if nargin == 1
                DoBoth = true;
                WhichVib = 0;
            end
            
            if (WhichVib == 1 || DoBoth)
                [obj.x1Vib, Location1] = randomVibrato(obj.x1, obj.fs, ...
                    obj.VibRate, obj.VibDepth, obj.VibCycles, obj.NoVibBuffer);
                
                obj.x1VibStart = Location1 / obj.fs;
            end
            
            if (WhichVib == 2 || DoBoth)
                [obj.x2Vib, Location2] = randomVibrato(obj.x2, obj.fs, ...
                    obj.VibRate, obj.VibDepth, obj.VibCycles, obj.NoVibBuffer);
                
                obj.x2VibStart = Location2 / obj.fs;
            end
        end
        
        function PerceptMag = calcPerceptMag(obj, x)
            Sones = acousticLoudness(x, obj.fs);
            Phons = obj.sones2phons(Sones);
            PerceptMag = db2mag(Phons);
        end
        
    end
    
    methods(Static)
        
        function Basename = getBasename(Filename)
            Splitname = split(Filename, '.');
            Basename = Splitname(1);
        end
        
        function Phons = sones2phons(Sones)
            Phons = 40 + 10*log2(Sones);
        end
        
    end
end