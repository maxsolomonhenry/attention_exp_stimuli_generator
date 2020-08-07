function Filename = getFilenameFromKey(CurrentName, FileKey)
    [~, Base, ~] = fileparts(CurrentName);
    Table = tdfread(FileKey);
    
    Filename = Table.Original(str2num(Base), :);
end