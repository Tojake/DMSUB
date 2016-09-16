
function [] = compFeatureMFCC(dirSrc, fileSrc, dirDest, fileDest)
% Computes MFCC using the given song file.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
precisionOutput = 6; % ouput precision
wintime = 0.025;
hoptime = 0.010;
numcep = 20;
maxfreq = 13000;
nbands = 40;

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);
Fs = sideinfo.wav.fs;

% compute MFCCs
[mfccs, asp, psp] = melfcc(audio, Fs, 'wintime', wintime, 'hoptime', hoptime, 'numcep', numcep, 'maxfreq', maxfreq, 'nbands', nbands);

means = mean(mfccs, 2);
vars = var(mfccs, 0, 2);
features = [means; vars];

% print means and variances to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, features);
fclose(fileId);

end
