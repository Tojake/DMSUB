
function [] = compFeaturePitch(dirSrc, fileSrc, dirDest, fileDest)
% Divides audio in overlapping time windows and computes for each time
% window for each pitch band STMSP. Average STMSP for each pitch band over
% all time windows is printed to a text file.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
precisionOutput = 6; % output precision
plotSTMSP = false;

% load song
[f_audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);

% STMSP
shiftFB = estimateTuning(f_audio);
paramPitch.winLenSTMSP = 4410; % results in 10 pitch values per second
paramPitch.shiftFB = shiftFB;
[f_pitch, sideinfo] = audio_to_pitch_via_FB(f_audio, paramPitch, sideinfo);

average = mean(f_pitch, 2) * ones(1, size(f_pitch, 2));

if plotSTMSP
    paramVis = [];
    paramVis.featureRate = 10;
    paramVis.ylabel = 'MIDI pitch';
    visualizePitch(average, paramVis);
    set(gca, 'XTickLabel', []);
    set(gca, 'FontSize', 11);
    pbaspect([1 1 1]);
    print('pitch.eps', '-depsc2');
end

pitches = average(21:108, 1);

% print STMSP means to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, pitches);
fclose(fileId);

end
