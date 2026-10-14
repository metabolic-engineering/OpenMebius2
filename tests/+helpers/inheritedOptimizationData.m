function data = inheritedOptimizationData()
% Two completed iterations, sorted with the second iteration first.
data.MDVExp = [0.2; 0.8];
data.MDVFragList = ["F"; "F"];
data.MDVFragMask = int8([1; 1]);
data.RSS = [1, 2];
data.RSSIndex = [2, 1];
data.threshold = 3.84;
data.model.modelID = ["v1"; "v2"];
data.model.modelReaction = ["A -> B"; "B -> C"];
data.model.modelTransition = ["a -> a"; "a -> a"];
data.model.modelIndependent = int8([0; 1]);
data.fluxVariability = struct('fluxLB', [0; 0], 'fluxUB', [10; 1], ...
    'fluxLBFwd', [0; 0], 'fluxUBFwd', [10; 1], 'time', int32(123));
data.initialFlux = struct('flux', [5, 5; 0.4, 0.6], ...
    'fluxFwd', [5, 5; 0.4, 0.6], 'rhs', [5, 5; 0.4, 0.6], ...
    'RSS', [2, 3], 'time', int32(124));
data.fluxResult.iteration0001 = struct('flux', [5; 0.4], ...
    'fluxFwd', [5; 0.4], 'RSS', 2, 'MDV', [0.3; 0.7], ...
    'exitflag', 1, 'finiteDifferenceStepSize', 1e-6, 'time', int32(125));
data.fluxResult.iteration0002 = struct('flux', [5; 0.6], ...
    'fluxFwd', [5; 0.6], 'RSS', 1, 'MDV', [0.2; 0.8], ...
    'exitflag', 1, 'finiteDifferenceStepSize', 1e-7, 'time', int32(126));
end
