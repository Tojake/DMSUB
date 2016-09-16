
function [] = compFeatureBPM(dirSrc, fileSrc, dirDest, fileDest)
% Computes the BPM of the given song file.
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

% get bpm
infoBPM = tempo(audio, Fs);
bpm1 = infoBPM(1);
bpm2 = infoBPM(2);
trend = infoBPM(3);
if trend > 0.5
    bpm = bpm1;
else
    bpm = bpm2;
end

% print BPM to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, bpm);
fclose(fileId);

end
