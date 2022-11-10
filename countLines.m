function count = countLines(fname)
% adapted from here: https://stackoverflow.com/a/12177413/10526646
fh = fopen(fname, 'rt');
assert(fh ~= -1, 'Could not read: %s', fname);
x = onCleanup(@() fclose(fh));
count = 0;
while ~feof(fh)
    count = count + sum( fread( fh, 16384, 'char' ) == char(10) );
end
end