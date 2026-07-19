classdef BatchConfig
    % BATCHCONFIG
    % Defines and normalizes the canonical batch configuration struct.

    methods (Static)

        function config = defaultConfig()

            % Flux calculation configuration
            config = struct;
            config.iteration = 30;
            config.perturbateEfflux = false;
            config.algorithm = 'sqp';
            config.largeScale = false;
            config.fluxLB = -1000;
            config.fluxUB = 1000;
            config.numExperiments = 1;
            config.suggestNextFlux = false;
            config.isParallel = false;

            % Status
            % ready: ready to run
            % finished: finished
            % error: error
            % warning: warning
            config.status = 'ready';
            config.deleteResultFile = true;

            config.optimizationMethod = 'gradient-only';

            config.fmincon.maxFunctionEvaluations = 1000000;
            config.fmincon.maxIterations = 2000;
            config.fmincon.functionTolerance = 1e-6;
            config.fmincon.stepTolerance = 1e-10;
            config.fmincon.optimalityTolerance = 1e-8;
            config.fmincon.constraintTolerance = 1e-8;
            config.fmincon.finiteDifferenceType = 'central';
            config.fmincon.finiteDifferenceStepSize = 1e-6;
            config.fmincon.finiteDifferenceStepSizeSearch.enabled = true;
            config.fmincon.finiteDifferenceStepSizeSearch.candidates = ...
                [1e-5, 1e-6, 1e-7, 1e-8, 1e-9];
            config.fmincon.finiteDifferenceStepSizeSearch.includeConfiguredStep = true;
            config.fmincon.finiteDifferenceStepSizeSearch.maxCandidates = 6;
            config.fmincon.scaleProblem = 'obj-and-constr';
            config.fmincon.rejectWorseThanInitial = true;
            config.fmincon.objectiveIncreaseTolerance = 1e-6;
            config.fmincon.initialFeasibilityTolerance = 1e-7;

            config.GA.populationSize = 50;
            config.GA.generations = 40;
            config.GA.eliteCount = 2;
            config.GA.tournamentSize = 3;
            config.GA.crossoverFraction = 0.8;
            config.GA.mutationRate = 0.2;
            config.GA.mutationScale = 0.10;
            config.GA.penaltyScale = 1e6;
            config.GA.feasibilityTolerance = 1e-8;
            config.GA.functionTolerance = 1e-9;
            config.GA.stallGenerations = 10;
            config.GA.seed = 0;
            config.GA.maxInitialSeeds = 50;

            % MS fragment selection configuration
            config.isSelectMSFragment = false;
            % all: all fragments
            % custom: custom fragments
            config.MS.fragment = 'all';
            config.MS.fragmentList = string([]);
            config.MS.expList = string([]);
            config.MS.customFragment = [];

            config.efflux = struct;
            config.efflux.selection = logical([]);
            config.efflux.substrate = string([]);
            config.efflux.substrateSD = [];

            % Confidence interval configuration
            config.isCalcCI = false;
            config.CIConf.algorithm = 'Monte Carlo';
            config.CIConf.grid.delta = 1;
            config.CIConf.grid.threshold = 'chi-sq';
            config.CIConf.grid.points = 10;
            config.CIConf.grid.iteration = config.iteration;
            config.CIConf.grid.alpha = 0.05;
            config.CIConf.grid.isParallel = true;
            config.CIConf.MC.iteration = 500;
            config.CIConf.MC.fixMID = true;
            config.CIConf.MC.MIDSD = 0.01;
            config.CIConf.MC.optimizationProcedure = 'multiple';
            config.CIConf.MC.terminationTolerance = 1e-4;
            config.CIConf.MC.proximityThreshold = 1e-4;
            config.CIConf.MC.certainThreshold = 3;
            config.CIConf.MC.theNumberOfRuns = 50;
            config.CIConf.MC.calculationMethod = 'discarding';

            config.suggestionTable = string([]);
            config.suggestionTableRowNames = string([]);
            config.suggestionTableVarNames = string([]);

            config.isINSTMFA = false;
            config.INSTMFA = struct;
            config.INSTMFA.poolMetabolite = string([]);
            config.INSTMFA.poolSize = [];
            config.INSTMFA.timePointsExpName = string([]);
            config.INSTMFA.timePoints = [];

        end % defaultConfig

        function config = normalize(config, baseConfig)

            if nargin < 1 || isempty(config)
                config = struct;
            end

            if nargin < 2 || isempty(baseConfig)
                baseConfig = openmebius.domain.batch.BatchConfig.defaultConfig();
            end

            config = openmebius.domain.batch.BatchConfig.fillMissingFields( ...
                config, ...
                baseConfig);

            % Legacy batch IDs used this non-semantic field as random salt.
            if isfield(config, 'random')
                config = rmfield(config, 'random');
            end

            openmebius.domain.batch.BatchConfig.validate(config);

        end % normalize

        function validate(config)

            import openmebius.domain.batch.BatchConfig

            if ~isstruct(config) || ~isscalar(config)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidStruct", ...
                    "Batch config must be a scalar struct.");
            end

            BatchConfig.mustBePositiveInteger(config, 'iteration');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'algorithm', ...
                ["sqp", "sqp-legacy", "ipms", "interior-point", "interior point"]);
            BatchConfig.mustBeFiniteNumber(config, 'fluxLB');
            BatchConfig.mustBeFiniteNumber(config, 'fluxUB');

            if double(config.fluxLB) > double(config.fluxUB)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidFluxBounds", ...
                    "Batch config fluxLB must be less than or equal to fluxUB.");
            end

            BatchConfig.mustBePositiveInteger(config, 'numExperiments');
            BatchConfig.mustBeLogical(config, 'perturbateEfflux');
            BatchConfig.mustBeLogical(config, 'largeScale');
            BatchConfig.mustBeLogical(config, 'suggestNextFlux');
            BatchConfig.mustBeLogical(config, 'isParallel');
            BatchConfig.mustBeLogical(config, 'deleteResultFile');
            BatchConfig.mustBeLogical(config, 'isSelectMSFragment');
            BatchConfig.mustBeLogical(config, 'isCalcCI');
            BatchConfig.mustBeLogical(config, 'isINSTMFA');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'status', ...
                ["ready", "finished", "error", "warning", "canceled"]);
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'optimizationMethod', ...
                ["gradient-only", "fmincon", "local", ...
                 "hybrid-ga-gradient", "hybrid", "ga-gradient"]);

            BatchConfig.validateFmincon(config);
            BatchConfig.validateGA(config);
            BatchConfig.validateMS(config);
            BatchConfig.validateCI(config);
            BatchConfig.validateEfflux(config);
            BatchConfig.validateINSTMFA(config);

        end % validate

        function config = fillMissingFields(config, defaultConfig)

            fields = fieldnames(defaultConfig);

            for i = 1:numel(fields)
                fname = fields{i};

                if ~isfield(config, fname)
                    config.(fname) = defaultConfig.(fname);
                    continue
                end

                if isstruct(config.(fname)) && isstruct(defaultConfig.(fname))
                    config.(fname) = ...
                        openmebius.domain.batch.BatchConfig.fillMissingFields( ...
                        config.(fname), ...
                        defaultConfig.(fname));
                end

            end

        end % fillMissingFields

    end % methods

    methods (Static, Access = private)

        function validateFmincon(config)

            import openmebius.domain.batch.BatchConfig

            BatchConfig.mustBeStruct(config, 'fmincon');
            BatchConfig.mustBePositiveInteger(config, 'fmincon.maxFunctionEvaluations');
            BatchConfig.mustBePositiveInteger(config, 'fmincon.maxIterations');
            BatchConfig.mustBeNonnegativeNumber(config, 'fmincon.functionTolerance');
            BatchConfig.mustBeNonnegativeNumber(config, 'fmincon.stepTolerance');
            BatchConfig.mustBeNonnegativeNumber(config, 'fmincon.optimalityTolerance');
            BatchConfig.mustBeNonnegativeNumber(config, 'fmincon.constraintTolerance');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'fmincon.finiteDifferenceType', ...
                ["forward", "central"]);
            BatchConfig.mustBePositiveNumber(config, 'fmincon.finiteDifferenceStepSize');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'fmincon.scaleProblem', ...
                ["none", "obj-and-constr"]);
            BatchConfig.mustBeLogical(config, 'fmincon.rejectWorseThanInitial');
            BatchConfig.mustBeNonnegativeNumber( ...
                config, ...
                'fmincon.objectiveIncreaseTolerance');
            BatchConfig.mustBeNonnegativeNumber( ...
                config, ...
                'fmincon.initialFeasibilityTolerance');

            BatchConfig.mustBeStruct( ...
                config, ...
                'fmincon.finiteDifferenceStepSizeSearch');
            BatchConfig.mustBeLogical( ...
                config, ...
                'fmincon.finiteDifferenceStepSizeSearch.enabled');
            BatchConfig.mustBePositiveNumericVector( ...
                config, ...
                'fmincon.finiteDifferenceStepSizeSearch.candidates');
            BatchConfig.mustBeLogical( ...
                config, ...
                'fmincon.finiteDifferenceStepSizeSearch.includeConfiguredStep');
            BatchConfig.mustBePositiveInteger( ...
                config, ...
                'fmincon.finiteDifferenceStepSizeSearch.maxCandidates');

        end % validateFmincon

        function validateGA(config)

            import openmebius.domain.batch.BatchConfig

            BatchConfig.mustBeStruct(config, 'GA');
            BatchConfig.mustBePositiveInteger(config, 'GA.populationSize');
            BatchConfig.mustBePositiveInteger(config, 'GA.generations');
            BatchConfig.mustBePositiveInteger(config, 'GA.eliteCount');
            BatchConfig.mustBePositiveInteger(config, 'GA.tournamentSize');
            BatchConfig.mustBeProbability(config, 'GA.crossoverFraction');
            BatchConfig.mustBeProbability(config, 'GA.mutationRate');
            BatchConfig.mustBeNonnegativeNumber(config, 'GA.mutationScale');
            BatchConfig.mustBeNonnegativeNumber(config, 'GA.penaltyScale');
            BatchConfig.mustBeNonnegativeNumber(config, 'GA.feasibilityTolerance');
            BatchConfig.mustBeNonnegativeNumber(config, 'GA.functionTolerance');
            BatchConfig.mustBePositiveInteger(config, 'GA.stallGenerations');
            BatchConfig.mustBeNonnegativeInteger(config, 'GA.seed');
            BatchConfig.mustBePositiveInteger(config, 'GA.maxInitialSeeds');

        end % validateGA

        function validateMS(config)

            import openmebius.domain.batch.BatchConfig

            BatchConfig.mustBeStruct(config, 'MS');
            BatchConfig.mustBeKnownMember(config, 'MS.fragment', ["all", "custom"]);

        end % validateMS

        function validateCI(config)

            import openmebius.domain.batch.BatchConfig

            BatchConfig.mustBeStruct(config, 'CIConf');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'CIConf.algorithm', ...
                ["monte carlo", "grid search"]);

            BatchConfig.mustBeStruct(config, 'CIConf.grid');
            BatchConfig.mustBePositiveNumber(config, 'CIConf.grid.delta');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'CIConf.grid.threshold', ...
                ["chi-sq", "chi-squared", "f-distribution", "f distribution"]);
            BatchConfig.mustBePositiveInteger(config, 'CIConf.grid.points');
            BatchConfig.mustBePositiveInteger(config, 'CIConf.grid.iteration');
            BatchConfig.mustBeProbability(config, 'CIConf.grid.alpha');
            BatchConfig.mustBeLogical(config, 'CIConf.grid.isParallel');

            BatchConfig.mustBeStruct(config, 'CIConf.MC');
            BatchConfig.mustBePositiveInteger(config, 'CIConf.MC.iteration');
            BatchConfig.mustBeLogical(config, 'CIConf.MC.fixMID');
            BatchConfig.mustBeNonnegativeNumber(config, 'CIConf.MC.MIDSD');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'CIConf.MC.optimizationProcedure', ...
                ["single", "multiple"]);
            BatchConfig.mustBeNonnegativeNumber( ...
                config, ...
                'CIConf.MC.terminationTolerance');
            BatchConfig.mustBeNonnegativeNumber( ...
                config, ...
                'CIConf.MC.proximityThreshold');
            BatchConfig.mustBePositiveInteger(config, 'CIConf.MC.certainThreshold');
            BatchConfig.mustBePositiveInteger(config, 'CIConf.MC.theNumberOfRuns');
            BatchConfig.mustBeKnownMember( ...
                config, ...
                'CIConf.MC.calculationMethod', ...
                ["discarding", "mean-varianced"]);

        end % validateCI

        function validateEfflux(config)

            import openmebius.domain.batch.BatchConfig

            BatchConfig.mustBeStruct(config, 'efflux');

            effluxConfig = config.efflux;

            if ~isempty(effluxConfig.selection) && ...
                    ~(islogical(effluxConfig.selection) || ...
                    isnumeric(effluxConfig.selection))
                error( ...
                    "OpenMebius2:BatchConfig:InvalidLogical", ...
                    "Batch config field efflux.selection must be logical or numeric.");
            end

            if ~isempty(effluxConfig.substrateSD) && ...
                    ~(isnumeric(effluxConfig.substrateSD) && ...
                    all(~isinf(double(effluxConfig.substrateSD(:)))))
                error( ...
                    "OpenMebius2:BatchConfig:InvalidFiniteNumber", ...
                    "Batch config field efflux.substrateSD must contain " + ...
                    "finite numbers or NaN for unset values.");
            end

        end % validateEfflux

        function validateINSTMFA(config)

            import openmebius.domain.batch.BatchConfig

            BatchConfig.mustBeStruct(config, 'INSTMFA');

            instMFAConfig = config.INSTMFA;

            if ~isempty(instMFAConfig.poolSize) && ...
                    ~(isnumeric(instMFAConfig.poolSize) && ...
                    all(isfinite(double(instMFAConfig.poolSize(:)))) && ...
                    all(double(instMFAConfig.poolSize(:)) >= 0))
                error( ...
                    "OpenMebius2:BatchConfig:InvalidNonnegativeNumber", ...
                    "Batch config field INSTMFA.poolSize must contain nonnegative numbers.");
            end

            if ~isempty(instMFAConfig.timePoints) && ...
                    ~(isnumeric(instMFAConfig.timePoints) && ...
                    all(isfinite(double(instMFAConfig.timePoints(:)))) && ...
                    all(double(instMFAConfig.timePoints(:)) >= 0))
                error( ...
                    "OpenMebius2:BatchConfig:InvalidNonnegativeNumber", ...
                    "Batch config field INSTMFA.timePoints must contain nonnegative numbers.");
            end

        end % validateINSTMFA

        function mustBeStruct(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~isstruct(value) || ~isscalar(value)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidStruct", ...
                    "Batch config field %s must be a scalar struct.", ...
                    fieldPath);
            end

        end % mustBeStruct

        function mustBeLogical(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ischar(value) || isstring(value)
                valueString = lower(string(value));

                if ~isscalar(valueString) || ...
                        ~ismember(valueString, ...
                        ["true", "false", "1", "0", "yes", "no", "on", "off"])
                    error( ...
                        "OpenMebius2:BatchConfig:InvalidLogical", ...
                        "Batch config field %s must be a scalar logical value.", ...
                        fieldPath);
                end

                return
            end

            if ~(isscalar(value) && (islogical(value) || isnumeric(value)))
                error( ...
                    "OpenMebius2:BatchConfig:InvalidLogical", ...
                    "Batch config field %s must be a scalar logical value.", ...
                    fieldPath);
            end

            if ~isfinite(double(value))
                error( ...
                    "OpenMebius2:BatchConfig:InvalidLogical", ...
                    "Batch config field %s must be a scalar logical value.", ...
                    fieldPath);
            end

            if ~ismember(double(value), [0, 1])
                error( ...
                    "OpenMebius2:BatchConfig:InvalidLogical", ...
                    "Batch config field %s must be a scalar logical value.", ...
                    fieldPath);
            end

        end % mustBeLogical

        function mustBePositiveInteger(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~openmebius.domain.batch.BatchConfig.isScalarInteger(value) || ...
                    double(value) <= 0
                error( ...
                    "OpenMebius2:BatchConfig:InvalidPositiveInteger", ...
                    "Batch config field %s must be a positive integer.", ...
                    fieldPath);
            end

        end % mustBePositiveInteger

        function mustBeNonnegativeInteger(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~openmebius.domain.batch.BatchConfig.isScalarInteger(value) || ...
                    double(value) < 0
                error( ...
                    "OpenMebius2:BatchConfig:InvalidNonnegativeInteger", ...
                    "Batch config field %s must be a nonnegative integer.", ...
                    fieldPath);
            end

        end % mustBeNonnegativeInteger

        function mustBeFiniteNumber(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~openmebius.domain.batch.BatchConfig.isScalarFiniteNumber(value)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidFiniteNumber", ...
                    "Batch config field %s must be a finite number.", ...
                    fieldPath);
            end

        end % mustBeFiniteNumber

        function mustBePositiveNumber(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~openmebius.domain.batch.BatchConfig.isScalarFiniteNumber(value) || ...
                    double(value) <= 0
                error( ...
                    "OpenMebius2:BatchConfig:InvalidPositiveNumber", ...
                    "Batch config field %s must be a positive finite number.", ...
                    fieldPath);
            end

        end % mustBePositiveNumber

        function mustBeNonnegativeNumber(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~openmebius.domain.batch.BatchConfig.isScalarFiniteNumber(value) || ...
                    double(value) < 0
                error( ...
                    "OpenMebius2:BatchConfig:InvalidNonnegativeNumber", ...
                    "Batch config field %s must be a nonnegative finite number.", ...
                    fieldPath);
            end

        end % mustBeNonnegativeNumber

        function mustBeProbability(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~openmebius.domain.batch.BatchConfig.isScalarFiniteNumber(value) || ...
                    double(value) < 0 || ...
                    double(value) > 1
                error( ...
                    "OpenMebius2:BatchConfig:InvalidProbability", ...
                    "Batch config field %s must be a number between 0 and 1.", ...
                    fieldPath);
            end

        end % mustBeProbability

        function mustBePositiveNumericVector(config, fieldPath)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~(isnumeric(value) || islogical(value)) || ...
                    isempty(value) || ...
                    any(~isfinite(double(value(:)))) || ...
                    any(double(value(:)) <= 0)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidPositiveNumber", ...
                    "Batch config field %s must contain positive finite numbers.", ...
                    fieldPath);
            end

        end % mustBePositiveNumericVector

        function mustBeKnownMember(config, fieldPath, allowedValues)

            value = openmebius.domain.batch.BatchConfig.getFieldValue( ...
                config, ...
                fieldPath);

            if ~(ischar(value) || isstring(value)) || isempty(value)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidString", ...
                    "Batch config field %s must be a string.", ...
                    fieldPath);
            end

            valueString = lower(string(value));

            if ~isscalar(valueString) || ~ismember(valueString, allowedValues)
                error( ...
                    "OpenMebius2:BatchConfig:InvalidMember", ...
                    "Batch config field %s has an unsupported value: %s.", ...
                    fieldPath, ...
                    string(value));
            end

        end % mustBeKnownMember

        function value = getFieldValue(config, fieldPath)

            parts = split(string(fieldPath), ".");
            value = config;

            for i = 1:numel(parts)
                fieldName = char(parts(i));

                if ~isstruct(value) || ~isfield(value, fieldName)
                    error( ...
                        "OpenMebius2:BatchConfig:MissingField", ...
                        "Batch config field %s is missing.", ...
                        fieldPath);
                end

                value = value.(fieldName);
            end

        end % getFieldValue

        function tf = isScalarInteger(value)

            tf = openmebius.domain.batch.BatchConfig.isScalarFiniteNumber(value) && ...
                fix(double(value)) == double(value);

        end % isScalarInteger

        function tf = isScalarFiniteNumber(value)

            tf = (isnumeric(value) || islogical(value)) && ...
                isscalar(value) && ...
                isfinite(double(value));

        end % isScalarFiniteNumber

    end % methods

end % classdef
