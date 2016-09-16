
import glob

def getFeatures(dirSrc, extFilesSrc, lsGenres):
    """ Reads samples in form of multiple text files and returns a pair of
    feature matrix X and target vector y.
    dirSrc:         Absolute path to directory of source text files
    extFilesSrc:    File extension of source text files (e.g. "txt")
    lsGenres:       List of target genres. Source text files are expected to be
                    in the form of <genre>*.<fileExtension>
    returns:        (X, y) where X is feature matrix and y is target vector
    """
    
    # correct path
    dirSrc = dirSrc.replace('\\', '/')
    if dirSrc[-1] != '/':
        dirSrc += '/'

    # get features
    features = []
    targets = []
    for genre in lsGenres:
        filesSrc = glob.glob(dirSrc + genre + '*.' + extFilesSrc)
        for pathFile in filesSrc:
            with open(pathFile) as file:
                featureVector = [float(line) for line in file]
            features.append(featureVector)
            targets.append(genre);

    return (features, targets)