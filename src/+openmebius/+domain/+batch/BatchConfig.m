classdef BatchConfig
    % BATCHCONFIG
    % Defines and normalizes the legacy batch configuration struct.

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

        end % normalize

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

end % classdef
