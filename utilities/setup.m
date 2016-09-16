% Provided a collection of songs along with a text file listing their
% paths, automatically creates a dataset, computes ten different feature
% vectors and finally provides all combinations of them, normalizes them
% and reduces the dimensionality.

% constants
pathTextFile = 'F:\DataSet-0308.txt';
dirWaves = 'F:\Waves';
dirDataset = 'F:\DMSUB\datasetFull';
dirConverted = 'F:\DMSUB\dataset';
dirFeatures = 'F:\DMSUB\features';
dirMerged = 'F:\DMSUB\merged';
dirNormalized = 'F:\DMSUB\normalized';
dirReduced = 'F:\DMSUB\reduced';
features = {'tempo', 'pitch', 'amplitude', 'periodicity', 'mfcc', 'bpm', 'measure', 'beat', 'energy', 'length'};
lenFeatures = length(features);
exts = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

% do the work
buildDataSet(dirWaves, dirDataset, pathTextFile);
convert(dirDataset, 'wav', dirConverted, 'wav', 'middle', 60)

for f = 1:lenFeatures
    if strcmp(features{f}, 'length')
        compFeature(dirDataset, 'wav', dirFeatures, exts{f}, features{f});
    else
        compFeature(dirConverted, 'wav', dirFeatures, exts{f}, features{f});
    end
end

numSteps = 2^lenFeatures - 1;
progress = 0;
bar = waitbar(0, sprintf('0 / %u processed', numSteps));
for f = 1:lenFeatures
    subsets = nchoosek(exts, f);
    for s = 1:size(subsets, 1)
        ext = cell2mat(subsets(s, :));
        concatTextFiles(dirFeatures, subsets{s, :}, dirMerged, strcat('m', ext));
        normalize(dirMerged, strcat('m', ext), dirNormalized, strcat('f', ext));
        reduceDimensions(dirMerged, strcat('m', ext), dirReduced, strcat('f', ext));
        
        progress = progress + 1;
        waitbar(progress / numSteps, bar, sprintf('%u / %u processed', progress, numSteps));
    end
end
close(bar);
