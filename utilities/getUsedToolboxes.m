% Outputs the necessary MATLAB toolboxes for the .m files in the provided
% directory.
files = getFiles('C:\Users\jakob\Documents\GitRepos\bachelorthesis');

[a, products] = matlab.codetools.requiredFilesAndProducts(files);

{products.Name}'