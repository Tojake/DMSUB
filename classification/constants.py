
""" Provides all settings for classify.py.
"""

import genres
import os
from itertools import combinations, chain

# general
dirSrc = 'F:\\DMSUB\\reduced'
pathFileDest = 'F:\\DMSUB\\results.txt'
lsFeatures = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] # helper
lsExtFilesSrc = list(chain.from_iterable(
    ('f' + ''.join(c),)
        for l in
            [combinations(lsFeatures, n) for n in range(1, len(lsFeatures) + 1)]
        for c in l
))

lsClassifier = ['SVM'] # <- ['SVM', 'KNN', 'AB', 'RF', 'ERT', 'VOT', 'BAG']
lsGenres = genres.DMSUB

numFolds = 5
numProcs = os.cpu_count()
chunksize = 10
printToFile = True
plotCM = False
pathPlotCM = 'F:\\DMSUB\\plots'

# SVM
svmKernels = ['rbf', 'sigmoid'] # <- ['linear', 'poly', 'rbf', 'sigmoid']
svmCost = [2**n for n in range(-5, 16, 2)] # <- R+
svmGamma = [2**n for n in range(-15, 4, 2)] # <- R+

# KNN
knnNumNeighbors = range(1, 100) # <- N
knnWeights = ['uniform', 'distance'] # <- ['uniform', 'distance']
knnNorm = range(1, 11) # <- N

# AB
if 'AB' in lsClassifier:
    from sklearn.tree import DecisionTreeClassifier
    abEstimator = [DecisionTreeClassifier()]
    abNumEstimators = [1000] # <- N

# RF
rfNumEstimators = [1000] # <- N

# ERT
ertNumEstimators = [1000] # <- N

# VOT
if 'VOT' in lsClassifier:
    from sklearn.svm import SVC
    from sklearn.neighbors import KNeighborsClassifier
    from sklearn.ensemble import ExtraTreesClassifier
    votEstimators = [[('svm', SVC(probability = True)),
                      ('knn', KNeighborsClassifier()),
                      ('ert', ExtraTreesClassifier(n_estimators = 500))
                    ]]

# BAG
if 'BAG' in lsClassifier:
    from sklearn.neighbors import KNeighborsClassifier
    bagEstimator = [KNeighborsClassifier()]
    bagNumEstimators = [100] # <- N
