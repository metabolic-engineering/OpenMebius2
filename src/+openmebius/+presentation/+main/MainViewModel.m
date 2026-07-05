classdef MainViewModel

    properties (SetAccess = private)
        UiState struct
    end

    methods

        function obj = MainViewModel(uiState)

            arguments
                uiState struct
            end

            obj.UiState = uiState;
        end

    end

end
