
function [] = compFeature(dirSrc, extFilesSrc, dirDest, extFilesDest, feature)
% Computes a certain feature for each song file in a directory. For each
% song file, the corresponding feature is printed to a text file. Overall
% progess is shown in a waitbar.
%
% pathSrc:      absolute or relative path to directory of source audio
% extFilesSrc:  file extension of source audio files (e.g. 'wav')
% pathDest:     absolute or relative path to directory of output file
% extFilesDest: file extension of ouput text files (e.g. 'txt')
% feature:      string describing the computed feature. Possibilities are
%                'tempo', 'pitch', 'amplitude', 'periodicity', 'random',
%                'bpm', 'energy', 'length', 'beat', 'measure', 'mfcc',
%                'periodicity2'

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

% get source directory contents
contentDir = dir(strcat(dirSrc, '*.', extFilesSrc));
filesSrc = {contentDir.name}';
numFiles = length(filesSrc);
lengthExtFilesSrc = length(extFilesSrc);

if ~exist(dirDest, 'file') && ~isempty(dirDest)
    mkdir(dirDest);
end

% compute feature for each song file
bar = waitbar(0, sprintf('0 / %u processed', numFiles));
for f = 1:numFiles
    fileSrc = cell2mat(filesSrc(f));
    fileDest = strcat(fileSrc(1:end-lengthExtFilesSrc), extFilesDest);
    switch feature
        case 'tempo'
            compFeatureTempo(dirSrc, fileSrc, dirDest, fileDest);
        case 'pitch'
            compFeaturePitch(dirSrc, fileSrc, dirDest, fileDest);
        case 'amplitude'
            compFeatureAmplitude(dirSrc, fileSrc, dirDest, fileDest);
        case 'periodicity'
            compFeaturePeriodicity(dirSrc, fileSrc, dirDest, fileDest);
        case 'random'
            compFeatureRandom(dirDest, fileDest);
        case 'bpm'
            compFeatureBPM(dirSrc, fileSrc, dirDest, fileDest);
        case 'energy'
            compFeatureEnergy(dirSrc, fileSrc, dirDest, fileDest);
        case 'length'
            compFeatureLength(dirSrc, fileSrc, dirDest, fileDest);
        case 'beat'
            compFeatureBeat(dirSrc, fileSrc, dirDest, fileDest);
        case 'measure'
            compFeatureMeasure(dirSrc, fileSrc, dirDest, fileDest);
        case 'mfcc'
            compFeatureMFCC(dirSrc, fileSrc, dirDest, fileDest);
        case 'periodicity2'
            compFeaturePeriodicity2(dirSrc, fileSrc, dirDest, fileDest);
        otherwise
            close(bar);
            error(['Incorrect feature "', feature, '"']);
    end
    waitbar(f / numFiles, bar, sprintf('%u / %u processed', f, numFiles));
end
close(bar);

end
