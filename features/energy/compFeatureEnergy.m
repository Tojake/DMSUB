
function [] = compFeatureEnergy(dirSrc, fileSrc, dirDest, fileDest)
% Computes the energetic mean of the given song file.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
p = 1;
precisionOutput = 6; % ouput precision

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);

% get energetic mean
energy = mean(abs(audio).^p);

% print energy to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, energy);
fclose(fileId);

end
