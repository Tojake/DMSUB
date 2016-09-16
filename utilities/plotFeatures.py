
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'classification'))
from getFeatures import getFeatures
import genres
import numpy as np
import matplotlib.pyplot as plt

def plotFeatures(dirSrc, extFilesSrc, lsGenres, dimX, dimY = None):
    """ Plots the specified dimensions of the features given in dirSrc with file
    extension extFilesSrc to a coordinate system and shows the plot.
    """
    
    (X, y) = getFeatures(dirSrc, extFilesSrc, lsGenres)
    A = np.array(X)
    lsIdxGenres = [y.index(genre) for genre in lsGenres]
    lsIdxGenres.append(None)

    plt.figure()
    for i in range(len(lsIdxGenres) - 1):
        idx1, idx2 = lsIdxGenres[i], lsIdxGenres[i + 1]
        plt.plot(A[idx1:idx2, dimX - 1], A[idx1:idx2, dimY - 1], 'o')
    plt.show()
    


if __name__ == '__main__':
    dirSrc = 'F:\\-120to-60\\merged'
    extFilesSrc = '18.m3'
    lsGenres = genres.DMSUB
    dimX, dimY = 10, 11
    plotFeatures(dirSrc, extFilesSrc, lsGenres, dimX, dimY)