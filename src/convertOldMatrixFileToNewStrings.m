function A = convertOldMatrixFileToNewStrings(filepath, fluxLabel)
    % 旧形式で書かれた MA_4 = [...] のテキストファイルから、
    % 新形式の string 配列（各要素は " + r_20" など）を作る。
    %
    % 使用例:
    %   A4 = convertOldMatrixFileToNewStrings("../../eco_A4.txt", "r");

    txt = fileread(filepath);

    % "=[" の後ろから "];" の前までを抜き出す
    startIdx = regexp(txt, '=\s*\[', 'end', 'once');
    endIdx = regexp(txt, '\];', 'start', 'once');

    if isempty(startIdx) || isempty(endIdx)
        error('行列本体 (=[ ... ];) をテキスト中から見つけられませんでした。');
    end

    body = txt(startIdx:endIdx - 1);

    % 行ごとに分割
    rawLines = regexp(body, '\r\n|\n|\r', 'split');

    rowTokens = {}; % 各行のトークン(cell配列)を入れる
    maxCols = 0;

    for i = 1:numel(rawLines)
        line = strtrim(rawLines{i});

        % 空行や "[" だけの行はスキップ
        if isempty(line) || line == "["
            continue;
        end

        % 1行を「括弧の外の , / ;」で分割
        tokens = splitTopLevelByCommaAndSemicolon(line);

        if isempty(tokens)
            continue;
        end

        rowTokens{end + 1} = tokens; %#ok<AGROW>
        maxCols = max(maxCols, numel(tokens));
    end

    nRows = numel(rowTokens);
    A = strings(nRows, maxCols);

    % 各要素を新形式に変換
    for iRow = 1:nRows
        tokens = rowTokens{iRow};

        for jCol = 1:numel(tokens)
            expr = tokens{jCol};
            % "0" や空なら空文字のままにしておく
            if strcmp(expr, '0')
                A(iRow, jCol) = "";
            else
                A(iRow, jCol) = convertOldExpressionToNewString(expr, fluxLabel);
            end

        end

    end

end
