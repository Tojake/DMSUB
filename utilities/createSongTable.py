
import os

def createSongTable(pathFileSrc, pathFileDest, genre):
    """ Provided a dataset mapping file, prints all songs chosen for one genre
    to a text file usable for latex tables.
    """

    with open(pathFileSrc) as file:
        content = file.readlines()

    lsEntries = []

    for line in content:
        if line.find(genre, 0, len(genre)) == -1:
            continue

        line = line.replace('&', '\&')

        first = line.find('  --  ') + 6
        last = first + 4
        year = line[first:last]

        first = max(line.find('v_') + 2, line.find('/') + 1)
        last = line.find(' - ', first)
        interpret = line[first:last]

        first = last + 3
        last = line.find('.wav', first)
        year2 = line[last - 4 : last]
        if year2.isdigit():
            year = year2
            last -= 5
        title = line[first:last]

        if int(year) > 2016:
            year = 'N/A'
        lsEntries.append((year, interpret, title))

    lsEntries.sort()

    os.makedirs(os.path.dirname(pathFileDest), exist_ok = True)
    with open(pathFileDest, 'w') as file:
        for (year, interpret, title) in lsEntries:
            file.write(year + ' & ' + interpret + ' & ' + title + ' \\\\\n')


pathFileSrc = 'C:\\Users\\jakob\\Desktop\\_Map.txt'
pathFileDest = 'C:\\Users\\jakob\\Desktop\\'
lsGenres = ['deep', 'disco', 'house', 'soulful', 'techno']

if __name__ == '__main__':
    for g in lsGenres:
        createSongTable(pathFileSrc, pathFileDest + g + '.txt', g)