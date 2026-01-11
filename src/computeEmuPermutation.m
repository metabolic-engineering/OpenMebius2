function permBySize = computeEmuPermutation(oldFile, newFile)
    % computeEmuPermutation
    % 旧形式(X_old.txt)と新形式(X_new.txt)のEMU順を合わせるため、
    % 各サイズごと（各列ごと）の「旧 → 新 の行対応」を求める。
    %
    % 返り値 permBySize は長さ nSize の cell 配列。
    %   permBySize{j} は列 j (EMUサイズ j) のベクトルで、
    %   permBySize{j}(iOld) = iNew を意味する（空行は NaN）。

    % タブ区切り or 空白区切りのテキストを読み込む想定
    Xold = readcell(oldFile, "Delimiter", "\t");
    Xnew = readcell(newFile, "Delimiter", "\t");

    [nRow, nCol] = size(Xold);

    if ~isequal(size(Xnew), [nRow, nCol])
        error('X_old と X_new のサイズが一致しません。');
    end

    permBySize = cell(1, nCol);

    for jCol = 1:nCol % 各EMUサイズ列ごと (A1,A2,...)
        % その列の旧・新EMUをキー化
        keysOld = strings(nRow, 1);
        keysNew = strings(nRow, 1);

        for iRow = 1:nRow
            keysOld(iRow) = emuKeyFromOld(Xold{iRow, jCol});
            keysNew(iRow) = emuKeyFromNew(Xnew{iRow, jCol});
        end

        permCol = nan(nRow, 1);

        % 旧の各EMUについて、新のどこにあるか探す
        for iRow = 1:nRow

            if keysOld(iRow) == "" % 空 ( [] など ) はスキップ
                continue;
            end

            hit = find(keysNew == keysOld(iRow));

            if isempty(hit)
                error('列 %d, 旧行 %d: EMU %s に対応する新EMUが見つかりません。', ...
                    jCol, iRow, keysOld(iRow));
            elseif numel(hit) > 1
                error('列 %d: EMUキー %s が新リスト内で重複しています。', ...
                    jCol, keysOld(iRow));
            end

            permCol(iRow) = hit;
        end

        permBySize{jCol} = permCol;
    end

end

%% ==== 旧EMU名からキーを作るヘルパー（例外対応版） ====
function key = emuKeyFromOld(val)
    % val: 'AcCoA_emu2' や 'CO2_in_emu1' や [] など

    if isempty(val) || (isstring(val) && strlength(val) == 0)
        key = "";
        return;
    end

    if ismissing(val)
        key = "";
        return;
    end

    % cell の場合もあるので一旦文字列へ
    if isstring(val)
        s = char(val);
    elseif ischar(val)
        s = val;
    else
        % readcell で "[]" が文字列として入っているケース
        s = char(string(val));
    end

    s = strtrim(s);
    % '' で囲まれている場合の削除
    if startsWith(s, "'") && endsWith(s, "'")
        s = s(2:end - 1);
    end

    if strcmp(s, "[]")
        key = "";
        return;
    end

    % 'Met_emu123' をパース
    tok = regexp(s, '^(.*)_emu(\d+)$', 'tokens', 'once');

    if isempty(tok)
        error('旧EMU名の形式が想定と異なります: %s', s);
    end

    metName = tok{1};
    digits = tok{2}; % '2', '4', '123' など

    % メタボライト名正規化（'-' → '_'）
    metNameNorm = strrep(metName, '-', '_');

    % 数字 → A,B,C,... に変換
    idx = double(digits) - double('0'); % '1', '2' → 1, 2, ...
        letters = char(double('A') + idx - 1); % 1→'A',2→'B',...

    % ============================
    % 例外：Sym_SUC_emu4 を Sym_SUC_{A} とみなす
    % ============================
    if strcmp(metNameNorm, 'Sym_SUC') && strcmp(letters, 'D')
        letters = 'A';
    end

    key = string(metNameNorm) + "|" + string(letters);
end

%% ==== 新EMU名からキーを作るヘルパー ====
function key = emuKeyFromNew(val)
    % val: 'AcCoA_{B}' や 'IsoCit_{CDE}' や [] など

    if isempty(val) || (isstring(val) && strlength(val) == 0)
        key = "";
        return;
    end

    if ismissing(val)
        key = "";
        return;
    end

    if isstring(val)
        s = char(val);
    elseif ischar(val)
        s = val;
    else
        s = char(string(val));
    end

    s = strtrim(s);

    if startsWith(s, "'") && endsWith(s, "'")
        s = s(2:end - 1);
    end

    if strcmp(s, "[]")
        key = "";
        return;
    end

    % 'Met_{ABC}' をパース
    tok = regexp(s, '^(.*)_\{([A-Z]+)\}$', 'tokens', 'once');

    if isempty(tok)
        error('新EMU名の形式が想定と異なります: %s', s);
    end

    metName = tok{1};
    letters = tok{2}; % 'B', 'CD', 'ABCDE' など

    metNameNorm = strrep(metName, '-', '_');

    key = string(metNameNorm) + "|" + string(letters);
end
