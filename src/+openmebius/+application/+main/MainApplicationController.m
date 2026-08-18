classdef MainApplicationController < handle
    % MAINAPPLICATIONCONTROLLER Main App command boundary and Session owner.

    properties (Access = private)
        Session openmebius.application.session.MainApplicationSession
        ProjectController openmebius.application.project ...
            .ProjectOperationController
        ModelController openmebius.application.model.ModelOperationController
        LabelLaunchController openmebius.application.model ...
            .LabelConfigurationLaunchController
        ExperimentImportController openmebius.application.experiment ...
            .ExperimentImportController
        ExperimentCalculationController openmebius.application.experiment ...
            .ExperimentCalculationController
        ExperimentEditController openmebius.application.experiment ...
            .ExperimentEditController
        BatchController openmebius.application.batch.BatchOperationController
        BatchLaunchController openmebius.application.batch ...
            .BatchConfigurationLaunchController
        BatchSelectionController openmebius.application.batch ...
            .BatchExperimentSelectionEditorController
        BatchRunController openmebius.application.batch.BatchRunController
        ResultController openmebius.application.result ...
            .ResultOperationController
    end

    methods

        function obj = MainApplicationController(options)

            arguments
                options.Session (1, 1) openmebius.application.session ...
                    .MainApplicationSession
                options.ProjectController (1, 1) ...
                    openmebius.application.project.ProjectOperationController
                options.ModelController (1, 1) ...
                    openmebius.application.model.ModelOperationController
                options.LabelLaunchController (1, 1) ...
                    openmebius.application.model ...
                    .LabelConfigurationLaunchController
                options.ExperimentImportController (1, 1) ...
                    openmebius.application.experiment ...
                    .ExperimentImportController
                options.ExperimentCalculationController (1, 1) ...
                    openmebius.application.experiment ...
                    .ExperimentCalculationController
                options.ExperimentEditController (1, 1) ...
                    openmebius.application.experiment ...
                    .ExperimentEditController
                options.BatchController (1, 1) ...
                    openmebius.application.batch.BatchOperationController
                options.BatchLaunchController (1, 1) ...
                    openmebius.application.batch ...
                    .BatchConfigurationLaunchController
                options.BatchSelectionController (1, 1) ...
                    openmebius.application.batch ...
                    .BatchExperimentSelectionEditorController
                options.BatchRunController (1, 1) ...
                    openmebius.application.batch.BatchRunController
                options.ResultController (1, 1) ...
                    openmebius.application.result.ResultOperationController
            end

            names = string(fieldnames(options));

            for nameIndex = 1:numel(names)
                name = names(nameIndex);
                obj.(name) = options.(name);
            end

        end % constructor

        function value = model(obj)

            value = obj.Session.Model;

        end

        function value = project(obj)

            value = obj.Session.Project;

        end

        function value = experiments(obj)

            value = obj.Session.Experiments;

        end

        function value = batch(obj)

            value = obj.Session.Batch;

        end

        function value = result(obj)

            value = obj.Session.Result;

        end

        function tf = hasModel(obj)

            tf = obj.isValidHandle(obj.Session.Model);

        end

        function resetWorkspace(obj)

            obj.Session.clear();

        end

        function setNotificationReporter(obj, reporter)

            arguments
                obj
                reporter (1, 1) function_handle
            end

            obj.Session.setNotificationReporter(reporter);

        end

        function outcome = openProject(obj, projectInput)

            outcome = obj.ProjectController.open(projectInput);
            outcome = obj.commitProjectOutcome(outcome);

        end

        function outcome = saveProject( ...
                obj, projectInput, name, author, organism)

            outcome = obj.projectCommand(@saveProject);

            function value = saveProject()

                metadata = openmebius.domain.project.ProjectMetadata( ...
                    Name = name, Author = author, Organism = organism);
                value = obj.ProjectController.save( ...
                    obj.Session.Project, projectInput, metadata);

            end

            outcome = obj.commitProjectOutcome(outcome);

        end

        function outcome = createProject(obj, options)

            arguments
                obj
                options.ParentDirectory (1, 1) string
                options.ProjectDirectoryName (1, 1) string
                options.TemplateModelDirectory (1, 1) string
                options.Name (1, 1) string
                options.Author (1, 1) string
                options.Organism (1, 1) string
            end

            outcome = obj.projectCommand(@createProject);

            function value = createProject()

                metadata = openmebius.domain.project.ProjectMetadata( ...
                    Name = options.Name, ...
                    Author = options.Author, ...
                    Organism = options.Organism);
                value = obj.ProjectController.create( ...
                    ParentDirectory = options.ParentDirectory, ...
                    ProjectDirectoryName = ...
                    options.ProjectDirectoryName, ...
                    TemplateModelDirectory = ...
                    options.TemplateModelDirectory, ...
                    Metadata = metadata);

            end

            outcome = obj.commitProjectOutcome(outcome);

        end

        function outcome = duplicateProject(obj, options)

            arguments
                obj
                options.ParentDirectory (1, 1) string
                options.ProjectDirectoryName (1, 1) string
            end

            outcome = obj.projectCommand(@duplicateProject);

            function value = duplicateProject()

                value = obj.ProjectController.duplicate( ...
                    obj.Session.Project, ...
                    ParentDirectory = options.ParentDirectory, ...
                    ProjectDirectoryName = options.ProjectDirectoryName);

            end

        end % duplicateProject

        function outcome = loadTemplateModel(obj, directory)

            outcome = obj.modelCommand(@loadTemplate);

            function value = loadTemplate()

                location = openmebius.domain.model.ModelLocation ...
                    .fromDirectory(directory);
                value = obj.ModelController.loadTemplate(location);

            end

            outcome = obj.commitModelOutcome(outcome);

        end

        function outcome = saveModelTable(obj, modelTable)

            outcome = obj.ModelController.saveModelTable( ...
                obj.Session.Model, modelTable);

        end

        function outcome = saveMassSpectrometry(obj, msTable, atomTable)

            outcome = obj.ModelController.saveMassSpectrometry( ...
                obj.Session.Model, msTable, atomTable);

        end

        function outcome = setPathwayLabelPosition( ...
                obj, reactionID, position)

            outcome = obj.ModelController.setPathwayLabelPosition( ...
                obj.Session.Model, reactionID, position);

        end

        function outcome = removePathwayLabelPosition(obj, reactionID)

            outcome = obj.ModelController.removePathwayLabelPosition( ...
                obj.Session.Model, reactionID);

        end

        function outcome = prepareLabelConfiguration(obj)

            outcome = obj.LabelLaunchController.prepare(obj.Session.Model);

        end

        function outcome = applyLabelConfiguration( ...
                obj, labelTable, ratioTables)

            outcome = obj.ModelController.applyLabelConfiguration( ...
                obj.Session.Model, ...
                obj.Session.Experiments, ...
                obj.Session.Batch, ...
                labelTable, ...
                ratioTables);

        end

        function outcome = exportMassSpectrometryTemplate(obj, outputPath)

            outcome = obj.ModelController.exportMassSpectrometryTemplate( ...
                obj.Session.Model, outputPath);

        end

        function outcome = calculateExperiment( ...
                obj, infoTable, uptakeTable, tracerTable)

            outcome = obj.ExperimentCalculationController.calculate( ...
                obj.Session.Model, ...
                obj.Session.Experiments, ...
                obj.Session.Batch, ...
                infoTable, ...
                uptakeTable, ...
                tracerTable);

        end

        function outcome = importExperimentFiles( ...
                obj, experimentDirectory, files)

            outcome = obj.experimentImportCommand(@importFiles);

            function value = importFiles()

                location = openmebius.domain.experiment ...
                    .ExperimentLocation.fromDirectory(experimentDirectory);
                value = obj.ExperimentImportController.importFiles( ...
                    location, files, obj.Session.Model);

            end

            outcome = obj.commitExperimentImportOutcome(outcome);

        end

        function outcome = reloadExperiments(obj, experimentDirectory)

            outcome = obj.experimentImportCommand(@reloadExperiments);

            function value = reloadExperiments()

                location = openmebius.domain.experiment ...
                    .ExperimentLocation.fromDirectory(experimentDirectory);
                value = obj.ExperimentImportController.reload( ...
                    location, obj.Session.Model);

            end

            outcome = obj.commitExperimentImportOutcome(outcome);

        end

        function outcome = importRawMS( ...
                obj, rawInput, experimentDirectory)

            outcome = obj.experimentImportCommand(@importRawMS);

            function value = importRawMS()

                location = openmebius.domain.experiment ...
                    .ExperimentLocation.fromDirectory(experimentDirectory);
                value = obj.ExperimentImportController ...
                    .importShimadzuASCII( ...
                    rawInput, location, obj.Session.Model);

            end

            outcome = obj.commitExperimentImportOutcome(outcome);

        end

        function outcome = saveExperimentInfo(obj, infoTable)

            outcome = obj.ExperimentEditController.saveInfo( ...
                obj.Session.Model, ...
                obj.Session.Experiments, ...
                obj.Session.Batch, ...
                infoTable);

        end

        function outcome = saveTracer(obj, uptakeTable, tracerTable)

            outcome = obj.ExperimentEditController.saveTracer( ...
                obj.Session.Model, ...
                obj.Session.Experiments, ...
                obj.Session.Batch, ...
                uptakeTable, ...
                tracerTable);

        end

        function outcome = prepareTracerConfiguration( ...
                obj, tracerTable, position)

            outcome = obj.ExperimentEditController ...
                .prepareTracerConfiguration( ...
                obj.Session.Experiments, tracerTable, position);

        end

        function outcome = applyTracerConfiguration( ...
                obj, position, editorTable)

            outcome = obj.ExperimentEditController ...
                .applyTracerConfiguration(position, editorTable);

        end

        function outcome = copyTracerToAllEntries( ...
                obj, tracerTable, selection)

            outcome = obj.ExperimentEditController ...
                .copyTracerToAllEntries( ...
                obj.Session.Model, ...
                obj.Session.Experiments, ...
                obj.Session.Batch, ...
                tracerTable, ...
                selection);

        end

        function [outcome, batch] = autoFillBatch(obj)

            batch = obj.Session.Batch;
            outcome = obj.BatchController.autoFill(batch);

        end

        function outcome = prepareBatchConfiguration(obj, requestFactory)

            outcome = obj.BatchLaunchController.prepare( ...
                obj.Session.Batch, ...
                obj.Session.Experiments, ...
                requestFactory);

        end

        function [outcome, batch] = saveBatch(obj, tableData)

            batch = obj.Session.Batch;
            outcome = obj.BatchController.save(batch, tableData);

        end

        function [outcome, batch] = removeBatches(obj, batchIds)

            batch = obj.Session.Batch;
            resultLocation = obj.Session.Project.Paths.resultLocation();
            outcome = obj.BatchController.remove( ...
                batch, batchIds, resultLocation);

        end

        function statuses = getBatchStatuses(obj, batchIds)

            statuses = obj.Session.Batch.getBatchStatus(batchIds);

        end

        function [outcome, batch] = duplicateBatches( ...
                obj, batchIds, tableData)

            batch = obj.Session.Batch;
            outcome = obj.BatchController.duplicate( ...
                batch, batchIds, tableData);

        end

        function [outcome, batch] = moveBatches( ...
                obj, batchIds, direction, tableData)

            batch = obj.Session.Batch;
            outcome = obj.BatchController.move( ...
                batch, batchIds, direction, tableData);

        end

        function [outcome, batch] = applyBatchExperimentSelection( ...
                obj, selection)

            batch = obj.Session.Batch;
            outcome = obj.BatchController.applyExperimentSelection( ...
                batch, selection);

        end

        function outcome = prepareParallelBatch(obj)

            outcome = obj.BatchSelectionController.prepareParallel( ...
                obj.Session.Experiments);

        end

        function outcome = runBatch(obj, resultDirectory, options)

            arguments
                obj
                resultDirectory
                options.ProgressReporter (1, 1) function_handle = @(~) []
                options.NotificationReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
                options.WorkspaceSnapshot = []
            end

            if ~isempty(options.WorkspaceSnapshot)
                snapshot = options.WorkspaceSnapshot;

                if ~isa(snapshot, ...
                        ['openmebius.application.batch.' ...
                        'BatchRunWorkspaceSnapshot'])
                    error( ...
                        "OpenMebius2:BatchRun:InvalidWorkspaceSnapshot", ...
                        "Batch run workspace snapshot is invalid.");
                end

                experimentOutcome = obj.ExperimentEditController.saveAll( ...
                    obj.Session.Model, ...
                    obj.Session.Experiments, ...
                    obj.Session.Batch, ...
                    snapshot.InformationTable, ...
                    snapshot.UptakeTable, ...
                    snapshot.TracerTable);

                if experimentOutcome.isFailure()
                    outcome = obj.batchRunPreparationFailure( ...
                        experimentOutcome);
                    return
                end

                batchOutcome = obj.BatchController.save( ...
                    obj.Session.Batch, snapshot.BatchTable);

                if batchOutcome.isFailure()
                    outcome = obj.batchRunPreparationFailure(batchOutcome);
                    return
                end

            end

            outcome = obj.BatchRunController.run( ...
                obj.Session.Batch, ...
                resultDirectory, ...
                ProgressReporter = options.ProgressReporter, ...
                NotificationReporter = options.NotificationReporter, ...
                ResultReporter = options.ResultReporter);

        end

        function cancelBatch(obj)

            obj.BatchRunController.cancel(obj.Session.Batch);

        end

        function outcome = generateReport( ...
                obj, resultDirectory, options)

            arguments
                obj
                resultDirectory (1, 1) string
                options.IsDeployed (1, 1) logical = isdeployed
            end

            outcome = obj.resultCommand(@generateReport);

            function value = generateReport()

                location = openmebius.domain.result.ResultLocation ...
                    .fromDirectory(resultDirectory);
                value = obj.ResultController.generateReport( ...
                    location, ...
                    obj.Session.Model, ...
                    obj.Session.Experiments, ...
                    obj.Session.Result, ...
                    IsDeployed = options.IsDeployed);

            end

        end

        function outcome = exportResults( ...
                obj, batchIDs, batchNames, outputDirectory)

            outcome = obj.resultCommand(@exportResults);

            function value = exportResults()

                location = openmebius.domain.result.ResultLocation ...
                    .fromDirectory(outputDirectory);
                value = obj.ResultController.exportResults( ...
                    obj.Session.Result, batchIDs, batchNames, location);

            end

        end

        function outcome = prepareRangePlot(obj, batchIDs, batchNames)

            outcome = obj.ResultController.prepareRangePlot( ...
                obj.Session.Result, batchIDs, batchNames);

        end

        function outcome = loadSuggestion(obj, batchIDs, batchNames)

            outcome = obj.ResultController.loadSuggestion( ...
                obj.Session.Result, batchIDs, batchNames);

        end

        function outcome = loadResultInformation( ...
                obj, batchIDs, batchNames)

            outcome = obj.resultCommand(@loadInformation);

            function value = loadInformation()

                modelDegreesOfFreedom = obj.Session.Model.getDOF();
                value = obj.ResultController.loadInformation( ...
                    obj.Session.Result, ...
                    batchIDs, ...
                    batchNames, ...
                    modelDegreesOfFreedom);

            end

        end % loadResultInformation

    end % methods

    methods (Access = private)

        function outcome = batchRunPreparationFailure(~, operationOutcome)

            outcome = openmebius.application.batch.BatchRunOutcome( ...
                false, ...
                seconds(0), ...
                ErrorMessage = operationOutcome.ErrorMessage, ...
                Exception = operationOutcome.Exception);

        end % batchRunPreparationFailure

        function outcome = commitProjectOutcome(obj, outcome)

            if ~outcome.isSuccess() || isempty(outcome.Result)
                return
            end

            try
                result = outcome.Result;

                if isempty(result.Artifacts)
                    obj.Session.setProject(result.Session);
                else
                    obj.Session.replaceProject( ...
                        result.Session, ...
                        result.Artifacts.Model, ...
                        result.Artifacts.Experiments, ...
                        result.Artifacts.Batch, ...
                        result.Artifacts.Result);
                end

            catch exception
                outcome = openmebius.application.project ...
                    .ProjectOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end

        function outcome = commitModelOutcome(obj, outcome)

            if ~outcome.isSuccess() || isempty(outcome.Result)
                return
            end

            obj.Session.replaceModel(outcome.Result.Model);

        end

        function outcome = commitExperimentImportOutcome(obj, outcome)

            if ~outcome.isSuccess() || isempty(outcome.Result)
                return
            end

            obj.Session.replaceExperimentState( ...
                outcome.Result.Experiments, outcome.Result.Batch);

        end

        function outcome = projectCommand(~, command)

            try
                outcome = command();
            catch exception
                outcome = openmebius.application.project ...
                    .ProjectOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end

        function outcome = modelCommand(~, command)

            try
                outcome = command();
            catch exception
                outcome = openmebius.application.model ...
                    .ModelOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end

        function outcome = experimentImportCommand(~, command)

            try
                outcome = command();
            catch exception
                outcome = openmebius.application.experiment ...
                    .ExperimentImportOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end

        function outcome = resultCommand(~, command)

            try
                outcome = command();
            catch exception
                outcome = openmebius.application.result ...
                    .ResultOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end

        function tf = isValidHandle(~, value)

            tf = ~isempty(value);

            if ~tf || ~isobject(value)
                return
            end

            try
                tf = isvalid(value);
            catch
                tf = false;
            end

        end

    end % methods (Access = private)

end % classdef
