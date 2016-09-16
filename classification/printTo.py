
import sys

def printTo(file = None, *args, **kwargs):
    """ Prints to console as well as to a file if one is provided.
    file:       file object corresponding to the file to which output is
                printed. If it is None, output is printed only to console
    *args:      arguments of print function
    **kwargs:   keyword arguments of print function
    """
    
    print(*args, **kwargs)
    if file is not None:
        sys.stdout = file
        print(*args, **kwargs)
        sys.stdout = sys.__stdout__