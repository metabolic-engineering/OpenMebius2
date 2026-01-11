function tokens = splitTopLevelByCommaAndSemicolon(line)
% 括弧のネストを考慮して、トップレベルの , / ; で分割する
%
% 入力:
%   line: 1行分の文字列
%
% 出力:
%   tokens: 各要素（'0-r(20,1)-r(23,1)' など）のセル配列

    line = strtrim(line);
    tokens = {};

    if isempty(line)
        return;
    end

    depth = 0;          % 括弧のネストレベル
    current = '';       % 現在構築中のトークン

    for k = 1:length(line)
        ch = line(k);

        % 括弧のネストレベル更新
        if ch == '('
            depth = depth + 1;
        elseif ch == ')'
            depth = max(depth - 1, 0);
        end

        % トップレベルの区切り , または ;
        if (ch == ',' || ch == ';') && depth == 0
            % ここまでの current をトークンとして確定
            token = strtrim(current);
            if ~isempty(token)
                tokens{end+1} = token; %#ok<AGROW>
            end
            current = '';
        else
            current(end+1) = ch; %#ok<AGROW>
        end
    end

    % 行末に残ったトークンを追加
    token = strtrim(current);
    if ~isempty(token)
        tokens{end+1} = token;
    end
end
