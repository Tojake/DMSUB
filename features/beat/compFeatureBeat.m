
function [] = compFeatureBeat(dirSrc, fileSrc, dirDest, fileDest)
% Computes first fourier coefficients of the beat frames of an audio file
% and prints them to a text file. Format is a list with one entry per line
% [m1, s1, m2, s2, ...] with mi = mean and si = standard deviation of the
% absolute value of the ith fourier coefficient (computed over multiple
% beat frames).
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
precisionOutput = 6; % ouput precision
lenBeat = 50; % in ms
numCoefs = 30; % number of fourier coefficients

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);
Fs = sideinfo.wav.fs;

% get beats
beats = round(beat(audio, Fs) * Fs);
beats = beats(2:end - 1);
beats = beats(1:end - mod(length(beats), 4));
lenBeats = length(beats);
lenFrame = ceil(lenBeat / 1000 * Fs);

% fourier coefficients
coefMatrix = zeros(lenBeats, numCoefs);
for b = 1:lenBeats
    firstSample = beats(b);
    lastSample = firstSample + lenFrame - 1;
    samples = audio(firstSample:lastSample);
    fourier = fft(samples);
    coefs = fourier(1:numCoefs);
    coefMatrix(b, :) = coefs;
end

% means and standard deviations
means = mean(abs(coefMatrix));
stddevs = std(abs(coefMatrix));
features = [means; stddevs];

% print coefficients to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, features);
fclose(fileId);

end
