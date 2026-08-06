classdef BatchConfigEditor < handle
    % BATCHCONFIGEDITOR Applies domain edits to batch configurations.

    properties (Access = private)
        Collection openmebius.domain.batch.BatchCollection
    end

    methods

        function obj = BatchConfigEditor(collection)

            arguments
                collection (1, 1) openmebius.domain.batch.BatchCollection
            end

            obj.Collection = collection;

        end % constructor

        function ids = applyMSFragmentSelections( ...
                obj, selections, defaultFragmentNames, defaultMask)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchConfigEditor
                selections (1, :) struct
                defaultFragmentNames string
                defaultMask logical
            end

            requiredFields = ...
                ["BatchID", "ExperimentNames", "FragmentNames", ...
             "Selection"];

            for fieldName = requiredFields

                if ~isfield(selections, fieldName)
                    openmebius.domain.batch.BatchConfigEditor.invalidMSFragmentSelection( ...
                        "MS fragment selection is missing field %s.", ...
                        fieldName);
                end

            end

            defaultFragmentNames = string(defaultFragmentNames(:));
            defaultMask = logical(defaultMask(:));

            if numel(defaultFragmentNames) ~= numel(defaultMask)
                openmebius.domain.batch.BatchConfigEditor.invalidMSFragmentSelection( ...
                    "Default fragment names and selection mask must " + ...
                "have the same length.");
            end

            ids = strings(1, numel(selections));

            for i = 1:numel(selections)
                selection = selections(i);
                id = string(selection.BatchID);

                if ~isscalar(id) || strlength(id) == 0
                    openmebius.domain.batch.BatchConfigEditor.invalidMSFragmentSelection( ...
                    "BatchID must be a nonempty string scalar.");
                end

                experimentNames = string(selection.ExperimentNames(:)).';
                fragmentNames = string(selection.FragmentNames(:));
                selectionData = logical(selection.Selection);

                if size(selectionData, 1) ~= numel(fragmentNames) || ...
                        size(selectionData, 2) ~= numel(experimentNames)
                    openmebius.domain.batch.BatchConfigEditor.invalidMSFragmentSelection( ...
                        "MS fragment selection size does not match " + ...
                    "fragments and experiments.");
                end

                defaultSelection = ...
                    repmat(defaultMask, 1, size(selectionData, 2));
                isDefault = ...
                    isequal(fragmentNames, defaultFragmentNames) && ...
                    isequal(selectionData, defaultSelection);
                config = obj.Collection.configFor(id);
                config.isSelectMSFragment = ~isDefault;

                if isDefault
                    config.MS.fragment = 'all';
                else
                    config.MS.fragment = 'custom';
                end

                config.MS.customFragment = selectionData;
                config.MS.fragmentList = fragmentNames;
                config.MS.expList = experimentNames;
                obj.Collection.replaceConfig(id, config);
                ids(i) = id;
            end

        end % applyMSFragmentSelections

        function applyEfflux( ...
                obj, ids, selection, substrates, substrateSD)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchConfigEditor
                ids string
                selection logical
                substrates string
                substrateSD double
            end

            selection = logical(selection(:));
            substrates = string(substrates(:));
            substrateSD = double(substrateSD(:));

            if numel(selection) ~= numel(substrates) || ...
                    numel(substrateSD) ~= numel(substrates)
                error( ...
                    "OpenMebius2:BatchConfigEditor:InvalidEfflux", ...
                    "Efflux selection, substrate names, and standard " + ...
                "deviations must have the same length.");
            end

            ids = string(ids(:));

            for i = 1:numel(ids)
                config = obj.Collection.configFor(ids(i));
                currentSelection = logical(config.efflux.selection(:));
                currentSubstrates = string(config.efflux.substrate(:));
                currentSubstrateSD = double(config.efflux.substrateSD(:));

                if numel(currentSelection) ~= numel(currentSubstrates) || ...
                        numel(currentSubstrateSD) ~= numel(currentSubstrates)
                    error( ...
                        "OpenMebius2:BatchConfigEditor:InvalidEfflux", ...
                        "Stored efflux selection, substrate names, and " + ...
                    "standard deviations must have the same length.");
                end

                [~, newIndices, currentIndices] = ...
                    intersect(substrates, currentSubstrates);
                updatedSelection = currentSelection;
                updatedSubstrateSD = currentSubstrateSD;
                updatedSelection(currentIndices) = selection(newIndices);
                updatedSubstrateSD(currentIndices) = ...
                    substrateSD(newIndices);

                addedMask = ~ismember(substrates, currentSubstrates);
                updatedSubstrates = ...
                    [currentSubstrates; substrates(addedMask)];
                mergedSelection = ...
                    [updatedSelection; selection(addedMask)];
                mergedSubstrateSD = ...
                    [updatedSubstrateSD; substrateSD(addedMask)];
                [updatedSubstrates, sortIndices] = sort(updatedSubstrates);

                config.efflux.selection = ...
                    mergedSelection(sortIndices);
                config.efflux.substrate = updatedSubstrates;
                config.efflux.substrateSD = ...
                    mergedSubstrateSD(sortIndices);
                obj.Collection.replaceConfig(ids(i), config);
            end

        end % applyEfflux

        function applyGrowthRatePerturbation(obj, ids, selection, sd)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchConfigEditor
                ids string
                selection (1, 1) logical
                sd (1, 1) double
            end

            ids = string(ids(:));

            for i = 1:numel(ids)
                config = obj.Collection.configFor(ids(i));
                config.efflux.muSelection = selection;
                config.efflux.muSD = sd;
                obj.Collection.replaceConfig(ids(i), config);
            end

        end % applyGrowthRatePerturbation

        function applySuggestion( ...
                obj, ids, values, rowNames, variableNames)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchConfigEditor
                ids string
                values string
                rowNames string
                variableNames string
            end

            hasInvalidRowNames = ...
                ~isempty(rowNames) && size(values, 1) ~= numel(rowNames);

            if hasInvalidRowNames || ...
                    size(values, 2) ~= numel(variableNames)
                error( ...
                    "OpenMebius2:BatchConfigEditor:InvalidSuggestion", ...
                    "Suggestion values must match the row and variable " + ...
                "name dimensions.");
            end

            ids = string(ids(:));
            rowNames = string(rowNames(:));
            variableNames = string(variableNames(:)).';

            for i = 1:numel(ids)
                config = obj.Collection.configFor(ids(i));
                config.suggestionTable = values;
                config.suggestionTableRowNames = rowNames;
                config.suggestionTableVarNames = variableNames;
                obj.Collection.replaceConfig(ids(i), config);
            end

        end % applySuggestion

    end % methods

    methods (Static, Access = private)

        function invalidMSFragmentSelection(message, varargin)

            error( ...
                "OpenMebius2:BatchConfigEditor:InvalidMSFragmentSelection", ...
                message, ...
                varargin{:});

        end % invalidMSFragmentSelection

    end % methods (Static, Access = private)

end % classdef
