
function [] = compFeatureTempo(dirSrc, fileSrc, dirDest, fileDest)
% Computes first fourier coefficients of the novelty curve of an audio file
% and prints them to a text file. Format is a list with one entry per line
% [m1, s1, m2, s2, ...] with mi = mean and si = standard deviation of the
% absolute value of the ith fourier coefficient (computed over multiple
% time windows).
%
% dirSrc:   absolute or relative path to directory of source audio. Has to
%            end with '/' or '\'
% fileSrc:  name of source audio file
% dirDest:  absolute or relative path to directory of output file. Has to
%            end with '/' or '\'
% fileDest: name of output file

% constants
numCoefs = 30; % number of fourier coefficients
windowLength = 6; % in s
dropThreshold = 0.75; % holds threshold ratio. If ratio of the number of values in the last window is beneath, the last window is dropped
precisionOutput = 6; % ouput precision
plotAudio = false;
plotNoveltyCurve = false;
plotInverseFourier = false;
plotInverseFourierAsArea = false;
plotFrame = 10; % in s
area = 60 / plotFrame;

% load song
[audio,sideinfo] = wav_to_audio('', dirSrc, fileSrc);
Fs = sideinfo.wav.fs;

if(plotAudio)
    figure; plot((0:length(audio)/area-1)/Fs,audio(1:end/area));
    xlim([0 length(audio)/Fs/area]);
    ylim([-1.1 1.1])
    xlabel('Time (sec)')
    pbaspect([5 1 1]);
    set(gca, 'FontSize', 7);
    print('audio.eps', '-depsc2');
end

% novelty curve
parameterNovelty = [];
[noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);
parameterVis = [];
parameterVis.featureRate = featureRate;

if(plotNoveltyCurve)
    visualize_noveltyCurve(noveltyCurve(1:end/area+2),parameterVis)
    pbaspect([5 1 1]);
    set(gca, 'FontSize', 7);
    print('noveltyCurve.eps', '-depsc2')
end

% fourier coefficients
numValues = length(noveltyCurve); % number of values
vs = round(featureRate); % values per s
vw = windowLength * vs; % values per window
numWindows = ceil(numValues / vs / windowLength); % number of windows
vwl = numValues - (numWindows-1)*vw; % values in the last window
noveltyCurve = [noveltyCurve zeros(1, vw - vwl)]; % fill last window of noveltyCurve with zeros

if vwl < dropThreshold * vw % drop last window if it is too small
    numWindows = numWindows - 1;
end

coefficientMatrix = zeros(numWindows, numCoefs); % resulting matrix (coef x wind)
for w = 1:numWindows
    idxFirst = (w-1)*vw + 1;
    idxLast = idxFirst + vw - 1;
    fourier = fft(noveltyCurve(idxFirst:idxLast));
    coefs = fourier(1:numCoefs);
    coefficientMatrix(w, :) = coefs;
end

if plotNoveltyCurve && plotInverseFourier
    hold on
    for w = 1:numWindows
        y = ifft(coefficientMatrix(w, :), vw);
        x = (1:vw) / vw * windowLength + (w-1) * windowLength;
        if mod(w, 2) == 0
            color = [1 0.1 0.1];
        else
            color = [0.6 0 0];
        end
        if plotInverseFourierAsArea
            h = area(x, abs(y));
            h.FaceColor = color;
            h.EdgeColor = color;
        else
            plot(x, abs(y), 'color', color)
        end
    end
    hold off
end

means = mean(abs(coefficientMatrix));
stddevs = std(abs(coefficientMatrix));
features = [means; stddevs];

% print coefficients to file
fileId = fopen(strcat(dirDest, fileDest), 'w+');
format = strcat('%.', int2str(precisionOutput), 'f\r\n%.', int2str(precisionOutput), 'f\r\n');
fprintf(fileId, format, features);
fclose(fileId);

end
