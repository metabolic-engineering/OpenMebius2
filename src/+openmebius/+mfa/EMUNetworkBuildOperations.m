classdef EMUNetworkBuildOperations
    % EMUNETWORKBUILDOPERATIONS
    % Typed port used while legacy EMUModel build steps are extracted.

    properties (Access = private)
        InitializeCallback
        EnumerateCallback
        ValidateCallback
        ResolveSizeInfoCallback
        AssignSizeInfoCallback
        BuildAnBnCallback
        BuildCnCallback
        BuildXnYnCallback
        BuildMDVCallback
        CreateSnapshotCallback
    end

    methods

        function obj = EMUNetworkBuildOperations(options)

            arguments
                options.Initialize (1, 1) function_handle
                options.Enumerate (1, 1) function_handle
                options.Validate (1, 1) function_handle
                options.ResolveSizeInfo (1, 1) function_handle
                options.AssignSizeInfo (1, 1) function_handle
                options.BuildAnBn (1, 1) function_handle
                options.BuildCn (1, 1) function_handle
                options.BuildXnYn (1, 1) function_handle
                options.BuildMDV (1, 1) function_handle
                options.CreateSnapshot (1, 1) function_handle
            end

            obj.InitializeCallback = options.Initialize;
            obj.EnumerateCallback = options.Enumerate;
            obj.ValidateCallback = options.Validate;
            obj.ResolveSizeInfoCallback = options.ResolveSizeInfo;
            obj.AssignSizeInfoCallback = options.AssignSizeInfo;
            obj.BuildAnBnCallback = options.BuildAnBn;
            obj.BuildCnCallback = options.BuildCn;
            obj.BuildXnYnCallback = options.BuildXnYn;
            obj.BuildMDVCallback = options.BuildMDV;
            obj.CreateSnapshotCallback = options.CreateSnapshot;

        end % constructor

        function initialize(obj)

            obj.InitializeCallback();

        end % initialize

        function enumerate(obj)

            obj.EnumerateCallback();

        end % enumerate

        function validate(obj)

            obj.ValidateCallback();

        end % validate

        function sizeInfo = resolveSizeInfo(obj)

            sizeInfo = obj.ResolveSizeInfoCallback();

        end % resolveSizeInfo

        function assignSizeInfo(obj, sizeInfo)

            obj.AssignSizeInfoCallback(sizeInfo);

        end % assignSizeInfo

        function buildAnBn(obj)

            obj.BuildAnBnCallback();

        end % buildAnBn

        function buildCn(obj)

            obj.BuildCnCallback();

        end % buildCn

        function buildXnYn(obj)

            obj.BuildXnYnCallback();

        end % buildXnYn

        function buildMDV(obj)

            obj.BuildMDVCallback();

        end % buildMDV

        function snapshot = createSnapshot(obj)

            snapshot = obj.CreateSnapshotCallback();

            if ~isa( ...
                    snapshot, ...
                    "openmebius.domain.model.EMUNetworkSnapshot")
                error( ...
                    "OpenMebius2:EMUNetworkBuilder:InvalidSnapshot", ...
                    "The EMU network builder must return an " + ...
                    "EMUNetworkSnapshot.");
            end

        end % createSnapshot

    end % methods

end % classdef
