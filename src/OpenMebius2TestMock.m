classdef OpenMebius2TestMock < OpenMebius2

    properties
        Test_InputAnswer string = "NewProject"
        Test_InputOK (1, 1) logical = true

        Test_Folder string = string(tempdir)
        Test_GetDirOK (1, 1) logical = true

        Test_File string = fullfile(string(tempdir), "dummy.txt")
        Test_Files string = [
                             fullfile(string(tempdir), "a.txt")
                             fullfile(string(tempdir), "b.txt")
                             ]
        Test_GetFileOK (1, 1) logical = true
    end

    methods (Access = protected)

        function [folder, isOK] = uiGetDirWrap(app, varargin)
            %#ok<*INUSD>
            if app.Test_GetDirOK
                folder = app.Test_Folder;
                isOK = true;
            else
                folder = "";
                isOK = false;
            end

        end

        function [answer, isOK] = uiInputDlgWrap(app, varargin)
            % Name-Value 呼び出しを吸収するために varargin を受ける

            % 本体互換：Prompt の数だけ返す（複数入力にも対応）
            n = 1;

            if ~isempty(varargin)

                try
                    opt = struct(varargin{:}); % Prompt=... を拾う

                    if isfield(opt, "Prompt")
                        n = numel(opt.Prompt);
                        if n == 0, n = 1; end
                    end

                catch
                    n = 1; % 変でも落とさない（テスト優先）
                end

            end

            if app.Test_InputOK
                answer = repmat(string(app.Test_InputAnswer), n, 1);
                isOK = true;
            else
                answer = strings(n, 1);
                isOK = false;
            end

        end

        function [files, isOK] = uiGetFileWrap(app, varargin)

            multi = "off";

            if ~isempty(varargin)

                try
                    opt = struct(varargin{:});

                    if isfield(opt, "MultiSelect")
                        multi = string(opt.MultiSelect);
                    end

                catch
                    multi = "off";
                end

            end

            if app.Test_GetFileOK
                isOK = true;

                if multi == "on"
                    files = string(app.Test_Files(:));
                else
                    files = string(app.Test_File);
                end

            else
                isOK = false;

                if multi == "on"
                    files = string.empty(0, 1);
                else
                    files = "";
                end

            end

        end

    end

end
