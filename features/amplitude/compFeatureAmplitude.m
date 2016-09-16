
function [] = compFeatureAmplitude(dirSrc, fileSrc, dirDest, fileDest)
% Computes the amplitude variation pattern of an audio signal. In order to
% do that, the differential signal is computed and quantized. A
% co-occurrence matrix is created which counts the number of occurrences of
% particular pairs in successive positions. As feature vector the sums of
% the lower diagonals are printed to a text file.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
windowSize = 5; % number of samples per window

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);

% smoothed signal
smoothed = mean(vec2mat(audio, windowSize), 2);
dropLast = (mod(length(audio), windowSize) ~= 0);

% differential signal
differential = zeros(length(smoothed) - 1 - dropLast, 1);
for j = 1:length(differential)
    differential(j) = abs(smoothed(j + 1) - smoothed(j));
end

% quantized signal
m = mean(differential);
s = std(differential);
quantized = quantiz(differential, m + (-2:0.25:2) * s) + 1;

% co-occurence matrix
cooccurrence = zeros(18);
for j = 1:length(quantized)-1
    idx1 = max([quantized(j) quantized(j + 1)]);
    idx2 = min([quantized(j) quantized(j + 1)]);
    cooccurrence(idx1, idx2) = cooccurrence(idx1, idx2) + 1;
end

% summed co-occurrence diagonals
diagSums = zeros(18, 1);
for j = 0:17
    diagSums(j + 1) = sum(diag(cooccurrence, -j));
end

% print summed co-occurrence diagonals to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
fprintf(fileId, '%u\r\n', diagSums);
fclose(fileId);

end
