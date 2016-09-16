
import os

def filterResultsBest(pathFileSrc, pathFileDest, numFeatures = 10):
    """ Provided a result text file created by classify.py, filters the
    numFeatures best results contained in the file and prints them to the text
    file located at pathFileDest.
    """

    snippetFeature = '==========  '
    snippetAccuracy = 'Accuracy: '
    snippetStd = 'Std: '

    lsBest = []
    with open(pathFileSrc) as file:
        content = file.readlines()

    for line in content:
        if snippetFeature in line:
            first = len(snippetFeature)
            last = line.find(' ', first)
            feature = line[first:last]
        elif snippetAccuracy in line:
            first = len(snippetAccuracy)
            last = line.find(' ', first)
            accuracy = line[first:last]

            first = line.find(snippetStd, last)
            last = line.find(')', first)
            std = line[first:last]

            lsBest.append((accuracy, std, feature))

    lsBest.sort(reverse = True)

    os.makedirs(os.path.dirname(pathFileDest), exist_ok = True)
    with open(pathFileDest, 'w') as file:
        for i in range(0, numFeatures):
            feature = lsBest[i][2]
            accuracy = lsBest[i][0]
            std = lsBest[i][1]
            file.write(feature + ':\n' + accuracy + ', ' + std + '\n\n')


def filterResultsGhosal(pathFileSrc, pathFileDest):
    """ Provided a result text file created by classify.py, filters the
    best results exclusively obtained by features by Ghosal et al. contained in
    the file and prints them to the text file located at pathFileDest.
    """

    snippetFeature = '==========  '
    snippetAccuracy = 'Accuracy: '
    snippetStd = 'Std: '

    lsFeat = []
    with open(pathFileSrc) as file:
        content = file.readlines()

    for line in content:
        if snippetFeature in line:
            first = len(snippetFeature)
            last = line.find(' ', first)
            feature = line[first:last]
        elif snippetAccuracy in line:
            include = True
            for f in '456789':
                if f in feature:
                    include = False

            if include:
                first = len(snippetAccuracy)
                last = line.find(' ', first)
                accuracy = line[first:last]

                first = line.find(snippetStd, last)
                last = line.find(')', first)
                std = line[first:last]

                lsFeat.append((feature, accuracy, std))

    lsFeat.sort()

    os.makedirs(os.path.dirname(pathFileDest), exist_ok = True)
    with open(pathFileDest, 'w') as file:
        for t in lsFeat:
            feature = t[0]
            accuracy = t[1]
            std = t[2]
            file.write(feature + ':\n' + accuracy + ', ' + std + '\n\n')


path = 'D:\\OneDrive Business\\OneDrive - rwth-aachen.de\\Uni\\Thesis\\SVM\\'
pre = 'norm'
fileSrc = pre + '.txt'
fileDestBest = pre + '10best.txt'
fileDestGhosal = pre + 'Ghosal.txt'

if __name__ == '__main__':
    filterResultsBest(path + fileSrc, path + fileDestBest)
    filterResultsGhosal(path + fileSrc, path + fileDestGhosal)
