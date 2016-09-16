
function [] = buildDataSet(dirSrc, dirDest, pathFileClass)
% Copies and renames the songs specified in a text file according to their
% genre. Output format is "<genre>.<number>.<extension>".
%
% dirSrc:           absolute or relative path to (parent) directory of
%                    source audio
% dirDest:          absolute or relative path to directory of output audio
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
if ~isempty(dirDest)
    if ~strcmp(dirDest(end), '/') && ~strcmp(dirDest(end), '\')
        dirDest = strcat(dirDest, '/');
    end
end

% constants
maxNumSongs = 100; % maximum number of songs per genre
indexGenre = 3; % column in which the subgenre is stored
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
showCounts = true;
buildWithB = false;
buildWithE = false;
printMap = true;
pathMap = strcat(dirDest, '_Map.txt');

lenDirSrc = length(dirSrc);

% subgenre indices
numGenres = 7;
T = 1; % techno, trance
H = 2; % house
S = 3; % soulful
D = 4; % deep
F = 5; % disco / funky
B = 6; % downbeat
E = 7; % electro
counts = zeros(numGenres, 1);

% create output directory if not already existing
if ~exist(dirDest, 'file') && ~isempty(dirDest)
    mkdir(dirDest);
end

memory = repmat({''}, numGenres, 1);
pathsSrcT = {};
pathsSrcH = {};
pathsSrcS = {};
pathsSrcD = {};
pathsSrcF = {};
pathsSrcB = {};
pathsSrcE = {};

fileId = fopen(pathFileClass);

% skip first few lines
for line = 1:lineFirst-1
    fgetl(fileId);
end

% process text file
while true
    % get next line
    line = fgetl(fileId);
    
    if ~ischar(line)
        % EOF reached
        break;
    end
    
    if length(line) < minNumChars
        continue;
    end
    
    % read genre
    switch line(indexGenre)
        case 'T'
            genre = T;
        case 'H'
            genre = H;
        case 'S'
            genre = S;
        case 'D'
            genre = D;
        case 'F'
            genre = F;
        case 'B'
            genre = B;
        case 'E'
            genre = E;
        otherwise
            continue;
    end
    counts(genre) = counts(genre) + 1;
    
    % check for other versions of the song file
    lastRlvChar = strfind(line, ' (');
    if isempty(lastRlvChar)
        % no open bracket found, search for '.' instead
        lastRlvChar = strfind(line, '.');
    end
    id = line(firstRlvChar:lastRlvChar-1);
    
    if strcmp(memory(genre), id)
        continue;
    end
    
    % extend id to full relative path
    lastRlvChar = strfind(line, strcat('.', extFilesSrc));
    if isempty(lastRlvChar)
        continue;
    end
    oldId = id;
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
    % store song in memory
    memory(genre) = {oldId};
    
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

    % store paths of source files
    pathSrc = strcat(dirSrc, id);
    switch genre
        case T
            pathsSrcT = [pathsSrcT; pathSrc];
        case H
            pathsSrcH = [pathsSrcH; pathSrc];
        case S
            pathsSrcS = [pathsSrcS; pathSrc];
        case D
            pathsSrcD = [pathsSrcD; pathSrc];
        case F
            pathsSrcF = [pathsSrcF; pathSrc];
        case B
            pathsSrcB = [pathsSrcB; pathSrc];
        case E
            pathsSrcE = [pathsSrcE; pathSrc];
    end
end

fclose(fileId);

% determine and copy song files
lenPathsSrc = zeros(numGenres, 1);
lenPathsSrc(T) = length(pathsSrcT);
lenPathsSrc(H) = length(pathsSrcH);
lenPathsSrc(S) = length(pathsSrcS);
lenPathsSrc(D) = length(pathsSrcD);
lenPathsSrc(F) = length(pathsSrcF);
lenPathsSrc(B) = length(pathsSrcB);
lenPathsSrc(E) = length(pathsSrcE);
if showCounts
    fprintf('Techno:   %u (%u)\n', counts(T), lenPathsSrc(T));
    fprintf('House:    %u (%u)\n', counts(H), lenPathsSrc(H));
    fprintf('Soulful:  %u (%u)\n', counts(S), lenPathsSrc(S));
    fprintf('Deep:     %u (%u)\n', counts(D), lenPathsSrc(D));
    fprintf('Disco:    %u (%u)\n', counts(F), lenPathsSrc(F));
    fprintf('Downbeat: %u (%u)\n', counts(B), lenPathsSrc(B));
    fprintf('Electro:  %u (%u)\n', counts(E), lenPathsSrc(E));
    fprintf('TOTAL:    %u (%u)\n', sum(counts), ...
        lenPathsSrc(T) + lenPathsSrc(H) + lenPathsSrc(S) + lenPathsSrc(D) + lenPathsSrc(F) + lenPathsSrc(B) + lenPathsSrc(E));
end
numSongsPerGenre = min([lenPathsSrc(T), lenPathsSrc(H), lenPathsSrc(S), lenPathsSrc(D), lenPathsSrc(F), maxNumSongs]);
if buildWithB
    numSongsPerGenre = min(numSongsPerGenre, lenPathsSrc(B));
end
if buildWithE
    numSongsPerGenre = min(numSongsPerGenre, lenPathsSrc(E));
end
numSongs = numSongsPerGenre * (numGenres - ~buildWithB - ~buildWithE);

if printMap
    fileId = fopen(pathMap, 'w+');
end

progress = 0;
bar = waitbar(0, sprintf('0 / %u processed', numSongs));
for genre = T:E
    switch genre
        case T
            pathsSrc = pathsSrcT;
            prefix = 'techno';
        case H
            pathsSrc = pathsSrcH;
            prefix = 'house';
        case S
            pathsSrc = pathsSrcS;
            prefix = 'soulful';
        case D
            pathsSrc = pathsSrcD;
            prefix = 'deep';
        case F
            pathsSrc = pathsSrcF;
            prefix = 'disco';
        case B
            if ~buildWithB
                continue;
            end
            pathsSrc = pathsSrcB;
            prefix = 'downbeat';
        case E
            if ~buildWithE
                continue;
            end
            pathsSrc = pathsSrcE;
            prefix = 'electro';
    end
    numSongsThis = lenPathsSrc(genre);
    idxChosenSongs = randperm(numSongsThis, numSongsPerGenre);
    pathsSrc = pathsSrc(idxChosenSongs);
    for file = 1:length(pathsSrc)
        pathSrc = pathsSrc{file};
        fileDest = strcat(prefix, '.', num2str(file, '%04u'), '.', extFilesSrc);
        pathDest = strcat(dirDest, fileDest);
        copyfile(pathSrc, pathDest);
        progress = progress + 1;
        waitbar(progress / numSongs, bar, sprintf('%u / %u processed', progress, numSongs));
        
        if printMap
            fprintf(fileId, '%s  --  %s\r\n', fileDest, pathSrc(1 + lenDirSrc : end));
        end
    end
end
close(bar);

fclose(fileId);

end
