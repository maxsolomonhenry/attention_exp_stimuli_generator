function out = sincInterp(x, FracIndex, fs)
    %   Basic sinc interpolation.
    %
    %   For use in the experiment "Directing attention in contemporary
    %   composition with timbre," Henry, Bao and Regnier for the Music
    %   Perception and Cognition Lab, McGill University. June 24, 2020.
    %
    %   x           -->     Input sound.
    %   FracIndex   -->     Index value for sound (can be non-integer).
    %   fs          -->     Sample rate of input sound.

    a = floor(FracIndex);
    
    if FracIndex == a
        %   If index is integer, return value as normal.
        out = x(FracIndex);
    else
        b = ceil(FracIndex);
        i = mod(FracIndex, 1);
        
        %   Define first sample-value for interpolation.
        if a < 1
            A = x(1);
        else
            A = x(a);
        end
        
        %   Define second sample-value for interpolation.
        if b > length(x)
            B = x(end);
        else
            B = x(b);
        end
       
        %   Interpolate A and B.
        out = A * (1 - i) * sinc(i/fs) + B * i * sinc((1 - i)/fs);
    end
end