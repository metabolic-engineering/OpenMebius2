classdef ModelAggregate
    % MODELAGGREGATE Immutable application-facing model snapshot.

    properties (SetAccess = private)
        ModelTable table
        MassSpectrometryTable table
        AtomTable table
        BiomassTable table
        LabelTable table
        LabelConfiguration struct
        Pathway
        InvalidModelRows (:, 1) double
        InvalidMassSpectrometryRows (:, 1) double
        InvalidAtomRows (:, 1) double
    end

    methods

        function obj = ModelAggregate(options)

            arguments
                options.ModelTable table = table()
                options.MassSpectrometryTable table = table()
                options.AtomTable table = table()
                options.BiomassTable table = table()
                options.LabelTable table = table()
                options.LabelConfiguration struct = struct()
                options.Pathway = []
                options.InvalidModelRows (:, 1) double = zeros(0, 1)
                options.InvalidMassSpectrometryRows (:, 1) double = zeros(0, 1)
                options.InvalidAtomRows (:, 1) double = zeros(0, 1)
            end

            names = string(fieldnames(options));

            for nameIndex = 1:numel(names)
                obj.(names(nameIndex)) = options.(names(nameIndex));
            end

        end

    end

end
