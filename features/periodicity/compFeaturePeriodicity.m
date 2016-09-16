
function [] = compFeaturePeriodicity(dirSrc, fileSrc, dirDest, fileDest)
% Separates the audio into windows and computes Pearson's correlation
% coefficients between each pair of windows. For every window, the
% corresponding entry in a vector is set to the maximum absolute
% correlation coefficient to the other windows. Feature vector is [m, s]
% with m = mean and s = standard deviation of that vector.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
windowSize = 100; % number of samples per window
precisionOutput = 6; % ouput precision

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);

% Pearson's correlation coefficients
drop = mod(length(audio), windowSize); % drop last window if incomplete
obs = (vec2mat(audio(1:end-drop), windowSize))';
pearsonsCorr = corrcoef(obs);
pearsonsCorr = pearsonsCorr - eye(length(pearsonsCorr)); % set main diagonal to zeros
pearsonsCorr(isnan(pearsonsCorr)) = 0; % clean NaN entries in pearsonsCorr

% maximum correlation
maxCorr = max(abs(pearsonsCorr));
features = [mean(maxCorr); std(maxCorr)];

% print mean and standard deviation to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, features);
fclose(fileId);

end
