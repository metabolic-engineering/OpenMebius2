classdef EffluxFreeModelSession < handle
    % EFFLUXFREEMODELSESSION
    % Applies temporary efflux-free model changes and restores them safely.

    properties (SetAccess = private)
        IsActive (1, 1) logical = false
    end

    properties (Access = private)
        Model
        ReactionIDs (:, 1) string = strings(0, 1)
        OriginalIndependent (:, 1) logical = false(0, 1)
        MessageReporter (1, 1) function_handle = @(~, ~) []
    end

    methods

        function obj = EffluxFreeModelSession( ...
                model, substrates, options)

            arguments
                model
                substrates
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
            end

            substrates = string(substrates(:));
            obj.Model = model;
            obj.MessageReporter = options.MessageReporter;
            obj.ReactionIDs = strings(numel(substrates), 1);
            obj.OriginalIndependent = false(numel(substrates), 1);

            for i = 1:numel(substrates)
                reactionID = string( ...
                    model.findSubstrateRxnIDFromMetaboliteIrrev( ...
                    substrates(i)));
                obj.ReactionIDs(i) = reactionID;
                obj.OriginalIndependent(i) = ...
                    model.getReactionIndependent(reactionID);
            end

            model.makeEffluxFree(substrates.');
            obj.IsActive = true;

        end

        function restore(obj)

            if ~obj.IsActive
                return
            end

            % Restoration is attempted at most once. In particular, the
            % destructor must not retry after the model or reporter has
            % already been destroyed during application shutdown.
            obj.IsActive = false;

            try

                for i = 1:numel(obj.ReactionIDs)
                    obj.Model.setReactionIndependent( ...
                        obj.ReactionIDs(i), ...
                        obj.OriginalIndependent(i));
                end

            catch ME
                obj.reportRestoreFailure(ME);
            end

            obj.Model = [];
            obj.MessageReporter = @(~, ~) [];

        end

        function delete(obj)

            obj.restore();

        end

    end

    methods (Access = private)

        function reportRestoreFailure(obj, exception)

            try
                obj.MessageReporter( ...
                    "warning", ...
                    "Failed to restore efflux free model state: " + ...
                    string(exception.message));
            catch
                % Destructors must not fail when the notification owner has
                % already been deleted during application shutdown.
            end

        end

    end

end
