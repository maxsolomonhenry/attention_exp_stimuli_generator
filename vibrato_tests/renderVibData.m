function renderVibData(Filename, FileKey)
    RENDERED_DIR = 'rendered/';
    
    if ~exist(RENDERED_DIR, 'dir')
        mkdir(RENDERED_DIR);
    end

    Table = readtable(Filename);
    [~, Base, ~] = fileparts(Filename);
    
    NameParts = split(Base, '_');
    Part_ID = NameParts{1};
    Date = NameParts{2};
    
    OutFilename = [RENDERED_DIR Base '_rendered.txt'];
    FileID = fopen(OutFilename, 'w');
    fprintf(FileID, 'Part_ID\tDate\tTrialNo\tInst\tMel1\tMel2\tVibDepth\tAccuracy\n');
    
    TrialNo = 0;
    
    for Row = 8:43
        TrialNo = TrialNo + 1;
        
        Stim = Table(Row, 'stimulus');
        OriginalFilename = getFilenameFromKey(Stim.stimulus{1}, FileKey);
        
        [Inst, Mel1, Mel2, VibDepth, CorrectResp] = ...
            getInfoFromFilename(OriginalFilename);
        
        Resp = Table(Row, 'button_pressed');
        Accuracy = (Resp.button_pressed == CorrectResp);
        
        fprintf(FileID, '%s\t%s\t%d\t%s\t%d\t%d\t%d\t%d\n',Part_ID, Date, TrialNo, Inst, Mel1, Mel2, VibDepth, Accuracy);
    end
    
    fclose(FileID);
end