classdef ModelOperationController < handle
    % MODELOPERATIONCONTROLLER Runs model-area commands.

    properties (Access = private)
        TemplateModelLoadService
    end

    methods

        function obj = ModelOperationController(options)

            arguments
                options.TemplateModelLoadService = ...
                    openmebius.application.model.TemplateModelLoadService()
            end

            obj.TemplateModelLoadService = ...
                options.TemplateModelLoadService;

        end % constructor

        function outcome = loadTemplate(obj, modelLocation)

            arguments
                obj
                modelLocation openmebius.domain.model.ModelLocation
            end

            outcome = obj.execute( ...
                @() obj.TemplateModelLoadService.load(modelLocation));

        end % loadTemplate

        function outcome = saveModelTable(~, model, modelTable)

            arguments
                ~
                model
                modelTable table
            end

            outcome = openmebius.application.model ...
                .ModelOperationController.executeCommand(@saveTable);

            function result = saveTable()

                report = model.updateModelTableGUI(modelTable);
                result = openmebius.application.model.ModelEditResult( ...
                    ModelReport = report);

            end

        end % saveModelTable

        function outcome = saveMassSpectrometry( ...
                ~, model, msTable, atomTable)

            arguments
                ~
                model
                msTable table
                atomTable table
            end

            outcome = openmebius.application.model ...
                .ModelOperationController.executeCommand(@saveTables);

            function result = saveTables()

                msReport = model.updateMSTable(msTable);
                atomReport = model.updateAtomTable(atomTable);
                result = openmebius.application.model.ModelEditResult( ...
                    MSReport = msReport, ...
                    AtomReport = atomReport);

            end

        end % saveMassSpectrometry

    end % methods

    methods (Access = private)

        function outcome = execute(~, command)

            outcome = openmebius.application.model ...
                .ModelOperationController.executeCommand(command);

        end % execute

    end % methods (Access = private)

    methods (Static, Access = private)

        function outcome = executeCommand(command)

            try
                result = command();
                outcome = openmebius.application.model ...
                    .ModelOperationOutcome( ...
                        "finished", Result = result);
            catch exception
                outcome = openmebius.application.model ...
                    .ModelOperationOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % executeCommand

    end % methods (Static, Access = private)

end % classdef
