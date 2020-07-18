%   TODO:   turn into a class
%           develop/implement criteria functions for "steadytimeline"

function [Out, Location] = randomVibrato(Signal, fs, VibRate, VibDepth, Cycles, NoVibBuffer)
    %   Applies a brief artificial vibrato to an input signal. 
    %
    %   For use in the experiment "Directing attention in contemporary
    %   composition with timbre," Henry, Bao and Regnier for the Music
    %   Perception and Cognition Lab, McGill University. June 24, 2020.
    %
    %   Signal      -->     Input sound.
    %   fs          -->     Sample rate.
    %   VibRate     -->     Vibrato modulation rate in Hz.
    %   VibDepth    -->     Peak depth of vibrato in sample-deviation.
    %   Cycles      -->     Number of full cycles of frequency modulation.
    %   NoVibBuffer -->     Time, in seconds, at beginning and end of signal
    %                       that will not have vibrato.

    Out = zeros(size(Signal));
    VibratoLength = floor(fs/VibRate*Cycles);
    
    %   Find random location to initiate vibrato.
    Location = findRandomVibratoLoc(Signal, fs, VibratoLength, NoVibBuffer);
    
    %   Determine when to index vibrato modulator.
    VibWindow = [zeros(Location, 1); (1:VibratoLength)'; ...
        zeros(length(Signal) - (Location + VibratoLength), 1)];
    
    %   Vibrato depth timeline "windows" the modulation depth with hamming,
    %   to prevent abrupt vibrato onset/offset artifacts.
    DepthWindow = [zeros(Location, 1); VibDepth * hamming(VibratoLength); ...
        zeros(length(Signal) - (Location + VibratoLength), 1)];

    for n = 1:length(Signal)
        Out(n) = sincInterp(Signal, n + DepthWindow(n) * ...
                    (1  - cos(2*pi*VibRate*VibWindow(n)/fs)), fs);
    end

end

function VibratoLoc = findRandomVibratoLoc(Signal, fs, VibratoLength, NoVibBuffer)
    
    SteadyTimeline = getSteadyTimeline(Signal, NoVibBuffer, fs);
    VibStartCandidates = findStartCandidates(SteadyTimeline, VibratoLength);

    VibratoLoc = round(rand * (length(Signal) - 2 * NoVibBuffer * fs - VibratoLength)) ... 
        + NoVibBuffer * fs;
end

function SteadyTimeline = getSteadyTimeline(Signal, NoVibBuffer, fs)
    %   TODO:   fill this function with various criteria, to build a
    %           timeline of 1's and 0's.
    
    NoVibBufSamps = NoVibBuffer * fs;
    
    SteadyTimeline = [zeros(NoVibBufSamps, 1); ...
        ones(length(Signal) - 2 * NoVibBufSamps, 1); ...
        zeros(NoVibBufSamps, 1)];
end

function VibStartCandidates = findStartCandidates(SteadyTimeline, VibratoLength)
    %   Note:   this assumes a "no vibrato buffer" that's longer than vibrato 
    %           length.
    %
    %   Extends "no vibrato zone" backwards the length of the vibrato.
    %
    %   SteadyTimeline must be all 1's and 0's, (1 indicates no problems
    %   for vibrato).

    VibStartCandidates = SteadyTimeline;
    
    for i = (1:VibratoLength-1)
        VibStartCandidates = VibStartCandidates .* ...
            circshift(VibStartCandidates, -i);
    end
end