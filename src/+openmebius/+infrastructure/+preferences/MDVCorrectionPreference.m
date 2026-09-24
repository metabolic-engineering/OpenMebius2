classdef MDVCorrectionPreference < handle
    % MDVCORRECTIONPREFERENCE Persists the MDV correction method.

    properties (Constant)
        DefaultMethod = "skew"
        SupportedMethods = [ ...
            "matrix", ...
            "skew", ...
            "least-squares", ...
            "least-squares-with-fraction"]
        SupportedMethodLabels = [ ...
            "Classical", ...
            "Skew method", ...
            "Skew least squares", ...
            "Least squares with fraction"]
        PreferenceFileName = "mdv_correction_method.txt"
        DefaultEnforceEnrichmentCalculation = false
        EnforceEnrichmentCalculationPreferenceFileName = ...
            "enforce_enrichment_calculation.txt"
    end

    properties (SetAccess = private)
        StorageDirectory (1, 1) string
    end

    methods

        function obj = MDVCorrectionPreference(options)

            arguments
                options.StorageDirectory (1, 1) string = ...
                    string(fullfile(prefdir, "OpenMebius2"))
            end

            if strlength(options.StorageDirectory) == 0
                error( ...
                    "OpenMebius2:MDVCorrectionPreference:" + ...
                    "EmptyStorageDirectory", ...
                    "The preference storage directory must not be empty.");
            end

            obj.StorageDirectory = options.StorageDirectory;

        end % constructor

        function method = getMethod(obj)

            path = obj.preferenceFile();

            if ~isfile(path)
                method = obj.DefaultMethod;
                return
            end

            try
                method = lower(strtrim(string(fileread(path))));
                method = method(1);
            catch
                method = obj.DefaultMethod;
                return
            end

            if ismissing(method) || ...
                    ~any(method == obj.SupportedMethods)
                method = obj.DefaultMethod;
            end

        end % getMethod

        function setMethod(obj, method)

            method = obj.validateMethod(method);
            obj.writePreference(obj.preferenceFile(), method);

        end % setMethod

        function enabled = getEnforceEnrichmentCalculation(obj)

            path = obj.enforceEnrichmentCalculationPreferenceFile();

            if ~isfile(path)
                enabled = obj.DefaultEnforceEnrichmentCalculation;
                return
            end

            try
                value = lower(strtrim(string(fileread(path))));
                value = value(1);
            catch
                enabled = obj.DefaultEnforceEnrichmentCalculation;
                return
            end

            if any(value == ["1", "true", "on"])
                enabled = true;
            elseif any(value == ["0", "false", "off"])
                enabled = false;
            else
                enabled = obj.DefaultEnforceEnrichmentCalculation;
            end

        end % getEnforceEnrichmentCalculation

        function setEnforceEnrichmentCalculation(obj, enabled)

            arguments
                obj
                enabled (1, 1) logical
            end

            obj.writePreference( ...
                obj.enforceEnrichmentCalculationPreferenceFile(), ...
                string(enabled));

        end % setEnforceEnrichmentCalculation

        function path = preferenceFile(obj)

            path = fullfile( ...
                obj.StorageDirectory, ...
                obj.PreferenceFileName);

        end % preferenceFile

        function path = enforceEnrichmentCalculationPreferenceFile(obj)

            path = fullfile( ...
                obj.StorageDirectory, ...
                obj.EnforceEnrichmentCalculationPreferenceFileName);

        end % enforceEnrichmentCalculationPreferenceFile

    end % methods

    methods (Access = private)

        function method = validateMethod(obj, method)

            method = lower(strtrim(string(method)));

            if isempty(method) || ~isscalar(method) || ...
                    ismissing(method) || ...
                    ~any(method == obj.SupportedMethods)
                error( ...
                    "OpenMebius2:MDVCorrectionPreference:InvalidMethod", ...
                    "Unknown MDV correction method '%s'.", ...
                    char(join(method, ", ")));
            end

        end % validateMethod

        function ensureStorageDirectory(obj)

            if ~isfolder(obj.StorageDirectory)
                [wasCreated, createMessage] = mkdir(obj.StorageDirectory);

                if ~wasCreated
                    error( ...
                        "OpenMebius2:MDVCorrectionPreference:" + ...
                        "DirectoryCreationFailed", ...
                        "Could not create the preference directory: %s", ...
                        createMessage);
                end

            end

        end % ensureStorageDirectory

        function writePreference(obj, path, value)

            obj.ensureStorageDirectory();
            temporaryPath = string(tempname(char(obj.StorageDirectory))) + ...
                ".txt";
            temporaryCleanup = onCleanup( ...
                @() obj.deleteIfPresent(temporaryPath));
            fileID = fopen(temporaryPath, "w");

            if fileID < 0
                error( ...
                    "OpenMebius2:MDVCorrectionPreference:WriteFailed", ...
                    "Could not open the MDV correction preference for writing.");
            end

            fileCleanup = onCleanup(@() obj.closeIfOpen(fileID));
            fprintf(fileID, "%s", value);
            fclose(fileID);
            clear fileCleanup

            [wasMoved, moveMessage] = movefile( ...
                temporaryPath, path, "f");

            if ~wasMoved
                error( ...
                    "OpenMebius2:MDVCorrectionPreference:WriteFailed", ...
                    "Could not save the MDV correction preference: %s", ...
                    moveMessage);
            end

        end % writePreference

    end % methods (Access = private)

    methods (Static, Access = private)

        function closeIfOpen(fileID)

            try
                fclose(fileID);
            catch
            end

        end % closeIfOpen

        function deleteIfPresent(path)

            if isfile(path)
                delete(path);
            end

        end % deleteIfPresent

    end % methods (Static, Access = private)

end % classdef
