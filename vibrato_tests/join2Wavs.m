function join2Wavs(Filename1, Filename2, GapInSecs, CorrectResponse)
    [~, Base1, Ext1] = fileparts(Filename1);
    [~, Base2, Ext2] = fileparts(Filename2);
    
    if Ext1 ~= Ext2
        error("Mis-matched file format.");
    end
    
    if ~exist('CorrectResponse', 'var')
        CorrectResponse = "";
    end
    
    OutFilename = Base1 + "__" + Base2 + "__" + CorrectResponse + Ext1;

    [x1, fs1] = audioread(Filename1);
    [x2, fs2] = audioread(Filename2);
    
    if fs1 ~= fs2
        error("Mis-matched sample rate.");
    end
    
    y = [x1; zeros(GapInSecs * fs1, 1); x2];
        
    audiowrite(OutFilename, y, fs1);
end