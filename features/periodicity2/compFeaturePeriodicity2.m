
function [] = compFeaturePeriodicity2(dirSrc, fileSrc, dirDest, fileDest)
% Separates the audio into measures of four beats and computes Pearson's
% correlation coefficients between each pair of measures. For every
% measure, the corresponding entry in a vector is set to the maximum
% absolute correlation coefficient to the other measures. Feature vector is
% [m, s] with m = mean and s = standard deviation of that vector.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
precisionOutput = 6; % ouput precision

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);
Fs = sideinfo.wav.fs;

% get measures
beats = round(beat(audio, Fs) * Fs);
beats = beats(2:end - 1);
beats = beats(1:end - mod(length(beats), 4));
meas = beats(1:4:length(beats)); % positions of measures
lenFrame = min(meas(2:end) - meas(1:end - 1));
meas = meas(1:end - 1);
lenMeas = length(meas);

obs = zeros(lenFrame, lenMeas);
for m = 1:lenMeas
    firstSample = meas(m);
    lastSample = firstSample + lenFrame - 1;
    obs(:, m) = audio(firstSample:lastSample)';
end

% Pearson's correlation coefficients
pearsonsCorr = corrcoef(obs);
pearsonsCorr = pearsonsCorr - eye(length(pearsonsCorr)); % set main diagonal to zero
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
