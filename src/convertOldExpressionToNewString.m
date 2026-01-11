function out = convertOldExpressionToNewString(expr, fluxLabel)
    % 文字列に統一
    expr = string(expr);
    expr = strtrim(expr);

    % 完全なゼロは空にする
    if expr == "" || expr == "0"
        out = "";
        return;
    end

    % 空白削除（全角含む）
    expr = regexprep(expr, '\s+', '');

    % + と - の前にスペースを入れてトークン化しやすくする
    % 例: "0-r(20,1)-r(23,1)" → "0 -r(20,1) -r(23,1)"
    %     "0+0.5*r(22,1)-r(17,1)" → "0 +0.5*r(22,1) -r(17,1)"
    expr2 = regexprep(expr, '([+-])', ' $1');
    tokens = strtrim(split(expr2));
    tokens(tokens == "") = [];

    if isempty(tokens)
        out = "";
        return;
    end

    pieces = strings(1, numel(tokens));
    idxPiece = 0;

    for k = 1:numel(tokens)
        t = tokens(k);

        % "0" は無視
        if t == "0"
            continue;
        end

        % 1) 分数係数: 1/2*r(22,1), -3/4*r(5,1) など
        m = regexp(t, '^([+-]?\d+\/\d+)\*?r\((\d+),1\)$', 'tokens', 'once');

        if ~isempty(m)
            coeff = eval(m{1}); % 1/2 → 0.5 など
            rxnIdx = str2double(m{2});

        else
            % 2) 小数係数: 0.5*r(22,1), -2.0*r(5,1) など
            m = regexp(t, '^([+-]?\d*\.?\d+)\*?r\((\d+),1\)$', 'tokens', 'once');

            if ~isempty(m)
                coeff = str2double(m{1});
                rxnIdx = str2double(m{2});

            else
                % 3) 単純な符号付き: r(22,1), +r(22,1), -r(22,1)
                m = regexp(t, '^([+-]?)r\((\d+),1\)$', 'tokens', 'once');

                if ~isempty(m)
                    sgn = m{1};

                    if sgn == "-"
                        coeff = -1;
                    else
                        coeff = +1; % "", "+" の場合
                    end

                    rxnIdx = str2double(m{2});
                else
                    error("予期しない項の形式です: %s", t);
                end

            end

        end

        % 符号部分（先頭も含め常に「± 」の形にする）
        if coeff > 0
            signStr = "+ ";
        else
            signStr = "- ";
        end

        % 係数部分
        absCoeff = abs(coeff);

        if absCoeff == 1
            coeffStr = ""; % 1 は省略: "+ r_3"
        else
            coeffStr = sprintf(' %.1f * ', absCoeff); % "+ 0.5 * "
        end

        idxPiece = idxPiece + 1;
        pieces(idxPiece) = signStr + coeffStr + sprintf('%s_%d', fluxLabel, rxnIdx);
    end

    % 実際に使った分だけに切り詰め
    pieces = pieces(1:idxPiece);

    if isempty(pieces)
        out = "";
    else
        % 各項の間に 1 つスペースを入れて連結
        % 例: "+ r_20" と "- r_23" → "+ r_20 - r_23"
        out = strjoin(pieces, " ");

        % 先頭にも半角スペースを付与
        % 例: "+ r_21" → " + r_21"
        out = " " + out;
    end

end
