function debugSplitOldMatrix(filepath)

    txt = fileread(filepath);

    % "=[" の後から "];" までを抜き取る
    startIdx = regexp(txt, '=\s*\[', 'end', 'once');
    endIdx = regexp(txt, '\];', 'start', 'once');

    body = txt(startIdx:endIdx - 1);

    % 行ごとに split
    lines = regexp(body, '\n', 'split');

    disp("===== 行ごとに表示 =====");

    for i = 1:numel(lines)
        disp(lines{i});
    end

    disp("===== 各行を , で分割した結果 =====");

    for i = 1:numel(lines)
        cols = regexp(lines{i}, ',', 'split');
        fprintf("行 %d: ", i);
        disp(cols);
    end

end
