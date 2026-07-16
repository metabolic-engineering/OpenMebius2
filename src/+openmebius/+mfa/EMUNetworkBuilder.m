classdef EMUNetworkBuilder
    % EMUNETWORKBUILDER
    % Defines the construction order for an EMU network snapshot.

    methods

        function snapshot = build(~, operations)

            arguments
                ~
                operations (1, 1) ...
                    openmebius.mfa.EMUNetworkBuildOperations
            end

            operations.initialize();
            operations.enumerate();
            operations.validate();

            sizeInfo = operations.resolveSizeInfo();
            operations.assignSizeInfo(sizeInfo);
            operations.buildAnBn();
            operations.buildCn();
            operations.buildXnYn();
            operations.buildMDV();

            snapshot = operations.createSnapshot();

        end % build

    end % methods

end % classdef
