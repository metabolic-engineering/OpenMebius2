classdef EMUNetworkEnumerationResult
    % EMUNETWORKENUMERATIONRESULT Immutable EMU enumeration output.

    properties (SetAccess = private)
        TableEMU table
        TableEMUReaction table
        SearchedProducts cell
        ErrorMessages (:, 1) string
        IsValid (1, 1) logical
    end

    methods

        function obj = EMUNetworkEnumerationResult(options)

            arguments
                options.TableEMU table
                options.TableEMUReaction table
                options.SearchedProducts cell
                options.ErrorMessages string = strings(0, 1)
            end

            obj.TableEMU = options.TableEMU;
            obj.TableEMUReaction = options.TableEMUReaction;
            obj.SearchedProducts = options.SearchedProducts;
            obj.ErrorMessages = string(options.ErrorMessages(:));
            obj.IsValid = isempty(obj.ErrorMessages);

        end % constructor

    end % methods

end % classdef
