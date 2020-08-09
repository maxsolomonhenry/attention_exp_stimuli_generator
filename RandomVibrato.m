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
%   sample deviation = (Alpha * fs) / (2 * pi * fm) , as per:
%
%   Dutilleux, P., M. Holters, S. Disch, and U. Zölzer. 2011. “Modulators 
%       and Demodulators.” In DAFX: Digital audio effects, edited by Udo 
%       Zölzer, 83–99. https://doi.org/10.1002/9781119991298.ch3.
%
%   Dattorro, Jon. 1997. “Part 2: Delay-line modulation and chorus.” 
%       Journal of the Audio Engineering Society 45 (10): 25.


classdef RandomVibrato < handle    
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
        CandidateTimeline;
        VibStart;
        
    end
    
    properties (Constant)
        AMP_ENV_SMOOTHING = 400;
        AMP_THRESHOLD = 0.01;
    end
    
    methods
        
        %   Constructor
        function obj = RandomVibrato(fs, VibRate, Alpha, ...
                Cycles, NoVibBuffer)

            obj.fs = fs;           
            obj.VibRate = VibRate;

            obj.SamplesDeviation = (Alpha) * fs / (2 * pi * VibRate);
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
            obj.makeCandidateTimeline();
            obj.findRandomStartIndex();
        end
        
        function obj = makeCandidateTimeline(obj)            
            %   Introduce "no vib buffer" at start/end.
            obj.CandidateTimeline = [zeros(obj.NoVibBufSamps, 1); ...
                ones(length(obj.Signal) - 2 * obj.NoVibBufSamps, 1); ...
                zeros(obj.NoVibBufSamps, 1)];   
            
            Envelope = obj.traceEnvelope(obj.Signal);
            AboveThreshold = (Envelope > obj.AMP_THRESHOLD);
            
            %   Don't place vibrato where signal is below amplitude threshold.
            obj.CandidateTimeline = obj.CandidateTimeline .* AboveThreshold;
        end
        
        function Envelope = traceEnvelope(obj, Signal)
            Analytic = hilbert(Signal);
            EnvelopeApprox = abs(Analytic);

            M = obj.AMP_ENV_SMOOTHING;
            b = 1/M * ones(M, 1);
            Envelope = filter(b, 1, EnvelopeApprox);
            
            % compensate for group delay
            Envelope = circshift(Envelope, -floor(M/2));
            Envelope = Envelope/max(abs(Envelope));
        end
        
        function obj = findRandomStartIndex(obj)
            obj.VibStart = obj.randomIndex(obj.CandidateTimeline);
        end
        
        function Out = randomIndex(obj, Timeline)
            NonZeroIndicies = find(Timeline);
            FoundAnIndex = false;
            
            for i = randperm(length(NonZeroIndicies))
                %   Check for a length of 1's long enough for vibrato.
                if prod(Timeline(i:i + obj.VibratoLength - 1) == 1)
                    FoundAnIndex = true;
                    break
                end
            end
            
            if ~FoundAnIndex
                error('No candidate indicies for vibrato found.')
            end
            
            Out = NonZeroIndicies(i);
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
    end
    
end