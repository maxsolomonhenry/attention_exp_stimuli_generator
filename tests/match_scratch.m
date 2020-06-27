[x1, fs] = audioread('Melody1_Tpt.wav');
[x2, ~] = audioread('Melody1_Vl.wav');

x1 = x1(1:end-10, 2);
x2 = x2(:, 2);

y = matchAndMix(x1, x2, fs);
soundsc(y, fs);

function out = matchAndMix(x1, x2, fs)

    Mag1 = calcPerceptMag(x1, fs);
    Mag2 = calcPerceptMag(x2, fs);
    
    %   Gain up the quieter stimulus to match the louder one.
    if Mag1 > Mag2
        x2 = x2 * Mag1/Mag2;
    else
        x1 = x1 * Mag2/Mag1;
    end
    
    [x1, x2] = matchLength(x1, x2);
    
    out = x1 + x2;
    out = out/max(out);

end


function [y1, y2] = matchLength(x1, x2)
    
    if length(x1) == length(x2)
        y1 = x1;
        y2 = x2;
    elseif length(x1) > length(x2)
        y1 = x1;
        y2 = [x2; zeros(length(x1) - length(x2), 1)];
    else
        y1 = [x1; zeros(length(x2) - length(x1), 1)];
        y2 = x2;
    end

end

function Magnitude = calcPerceptMag(x, fs)

    Sones = acousticLoudness(x, fs);
    Phons = sones2phons(Sones);
    Magnitude = db2mag(Phons);
    
end

function Phons = sones2phons(Sones)

    Phons = 40 + 10*log2(Sones);
    
end