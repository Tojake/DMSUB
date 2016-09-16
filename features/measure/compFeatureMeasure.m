
function [] = compFeatureMeasure(dirSrc, fileSrc, dirDest, fileDest)
% Separates the source audio in measures of four beats each. Then,
% Pearson's correlation coefficient is computed between each pair of
% consecutive measures. Resulting feature vector is [m, s] with m = mean
% and s = standard deviation of the coefficients.
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
precisionOutput = 6; % ouput precision
plotAudio = false;
plotFrame = 5; % in s
area = 60 / plotFrame;

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

if(plotAudio)
    figure; plot((0:length(audio)/area-1)/Fs,audio(1:end/area));
    for b = 1:length(beats)
        if mod(b - 1, 4) == 0
            line(beats(b) / Fs * [1 1], [-1.1 1.1], [-1, -1], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
        else
            line(beats(b) / Fs * [1 1], [-1.1 1.1], [-1, -1], 'Color', 'r', 'LineWidth', 1, 'LineStyle', '-.');
        end
    end
    xlim([0 length(audio)/Fs/area]);
    ylim([-1.1 1.1])
    xlabel('Time (sec)')
    pbaspect([5 1 1]);
    set(gca, 'FontSize', 7);
    print('measures.eps', '-depsc2');
end

corrMeas = zeros(lenMeas - 1, 1);

% Pearon's correlation coefficients between consecutive measures
firstSample = meas(1);
lastSample = firstSample + lenFrame - 1;
for m = 1:lenMeas - 1
    meas1 = audio(firstSample:lastSample);
    firstSample = meas(m + 1);
    lastSample = firstSample + lenFrame - 1;
    meas2 = audio(firstSample:lastSample);
    
    pearsonsCorr = corrcoef(meas1, meas2);
    corrMeas(m) = abs(pearsonsCorr(2, 1));
end

corrMeas(isnan(corrMeas)) = 0; % clean NaN entries in corrMeas
features = [mean(corrMeas); std(corrMeas)];

% print mean and standard deviation to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, features);
fclose(fileId);

end
