# code taken from http://scikit-learn.org/stable/auto_examples/model_selection/plot_confusion_matrix.html

import numpy as np
import matplotlib.pyplot as plt
import os

def plotConfusionMatrix(cm, lsGenres, path, title = 'Confusion matrix',
        cmap = plt.cm.Blues):
    """ Given a confusion matrix and the corresponding genres in alphabetical
    order, plots the confusion matrix in color and saves it as picture at
    location <path>.
    """

    fig = plt.figure()

    plt.imshow(cm, interpolation = 'nearest', cmap = cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(lsGenres))
    plt.xticks(tick_marks, lsGenres, rotation = 45)
    plt.yticks(tick_marks, lsGenres)
    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')

    os.makedirs(os.path.dirname(path), exist_ok = True)
    plt.savefig(path)
    plt.close(fig)