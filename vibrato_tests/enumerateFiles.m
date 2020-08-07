function enumerateFiles(Ext, Path)
    if ~exist('Ext', 'var')
        Ext = '.*';
    end

    if exist('Path', 'var')
        if Path(length(Path)) ~= '/'
            Path = [Path '/'];
        end
        
        Filenames = dir([Path '*' Ext]);
    else
        Path = [];
        Filenames = dir(['*' Ext]);
    end
    
    
    NewDir = [Path 'Numbered/'];
    mkdir(NewDir);
    FileID = fopen([NewDir 'filekey.txt'], 'w');
    
    FileCount = 0;
    
    fprintf(FileID, 'Numbered   	Original\n');
    
    for k = 1:length(Filenames)
        if Filenames(k).name(1) == '.'
            continue
        end
        
        [~, ~, Ext1] = fileparts(Filenames(k).name);
        
        FileCount = FileCount + 1;
        copyfile([Path Filenames(k).name], [NewDir num2str(FileCount) Ext1]);
        fprintf(FileID, '%d%-10s\t%s\n', FileCount, Ext1, Filenames(k).name);
    end
    
    fclose(FileID);
end