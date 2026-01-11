function selectedDir = dispDirList(type, select, directory, dirList)

    arguments
        type (1, 1) string;
        select (1, 1) string;
        directory (1, 1) string;
        dirList (1, :) string;
    end

    disp('Found ' + type + ' in "' + directory + '" are:');
    disp('_____________________________________________________________');

    for i = 1:length(dirList)
        disp('  ' + dirList(i));
    end

    disp('_____________________________________________________________');

    selectedDir = input('Please enter the directory of the ' + select + ': ', 's');
