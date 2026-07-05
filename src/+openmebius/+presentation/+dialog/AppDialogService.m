classdef AppDialogService < handle

    properties (Access = private)
        Parent
    end

    methods

        function obj = AppDialogService(parent)

            arguments
                parent = []
            end

            obj.Parent = parent;

        end % constructor

        function setParent(obj, parent)

            obj.Parent = parent;

        end

        function [folder, isOK] = selectFolder(obj, options)

            arguments
                obj
                options.Title (1, 1) string = "Select folder"
                options.StartPath (1, 1) string = string(pwd)
            end

            out = uigetdir( ...
                char(options.StartPath), ...
                char(options.Title));

            if isequal(out, 0)
                folder = "";
                isOK = false;
            else
                folder = string(out);
                isOK = true;
            end

        end % method selectFolder

        function [files, isOK] = selectFile(obj, options)

            arguments
                obj
                options.Filter = "*.*"
                options.Title (1, 1) string = "Select file"
                options.StartPath (1, 1) string = string(pwd)
                options.MultiSelect (1, 1) string {mustBeMember(options.MultiSelect, ["off", "on"])} = "off"
                options.Save (1, 1) logical = false
                options.DefaultName (1, 1) string = ""
                options.ConfirmOverwrite (1, 1) logical = true
            end

            filterSpec = obj.normalizeFilter(options.Filter);
            startPath = char(options.StartPath);
            titleText = char(options.Title);

            if options.Save

                if options.DefaultName ~= ""
                    startPath = char(fullfile(options.StartPath, options.DefaultName));
                end

                [fname, fpath] = uiputfile(filterSpec, titleText, startPath);

                if isequal(fname, 0) || isequal(fpath, 0)
                    files = string.empty(0, 1);
                    isOK = false;
                    return
                end

                filePath = string(fullfile(fpath, fname));

                if options.ConfirmOverwrite && isfile(filePath)

                    [answer, confirmed] = obj.confirm( ...
                        "The file already exists. Do you want to overwrite it?", ...
                        "File exists", ...
                        Options = ["Yes", "No"], ...
                        DefaultOption = "No", ...
                        CancelOption = "No", ...
                        Icon = "warning");

                    if ~confirmed || answer ~= "Yes"
                        files = string.empty(0, 1);
                        isOK = false;
                        return
                    end

                end

                files = filePath;
                isOK = true;
                return
            end

            if options.MultiSelect == "on"
                [fname, fpath] = uigetfile( ...
                    filterSpec, ...
                    titleText, ...
                    startPath, ...
                    "MultiSelect", "on");
            else
                [fname, fpath] = uigetfile( ...
                    filterSpec, ...
                    titleText, ...
                    startPath);
            end

            if isequal(fname, 0) || isequal(fpath, 0)
                files = string.empty(0, 1);
                isOK = false;
                return
            end

            if iscell(fname)
                files = strings(numel(fname), 1);

                for i = 1:numel(fname)
                    files(i) = string(fullfile(fpath, fname{i}));
                end

            else
                files = string(fullfile(fpath, fname));
            end

            isOK = true;

        end % method selectFile

        function [answer, isOK] = inputText(obj, options)

            arguments
                obj
                options.Prompt (1, :) string = "Input"
                options.Title (1, 1) string = "Input dialog"
                options.Default (1, :) string = ""
                options.Dims (1, 2) double = [1 50]
            end

            prompt = cellstr(options.Prompt(:));
            titleText = char(options.Title);

            n = numel(prompt);
            defaultValues = options.Default(:);

            if numel(defaultValues) == 0
                defaultValues = repmat("", n, 1);
            elseif isscalar(defaultValues) && n > 1
                defaultValues = repmat(defaultValues, n, 1);
            elseif numel(defaultValues) ~= n
                error( ...
                    "OpenMebius2:Dialog:DefaultSizeMismatch", ...
                "Default must be length 0, 1, or equal to number of prompts.");
            end

            out = inputdlg( ...
                prompt, ...
                titleText, ...
                options.Dims, ...
                cellstr(defaultValues));

            if isempty(out)
                answer = strings(n, 1);
                isOK = false;
            else
                answer = string(out);
                isOK = true;
            end

        end % method inputText

        function [answer, isOK] = confirm(obj, message, title, options)

            arguments
                obj
                message (1, 1) string
                title (1, 1) string = "Confirm"
                options.Options (1, :) string = ["OK", "Cancel"]
                options.DefaultOption (1, 1) string = "OK"
                options.CancelOption (1, 1) string = "Cancel"
                options.Icon (1, 1) string = "question"
            end

            if obj.hasValidParent()
                answer = uiconfirm( ...
                    obj.Parent, ...
                    char(message), ...
                    char(title), ...
                    "Options", cellstr(options.Options), ...
                    "DefaultOption", char(options.DefaultOption), ...
                    "CancelOption", char(options.CancelOption), ...
                    "Icon", char(options.Icon));

                answer = string(answer);
                isOK = answer ~= options.CancelOption;
                return
            end

            answer = questdlg( ...
                char(message), ...
                char(title), ...
                cellstr(options.Options), ...
                char(options.DefaultOption));

            if isempty(answer)
                answer = options.CancelOption;
            else
                answer = string(answer);
            end

            isOK = answer ~= options.CancelOption;

        end % method confirm

        function alert(obj, message, options)

            arguments
                obj
                message (1, 1) string
                options.Title (1, 1) string = "Message"
                options.Icon (1, 1) string = "info"
                options.Interpreter (1, 1) string = "none"
            end

            if obj.hasValidParent()
                uialert( ...
                    obj.Parent, ...
                    char(message), ...
                    char(options.Title), ...
                    "Icon", char(options.Icon), ...
                    "Interpreter", char(options.Interpreter));
                return
            end

            switch lower(options.Icon)
                case "error"
                    errordlg(char(message), char(options.Title));
                case "warning"
                    warndlg(char(message), char(options.Title));
                otherwise
                    msgbox(char(message), char(options.Title));
            end

        end % method alert

    end % methods

    methods (Access = private)

        function tf = hasValidParent(obj)

            tf = false;

            if isempty(obj.Parent)
                return
            end

            try
                tf = isvalid(obj.Parent);
            catch
                tf = false;
            end

        end % method hasValidParent

        function filterSpec = normalizeFilter(~, filter)

            filterSpec = filter;

            if isstring(filterSpec) && isscalar(filterSpec)
                filterSpec = char(filterSpec);
                return
            end

            if isstring(filterSpec)
                filterSpec = cellstr(filterSpec);
                return
            end

        end % method normalizeFilter

    end % methods (Access = private)

end % classdef
