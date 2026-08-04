classdef BatchPreparationService
    % BATCHPREPARATIONSERVICE Refreshes analysis identity before execution.

    properties (SetAccess = private)
        ProvenanceBuilder
    end

    methods

        function obj = BatchPreparationService(options)

            arguments
                options.ProvenanceBuilder = ...
                    openmebius.application.analysis ...
                    .AnalysisProvenanceBuilder()
            end

            obj.ProvenanceBuilder = options.ProvenanceBuilder;

        end % constructor

        function [batchTable, changed, provenances] = prepare( ...
                obj, batchTable, ids, model, experiments)

            arguments
                obj (1, 1) openmebius.application.batch ...
                    .BatchPreparationService
                batchTable table
                ids string
                model
                experiments
            end

            ids = string(ids(:));
            changed = false(size(ids));
            provenances = cell(height(batchTable), 1);

            for i = 1:numel(ids)
                index = find(batchTable.id == ids(i), 1);

                if isempty(index)
                    error( ...
                        "OpenMebius2:BatchPreparationService:BatchNotFound", ...
                        "Batch ID not found: %s", ...
                        ids(i));
                end

                provenance = obj.ProvenanceBuilder.build( ...
                    batchTable.config(index), ...
                    batchTable.id(index), ...
                    model, ...
                    experiments, ...
                    string(batchTable.exp{index}));
                provenances{index} = provenance;
                previousHash = batchTable.contentHash(index);
                currentHash = string(provenance.contentHash);
                changed(i) = previousHash ~= currentHash;
                batchTable.contentHash(index) = currentHash;

                % Hash refresh must not reopen terminal batches. Finished
                % and failed results remain terminal until an explicit
                % status operation changes them.

            end

        end % prepare

    end % methods

end % classdef
