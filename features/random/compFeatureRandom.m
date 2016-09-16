
function [] = compFeatureRandom(dirDest, fileDest)
% Computes random numbers as features.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
numFeatures = 100;
precisionOutput = 6; % ouput precision

% calculate random features
features = rand(numFeatures, 1);

% print features to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, features);
fclose(fileId);

end
