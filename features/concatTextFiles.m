
function [] = concatTextFiles(varargin)
% Uses system calls to concatenate multiple text files in a directory.
% Concatenated content is printed to multiple ouput text files in output
% directory. Only implemented for Microsoft Windows yet.
%
% Arguments are interpreted as follows:
% Assume there are n arguments given, where n >= 5.
% arg_1:                        absolute path to directory of source text
%                                files. May be '' if it is the current
%                                directory. Must not contain '/' if
%                                executed on Microsoft Windows
% arg_2, arg_3, ..., arg_n-2:   file extensions of source text files. Files
%                                with the same name and matching the given
%                                extensions are concatenated each to an
%                                output text file
% arg_n-1:                      absolute path to directory of ouput text
%                                files. May be '' if it is the current
%                                directory. Must not contain '/' if
%                                executed on Microsoft Windows
% arg_n:                        file extension of the output text files

% check arguments
if nargin <= 3
    error('At least four arguments are required');
end

% check OS
os = getenv('OS');
if ~strcmp(os, 'Windows_NT')
    error('Only implemented for Microsoft Windows yet');
end

% extract arguments
dirSrc = varargin{1};
dirDest = varargin{end - 1};
extFilesDest = varargin{end};

if ~isempty(dirSrc)
    if ~strcmp(dirSrc(end), '\')
        dirSrc = strcat(dirSrc, '\');
    end
end
if ~isempty(dirDest)
    if ~strcmp(dirDest(end), '\')
        dirDest = strcat(dirDest, '\');
    end
end

% get files in directory
fileMatrix = []; % rows represent songs, columns represent features
for f = 2:nargin-2
    extFilesSrc = varargin{f};
    contentDir = dir(strcat(dirSrc, '*.', extFilesSrc));
    filesSrc = {contentDir.name}';
    fileMatrix = [fileMatrix, filesSrc];
end

% create ouput directory if not existing
if ~exist(dirDest, 'file') && ~isempty(dirDest)
    mkdir(dirDest);
end

% create and execute system call
[numSongs, numFeatures] = size(fileMatrix);
bar = waitbar(0, sprintf('0 / %u processed', numSongs));
for s = 1:numSongs
    fileSrc = cell2mat(fileMatrix(s, 1));
    fileDest = strcat(fileSrc(1:end-length(varargin{2})), extFilesDest);
    command = 'type ';
    for f = 1:numFeatures
        command = [command, dirSrc, cell2mat(fileMatrix(s, f)), ' '];
    end
    command = [command, '> ', dirDest, fileDest];
    
    [status, cmdout] = system(command);
    
    % check if successful
    if status ~= 0
        close(bar);
        error(['Error in system call "', command, '"']);
    end
    
    waitbar(s / numSongs, bar, sprintf('%u / %u processed', s, numSongs));
end
close(bar);

end
