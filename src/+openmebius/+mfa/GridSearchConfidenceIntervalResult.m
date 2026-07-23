classdef GridSearchConfidenceIntervalResult

    properties (SetAccess = private)
        LowerBounds (:, 1) double
        UpperBounds (:, 1) double
        ProfileData (1, 1) openmebius.mfa.GridSearchProfileData
        ElapsedTime (1, 1) double
        IsCanceled (1, 1) logical
    end % properties (SetAccess = private)

    methods

        function obj = GridSearchConfidenceIntervalResult(options)

            arguments
                options.LowerBounds (:, 1) double
                options.UpperBounds (:, 1) double
                options.ProfileData (1, 1) openmebius.mfa.GridSearchProfileData
                options.ElapsedTime (1, 1) double
                options.IsCanceled (1, 1) logical = false
            end

            if ~isequal(size(options.LowerBounds), ...
                    size(options.UpperBounds))
                error( ...
                    "OpenMebius2:GridSearchCI:BoundSizeMismatch", ...
                    "Lower and upper confidence-interval bounds " + ...
                "must have the same size.");
            end

            if size(options.LowerBounds, 1) ~= ...
                    size(options.ProfileData, 1)
                error( ...
                    "OpenMebius2:GridSearchCI:ProfileSizeMismatch", ...
                    "Confidence-interval bounds and profile data " + ...
                "must have the same row count.");
            end

            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.ProfileData = options.ProfileData;
            obj.ElapsedTime = options.ElapsedTime;
            obj.IsCanceled = options.IsCanceled;

        end % constructor

    end % methods

end % classdef
