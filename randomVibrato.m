%   Class for generating vibrato at a random spot in a stimulus, given
%   certain criteria of note steadiness (spectral flux).
%
%   For use in the experiment "Directing attention in contemporary
%   composition with timbre," Henry, Bao and Regnier for the Music
%   Perception and Cognition Lab, McGill University. Summer, 2020.
%
%   RandomVibrato(fs, VibRate, Alpha, Cycles, NoVibBuffer)            
%
%   fs          -->     Sample rate.
%   VibRate     -->     Vibrato modulation rate in Hz.
%   Alpha       -->     Vibrato depth as +/- max. pitch deviation (percent).
%   Cycles      -->     Number of full cycles of modulation.
%   NoVibBuffer -->     Time, in seconds, at beginning and end
%                       of signal that won't have vibrato.
%
%   sample deviation = Alpha * fs / VibRate, as per:
%
%   Dutilleux, P., M. Holters, S. Disch, and U. Zölzer. 2011. “Modulators 
%       and Demodulators.” In DAFX: Digital audio effects, edited by Udo 
%       Zölzer, 83–99. https://doi.org/10.1002/9781119991298.ch3.
%
%   Dattorro, Jon. 1997. “Part 2: Delay-line modulation and chorus.” 
%       Journal of the Audio Engineering Society 45 (10): 25.


classdef RandomVibrato < handle    
%   TODO:   adjustForVibratoLength is VERY SLOW (14s).
%           Alpha --> should be divided by two? (distance max to min dev.)
%           Flux thresholding is broken.

    properties
        
        Signal;
        fs;
        
        Out;
        
        VibRate;
        SamplesDeviation;
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
        
        InterpolatedFlux;
        GatedFlux;
    end
    
    properties (Constant)
        FLUX_THRESHOLD = 0.5;
    end
    
    methods
        
        %   Constructor
        function obj = RandomVibrato(fs, VibRate, Alpha, ...
                Cycles, NoVibBuffer)

            obj.fs = fs;           
            obj.VibRate = VibRate;

            obj.SamplesDeviation = Alpha * fs / VibRate;
            obj.NoVibBufSamps = NoVibBuffer * obj.fs;
            obj.VibratoLength = floor(fs/obj.VibRate*Cycles);
        end
        
        %   Main method, adds vibrato given input signal.
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
            %   Introduce "no vib buffer" at start/end.
            obj.SteadySectionsTimeline = [zeros(obj.NoVibBufSamps, 1); ...
                ones(length(obj.Signal) - 2 * obj.NoVibBufSamps, 1); ...
                zeros(obj.NoVibBufSamps, 1)];
            
            obj.getGatedFlux();
            
            %   Exclude regions aboe spectral flux threshold.
            obj.SteadySectionsTimeline = obj.SteadySectionsTimeline .* ...
                obj.GatedFlux;       
        end
        
        function obj = getGatedFlux(obj)
            obj.getInterpolatedSpecFlux();
%             obj.InterpolatedFlux = [diff(obj.InterpolatedFlux, 1); 0];
            obj.GatedFlux = abs(obj.InterpolatedFlux) < obj.FLUX_THRESHOLD;
        end
        
        function obj = getInterpolatedSpecFlux(obj)
            N = length(obj.Signal);
            Flux = spectralFlux(obj.Signal, obj.fs);
            HopSize = round(obj.fs*0.02);
            obj.InterpolatedFlux = interp1(1:length(Flux), Flux, (1:N)/HopSize)';
            obj.InterpolatedFlux = obj.InterpolatedFlux / ...
                max(abs(obj.InterpolatedFlux));
        end
        
        function obj = adjustForVibratoLength(obj)
            %   Extends "no vibrato start zone" backwards to compensate for
            %   vibrato length.

            if obj.VibratoLength > obj.NoVibBufSamps
                warning(['Vibrato length is longer than specified start buffer. ' ...
                    'Buffer will be extended to length of vibrato.']);
            end
            
            obj.AdjustedTimeline = obj.SteadySectionsTimeline;
            
            for i = (1:obj.VibratoLength - 1)
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
                obj.SamplesDeviation * hamming(obj.VibratoLength); ...
                zeros(length(obj.Signal) - (obj.VibStart + obj.VibratoLength), 1)];
        end
        
        function Out = generateOutput(obj)
            %   Step through signal with modulated fractional indicies to
            %   build vibrato'ed output.
            
            Out = zeros(size(obj.Signal));
            
            for n = 1:length(obj.Signal)
                Out(n) = sincInterp(obj.Signal, n + obj.VibModAmplitude(n) * ...
                    (1  - cos(2*pi * obj.VibRate * obj.VibIndex(n)/obj.fs)), ...
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