
function [] = checkWaves(dirSrc, pathFileClass)
% Checks if the songs specified in the text file exist.
%
% dirSrc:           absolute or relative path to (parent) directory of
%                    source audio
% pathFileClass:    absolute or relative path to text file providing the
%                    songs and their corresponding genres. Format of each  
%                    line is "| g  | <subpath>/<filename>.<extensions>
%                    <...>" where g is a character representing the genre.
%                    <subpath>/ is optional

if ~isempty(dirSrc)
    if ~strcmp(dirSrc(end), '/') && ~strcmp(dirSrc(end), '\')
        dirSrc = strcat(dirSrc, '/');
    end
end

% constants
firstRlvChar = 8; % column in which the subfolder of the song begins
lineFirst = 26; % first relevant line
minNumChars = 112; % minimum number of chars a line needs to be relevant
extFilesSrc = 'wav';
lenExtFilesSrc = length(extFilesSrc);
missingSongs = { % cell array of missing songs
    '1991/v_Rhythm On The Loose - Break Of Dawn (Original Mix).1991.wav',
    '2000/v_Rui Da Silva - Touch Me (Peace Division Mix).2000.wav',
    '2003/v_Reel People ft Angela Johnson - Can''t Stop (Acappella).wav'
};

fileId = fopen(pathFileClass);

% get number of lines in text file
numLines = 0;
while fgets(fileId) ~= -1
    numLines = numLines + 1;
end
numLines = numLines - lineFirst + 1;
frewind(fileId);

% skip first few lines
for line = 1:lineFirst-1
    fgetl(fileId);
end

% process text file
bar = waitbar(0, sprintf('0 / %u processed', numLines));
linesProc = -1;

while true
    % get next line
    line = fgetl(fileId);
    linesProc = linesProc + 1;
    waitbar(linesProc / numLines, bar, sprintf('%u / %u processed', linesProc, numLines));
    
    if ~ischar(line)
        % EOF reached
        break;
    end
    
    if length(line) < minNumChars
        continue;
    end
    
    % get id
    lastRlvChar = strfind(line, strcat('.', extFilesSrc));
    if isempty(lastRlvChar)
        continue;
    end
    id = line(firstRlvChar : lastRlvChar + lenExtFilesSrc);
    
    if ismember(id, missingSongs)
        continue;
    end
    
    % ignore songs from folder 2604 (not existing)
    year = line(firstRlvChar:firstRlvChar+3);
    if strcmp(year, '2604')
        continue;
    end
    
    % last check passed
    % windows incompatibility fix (replacing '"', ':', '?')
    os = getenv('OS');
    if strcmp(os, 'Windows_NT')
        id = strrep(id, '"', native2unicode([239 128 160], 'UTF-8'));
        id = strrep(id, ':', native2unicode([239 128 162], 'UTF-8'));
        id = strrep(id, '?', native2unicode([239 128 165], 'UTF-8'));
    end

    % fix songs from 2011 to 2014 and 2601
    if strcmp(year, '2011') || strcmp(year, '2012') || strcmp(year, '2013') || ...
            strcmp(year, '2014') || strcmp(year, '2601')
        id = strrep(id, '.2011', '');
        id = strrep(id, '.2012', '');
        id = strrep(id, '.2013', '');
        id = strrep(id, '.2014', '');
        id = strrep(id, '.2015', '');
        id = strrep(id, '.1999', '');
        id = strrep(id, '.1991', '');
    end

    % copy and rename
    pathSrc = strcat(dirSrc, id);
    if exist(pathSrc, 'file') ~= 2
        fprintf('Missing file in line %u: "%s"\n', linesProc + lineFirst, pathSrc);
    end
end

fclose(fileId);
close(bar);

end
