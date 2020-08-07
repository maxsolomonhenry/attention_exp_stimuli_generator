function [Inst, Mel1, Mel2, VibDepth, CorrectResp] = getInfoFromFilename(Filename)
    [~, Base, ~] = fileparts(Filename);
    
    NameParts = split(Base, '__');
    
    Part1 = NameParts{1};
    Part2 = NameParts{2};
    Part3 = NameParts{3};
    
    Inst = Part1(1:3);
    Mel1 = str2double(Part1(4));
    Mel2 = str2double(Part2(4));
    
    if contains(Part1, 'vib')
        VibDepth = str2double(Part1(9:end));
    else
        VibDepth = str2double(Part2(9:end));
    end
    
    CorrectResp = str2double(Part3);
end