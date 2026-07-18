classdef BatchExperimentSelectionEditorController < handle
    % BATCHEXPERIMENTSELECTIONEDITORCONTROLLER Prepares RunAddBatch input.

    methods

        function outcome = prepareParallel(~, experiments)

            outcome = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController.execute( ...
                    @createRequest);

            function request = createRequest()

                experimentNames = string(getExpList(experiments));
                request = openmebius.application.batch ...
                    .BatchExperimentSelectionEditorRequest( ...
                        experimentNames(:), "parallel");

            end

        end % prepareParallel

        function outcome = prepareINSTMFA(~, session)

            arguments
                ~
                session (1, 1) openmebius.application.batch ...
                    .BatchConfigurationSession
            end

            outcome = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController.execute( ...
                    @createRequest);

            function request = createRequest()

                if ~session.isSingleBatch()
                    error( ...
                        "OpenMebius2:" + ...
                        "BatchExperimentSelectionEditorController:" + ...
                        "MultipleBatchesForINSTMFA", ...
                        "INST-MFA experiments can only be edited for " + ...
                        "a single batch.");
                end

                request = openmebius.application.batch ...
                    .BatchExperimentSelectionEditorRequest( ...
                        session.experimentNames(), ...
                        "inst-mfa", ...
                        session.BatchIds(1));

            end

        end % prepareINSTMFA

    end % methods

    methods (Static, Access = private)

        function outcome = execute(requestFactory)

            try
                request = requestFactory();
                outcome = openmebius.application.batch ...
                    .BatchExperimentSelectionEditorOutcome( ...
                        "finished", Result = request);
            catch exception
                outcome = openmebius.application.batch ...
                    .BatchExperimentSelectionEditorOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % execute

    end % methods (Static, Access = private)

end % classdef
