
from getFeatures import getFeatures
from showProgress import showProgress
from printTo import printTo
import numpy as np
from sklearn import cross_validation, metrics
from multiprocessing import Pool
from constants import dirSrc, pathFileDest, lsExtFilesSrc, lsClassifier, \
    lsGenres, numFolds, numProcs, chunksize, printToFile, plotCM
if printToFile:
    import os
if plotCM:
    from constants import pathPlotCM
    from plotConfusionMatrix import plotConfusionMatrix
if 'SVM' in lsClassifier:
    from sklearn import svm
    from constants import svmKernels, svmCost, svmGamma
if 'KNN' in lsClassifier:
    from sklearn import neighbors
    from constants import knnNumNeighbors, knnWeights, knnNorm
if 'AB' in lsClassifier:
    from sklearn import ensemble
    from constants import abEstimator, abNumEstimators
if 'RF' in lsClassifier:
    from sklearn import ensemble
    from constants import rfNumEstimators
if 'ERT' in lsClassifier:
    from sklearn import ensemble
    from constants import ertNumEstimators
if 'VOT' in lsClassifier:
    from sklearn import ensemble
    from constants import votEstimators
if 'BAG' in lsClassifier:
    from sklearn import ensemble
    from constants import bagEstimator, bagNumEstimators


def classify(X, y, classFunc, lsDcParams):
    """ Uses exhaustive search to find the parameters generating the best
    classification accuracy. In order to do that, cross-validation scores are
    computed and compared.
    X:          Feature matrix
    y:          Target vector
    classFunc:  Classification function (e.g. svm.SVC)
    lsDcParams: List of dictionaries containing parameter names of the
                classification function as keys and corresponding values as
                values
    returns:    Tuple containing the best average score, corresponding standard
                deviation and a dictionary containing corresponging parameters
    """

    # preprocessing
    numStepsNeeded = len(lsDcParams)
    lsXyfParams = [(X, y, classFunc, dc) for dc in lsDcParams]

    if numStepsNeeded >= 2 * chunksize:
        # create processes computing multiple cross-validations
        procs = Pool(numProcs)
        results = procs.imap_unordered(workerClassify, lsXyfParams, chunksize)
        procs.close()

        # store best average score and show progress
        maxMeanScore = 0
        showProgress(0, numStepsNeeded)
        for step, result in enumerate(results, 1):
            meanScore = result[0]
            if meanScore > maxMeanScore:
                maxMeanScore = meanScore
                stdMaxScores, dcParams = result[1], result[2]
            showProgress(step, numStepsNeeded, maxMeanScore)
        procs.join()
    else:
        # use multiple processes for cross-validation
        maxMeanScore = 0
        showProgress(0, numStepsNeeded)
        for step in range(0, numStepsNeeded):
            result = workerClassify(lsXyfParams[step], True)
            meanScore = result[0]
            if meanScore > maxMeanScore:
                maxMeanScore = meanScore
                stdMaxScores, dcParams = result[1], result[2]
            showProgress(step + 1, numStepsNeeded, maxMeanScore)
    print()

    return (maxMeanScore, stdMaxScores, dcParams)


def workerClassify(XyfParams, single = False):
    """ Computes cross-validation for a combination of parameters.
    XyfParams:  Tuple in the form of (X, y, f, dcParams), where
                X:          Feature matrix
                y:          Target vector
                f:          Classification function (e.g. svm.SVC)
                dcParams:   Dict containing parameter names of the
                            classification function as keys and corresponding
                            values as values
    returns:    Tuple containing average score, corresponding standard deviation
                and a dictionary containing corresponding parameters
    """

    if single:
        n = numProcs
    else:
        n = 1

    (X, y, f, dcParams) = XyfParams
    clf = f(**dcParams)
    scores = cross_validation.cross_val_score(clf, X, y, cv = numFolds,
        n_jobs = n)
    return (scores.mean(), scores.std(), dcParams)


""" Provides classification scores for all combinations of classifiers and
features specified in constants.py.
"""
if __name__ == '__main__':
    if printToFile:
        os.makedirs(os.path.dirname(pathFileDest), exist_ok = True)
        file = open(pathFileDest, 'w')
    else:
        file = None

    for feature in lsExtFilesSrc:
        printTo(file)
        printTo(file, '==========  ' + feature + '  ==========')
        for classifier in lsClassifier:
            printTo(file)
            printTo(file, '----- ' + classifier + ' -----')
            printTo(file)
            (X, y) = getFeatures(dirSrc, feature, lsGenres)

            if classifier == 'SVM':
                f = svm.SVC
                lsDcParams = [{'kernel': k, 'C': c, 'gamma': g}
                    for c in svmCost for g in svmGamma for k in svmKernels]
            elif classifier == 'KNN':
                f = neighbors.KNeighborsClassifier
                lsDcParams = [{'n_neighbors': n, 'weights': w, 'p': p} for
                    n in knnNumNeighbors for w in knnWeights for p in knnNorm]
            elif classifier == 'AB':
                f = ensemble.AdaBoostClassifier
                lsDcParams = [{'base_estimator': b, 'n_estimators': n}
                    for b in abEstimator for n in abNumEstimators]
            elif classifier == 'RF':
                f = ensemble.RandomForestClassifier
                lsDcParams = [{'n_estimators': n} for n in rfNumEstimators]
            elif classifier == 'ERT':
                f = ensemble.ExtraTreesClassifier
                lsDcParams = [{'n_estimators': n} for n in ertNumEstimators]
            elif classifier == 'VOT':
                f = ensemble.VotingClassifier
                lsDcParams = [{'estimators': e, 'voting': 'soft'}
                    for e in votEstimators]
            elif classifier == 'BAG':
                f = ensemble.BaggingClassifier
                lsDcParams = [{'base_estimator': b, 'n_estimators': n}
                    for b in bagEstimator for n in bagNumEstimators]
            result = classify(X, y, f, lsDcParams)

            print()
            for (v, k) in result[2].items():
                printTo(file, '{} = {}'.format(v, k), end = ', ')
            printTo(file)
            printTo(file, 'Accuracy: {:.4f} (Std: {:.4f})'.format(result[0],
                result[1]))
            printTo(file)

            # get and plot confusion matrix
            clf = f(**result[2])
            yPred = cross_validation.cross_val_predict(clf, X, y, cv = numFolds,
                n_jobs = numProcs)
            cm = metrics.confusion_matrix(y, yPred)
            printTo(file, 'Confusion matrix:')
            printTo(file, cm)
            if plotCM:
                pathDest = pathPlotCM + '\\' + feature + '-' + classifier + \
                    '.png'
                plotConfusionMatrix(cm, lsGenres, path = pathDest, title = 
                    'Confusion matrix ( ' + feature + ' | ' + classifier + ' )')
        printTo(file)

    if file is not None:
        file.close()