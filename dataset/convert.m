
function [] = convert(dirSrc, extFilesSrc, dirDest, extFilesDest, startFrame, lengthFrame)
% Takes the time frame of each source audio file in a given directory and
% creates a new corresponding audio file, converted to mono, 22050 Hz.
%
% pathSrc:      absolute or relative path to directory of source audio
% extFilesSrc:  file extension of source audio files (e.g. 'wav')
% pathDest:     absolute or relative path to directory of output file
% extFilesDest: file extension of ouput audio files. May be 'wav', 'ogg',
%                'flac', 'm4a' or 'mp4'
% startFrame:   beginning of time frame in seconds. If it is negative, 
%                startFrame denotes the absolute value of seconds before
%                the end of the audio file. If the string 'middle' is used
%                instead, the middle of each audio file is returned
% lengthFrame:  length of time frame in seconds. May not be less than zero
%                and may not be zero except for startFrame also equaling
%                zero: In this special case, the time frame taken is set to
%                the whole source audio.
%                Will be prioritized if startFrame plus lengthFrame exceed
%                length of source audio

if lengthFrame < 0 || (lengthFrame == 0 && startFrame ~= 0)
    error('Framelength has to be greater than zero');
end

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

if strcmp(startFrame, 'middle')
    useMiddle = true;
else
    useMiddle = false;
end

% get source directory contents
contentDir = dir(strcat(dirSrc, '*.', extFilesSrc));
filesSrc = {contentDir.name}';
numFiles = length(filesSrc);
lengthExtFilesSrc = length(extFilesSrc);

if ~exist(dirDest, 'file') && ~isempty(dirDest)
    mkdir(dirDest);
end

% create converted song for each source song
bar = waitbar(0, sprintf('0 / %u processed', numFiles));
for f = 1:numFiles
    % load song
    fileSrc = cell2mat(filesSrc(f));
    [audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);
    lengthAudio = length(audio);
    Fs = sideinfo.wav.fs;
    maxValue = max(abs(audio(:)));
    
    % convert from s to samples
    lengthFrameSam = lengthFrame * Fs;
    if useMiddle
        startFrameSam = round(lengthAudio/2 - lengthFrameSam/2 + 0.75);
    else
        startFrameSam = startFrame * Fs + 1;
    end
    
    % get first and last frame
    if startFrameSam == 1 && lengthFrameSam == 0
        % special case, take all samples
        firstSample = 1;
        lastSample = lengthAudio;
    elseif lengthFrameSam > lengthAudio
        % adjust number of samples to length of audio
        warning(['cut number of samples of ' fileSrc]);
        firstSample = 1;
        lastSample = lengthAudio;
    % keep number of samples
    elseif startFrameSam > 0 && startFrameSam + lengthFrameSam - 1 > lengthAudio
        % set last sample to end of audio and adjust first sample
        warning(['antidated start of frame of ' fileSrc]);
        lastSample = lengthAudio;
        firstSample = lastSample - lengthFrameSam + 1;
    elseif startFrameSam <= 0 && startFrameSam + lengthFrameSam - 1 > 0
        % set last sample to end of audio and adjust first sample
        warning(['antidated start of frame of ' fileSrc]);
        lastSample = lengthAudio;
        firstSample = lastSample - lengthFrameSam + 1;
    elseif startFrameSam <= 0 && abs(startFrameSam) > lengthAudio
        % set first sample to begin of audio and adjust last sample
        warning(['postponed start of frame of ' fileSrc]);
        firstSample = 1;
        lastSample = firstSample + lengthFrameSam - 1;
    else
        firstSample = mod(startFrameSam - 1, lengthAudio) + 1;
        lastSample = firstSample + lengthFrameSam - 1;
    end
    
    % write song
    pathFileDest = strcat(dirDest, fileSrc(1:end-lengthExtFilesSrc), extFilesDest);
    audiowrite(pathFileDest, audio(firstSample:lastSample) / maxValue, Fs);
    
    waitbar(f / numFiles, bar, sprintf('%u / %u processed', f, numFiles));
end
close(bar);

end
