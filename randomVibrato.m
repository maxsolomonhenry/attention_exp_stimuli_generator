%   TODO: adjustForVibratoLength is VERY SLOW (14s). Fix.

classdef RandomVibrato < handle
    %   Class for generating vibrato at a random spot in a stimulus, given
    %   certain criteria.
    %
    %   For use in the experiment "Directing attention in contemporary
    %   composition with timbre," Henry, Bao and Regnier for the Music
    %   Perception and Cognition Lab, McGill University. Summer, 2020.
    %
    
    properties
        
        Signal;
        fs;
        
        Out;
        
        VibRate;
        VibDepth;
        Cycles;
        NoVibBuffer;
        
        Location;
        VibIndex;
        VibModAmplitude;
        
        VibratoLength;
        NoVibBufSamps;
        SteadySectionsTimeline;
        AdjustedTimeline;
        VibStart;
    end
    
    properties (Constant)
    end
    
    methods
        
        %   Constructor
        function obj = RandomVibrato(fs, VibRate, VibDepth, ...
                Cycles, NoVibBuffer)
            
            %   fs          -->     Sample rate.
            %   VibRate     -->     Vibrato modulation rate in Hz.
            %   VibDepth    -->     Peak depth of vibrato in sample-deviation.
            %   Cycles      -->     Number of full cycles of modulation.
            %   NoVibBuffer -->     Time, in seconds, at beginning and end
            %                       of signal that won't have vibrato.
            
            obj.fs = fs;           
            obj.VibRate = VibRate;
            obj.VibDepth = VibDepth;
            
            obj.NoVibBufSamps = NoVibBuffer * obj.fs;
            obj.VibratoLength = floor(fs/obj.VibRate*Cycles);
        end
        
        function Out = addVibrato(obj, Signal)
            obj.Signal = Signal;
            
            obj.findVibratoStart();
            obj.makeVibIndexAndAmplitude();
            Out = obj.generateOutput();
        end
        
        function findVibratoStart(obj)
            obj.findSteadySections()
            obj.adjustForVibratoLength()
            obj.findRandomStartIndex()
        end
        
        function obj = findSteadySections(obj)
            %   TODO:   spectral flux/other critera here.
            
            obj.SteadySectionsTimeline = [zeros(obj.NoVibBufSamps, 1); ...
                ones(length(obj.Signal) - 2 * obj.NoVibBufSamps, 1); ...
                zeros(obj.NoVibBufSamps, 1)];
        end
        
        function obj = adjustForVibratoLength(obj)
            %   Extends "no vibrato start zone" backwards to compensate for
            %   vibrato length.

            if obj.VibratoLength > obj.NoVibBufSamps
                warning(['Vibrato length is longer than specified start buffer. ' ...
                    'Buffer will be extended to length of vibrato.']);
            end
            
            obj.AdjustedTimeline = obj.SteadySectionsTimeline;
            
            for i = (1:obj.VibratoLength-1)
                obj.AdjustedTimeline = obj.AdjustedTimeline .* ...
                    circshift(obj.SteadySectionsTimeline, -i);
            end
        end
        
        function obj = findRandomStartIndex(obj)
            if any(obj.AdjustedTimeline)
                obj.VibStart = obj.randomIndex(obj.AdjustedTimeline);
            else
                error('No candidate indecies for vibrato found.')
            end
        end
        
        function obj = makeVibIndexAndAmplitude(obj)
            %   Values to index the vibrato modulation oscillator.
            obj.VibIndex = [zeros(obj.VibStart, 1); (1:obj.VibratoLength)'; ...
                zeros(length(obj.Signal) - (obj.VibStart + obj.VibratoLength), 1)];
            
            %   Amplitude values for the vibrato oscillator (fades in/out).
            obj.VibModAmplitude = [zeros(obj.VibStart, 1); ...
                obj.VibDepth * hamming(obj.VibratoLength); ...
                zeros(length(obj.Signal) - (obj.VibStart + obj.VibratoLength), 1)];
        end
        
        function Out = generateOutput(obj)
            %   Step through Signal with modulated fractional indicies to
            %   build vibrato'ed output.
            
            Out = zeros(size(obj.Signal));
            
            for n = 1:length(obj.Signal)
                Out(n) = sincInterp(obj.Signal, n + obj.VibModAmplitude(n) * ...
                    (1  - cos(2*pi*obj.VibRate*obj.VibIndex(n)/obj.fs)), ...
                        obj.fs);
            end
        end
        
    end
    
    methods(Static)
        
        function Out = randomIndex(Timeline)
        NonZeroIndicies = find(Timeline);
        i = randi(length(NonZeroIndicies));
        Out = NonZeroIndicies(i);
        end
        
    end
    
end