classdef BatchConfigurationController < handle
    % BATCHCONFIGURATIONCONTROLLER Executes RunConfig commands.

    methods

        function outcome = apply(~, session, requestFactory)

            arguments
                ~
                session (1, 1) openmebius.application.batch ...
                    .BatchConfigurationSession
                requestFactory (1, 1) function_handle
            end

            try
                request = requestFactory();

                if ~isa(request, ...
                        "openmebius.application.batch." + ...
                        "BatchConfigurationApplyRequest")
                    error( ...
                        "OpenMebius2:BatchConfigurationController:" + ...
                        "InvalidRequest", ...
                        "Request factory must return a batch " + ...
                        "configuration apply request.");
                end

                if request.ApplySuggestion
                    suggestionTable = request.SuggestionTable;
                else
                    suggestionTable = [];
                end

                session.apply( ...
                    request.Config, ...
                    request.FragmentSelections, ...
                    suggestionTable);
                outcome = openmebius.application.batch ...
                    .BatchConfigurationApplyOutcome("finished");
            catch exception
                outcome = openmebius.application.batch ...
                    .BatchConfigurationApplyOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % apply

    end % methods

end % classdef
