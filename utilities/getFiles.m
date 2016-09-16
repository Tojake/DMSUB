% Lists all .m files in the provided directory and its subdirectories.
function files = getFiles(dirSrc) 
    dirContentsM = dir(strcat(dirSrc, '/*.m'));
    files = {dirContentsM.name}';
    files(:) = strcat(dirSrc, '/', files(:));
    
    dirContentsD = dir(strcat(dirSrc, '/*'));
    dirContentsD(~[dirContentsD.isdir]) = [];
    dirContentsD = dirContentsD(3:end);
    dirs = {dirContentsD.name}';
    
    for d = 1:length(dirs)
        files = [files; getFiles(strcat(dirSrc, '/', cell2mat(dirs(d))))];
    end
    
end
