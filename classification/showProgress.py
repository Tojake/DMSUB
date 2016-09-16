
import sys

def showProgress(stepCur, stepsNeeded, bestRes = None):
    """ Prints a progress bar to console as well as the progress in steps.
    stepCur:        Integer describing the index of the current step
    stepsNeeded:    Integer describing the steps overall needed
    bestRes:        Optional float describing the best result so far
    """

    # constants
    width = 40
    cProc, cNotProc, cLeftBorder, cRightBorder = '#', '-', '[', ']'

    # get needed numbers of symbols
    numCProc = round(width * stepCur / stepsNeeded)
    numCNotProc = width - numCProc

    # print to console
    sys.stdout.write('\r{}{}{}{} {} / {}'.format(cLeftBorder, numCProc * cProc,
        numCNotProc * cNotProc, cRightBorder, stepCur, stepsNeeded))
    if bestRes is not None:
        sys.stdout.write(' (Best: {:.2f})'.format(bestRes))
    sys.stdout.flush()