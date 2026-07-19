classdef ChildAppHost < handle
    % CHILDAPPHOST Owns child applications and their event subscriptions.

    properties (Access = private)
        Entries containers.Map
    end

    methods

        function obj = ChildAppHost()

            obj.Entries = containers.Map( ...
                'KeyType', 'char', ...
                'ValueType', 'any');

        end % constructor

        function attach(obj, key, childApp, subscriptions)

            arguments
                obj (1, 1) openmebius.presentation.lifecycle.ChildAppHost
                key (1, 1) string
                childApp
                subscriptions cell = cell(0, 2)
            end

            obj.validateChild(childApp);
            obj.validateSubscriptions(subscriptions);
            obj.close(key);

            listeners = event.listener.empty(0, 1);

            try
                for subscriptionIndex = 1:size(subscriptions, 1)
                    listeners(end + 1, 1) = addlistener( ...
                        childApp, ...
                        char(string(subscriptions{subscriptionIndex, 1})), ...
                        subscriptions{subscriptionIndex, 2}); %#ok<AGROW>
                end
            catch exception
                obj.deleteListeners(listeners);
                rethrow(exception);
            end

            obj.Entries(char(key)) = struct( ...
                ChildApp = childApp, ...
                Listeners = listeners);

        end % attach

        function childApp = detach(obj, key)

            arguments
                obj (1, 1) openmebius.presentation.lifecycle.ChildAppHost
                key (1, 1) string
            end

            mapKey = char(key);
            childApp = [];

            if ~isKey(obj.Entries, mapKey)
                return
            end

            entry = obj.Entries(mapKey);
            remove(obj.Entries, mapKey);
            obj.deleteListeners(entry.Listeners);
            childApp = entry.ChildApp;

        end % detach

        function close(obj, key)

            arguments
                obj (1, 1) openmebius.presentation.lifecycle.ChildAppHost
                key (1, 1) string
            end

            childApp = obj.detach(key);
            obj.deleteChild(childApp);

        end % close

        function closeAll(obj)

            keys = string(obj.Entries.keys());

            for keyIndex = 1:numel(keys)
                obj.close(keys(keyIndex));
            end

        end % closeAll

        function tf = isAttached(obj, key)

            arguments
                obj (1, 1) openmebius.presentation.lifecycle.ChildAppHost
                key (1, 1) string
            end

            tf = isKey(obj.Entries, char(key));

        end % isAttached

        function childApp = child(obj, key)

            arguments
                obj (1, 1) openmebius.presentation.lifecycle.ChildAppHost
                key (1, 1) string
            end

            mapKey = char(key);

            if ~isKey(obj.Entries, mapKey)
                childApp = [];
                return
            end

            entry = obj.Entries(mapKey);
            childApp = entry.ChildApp;

        end % child

        function delete(obj)

            obj.closeAll();

        end % delete

    end % methods

    methods (Access = private)

        function validateChild(~, childApp)

            if isempty(childApp) || ~isa(childApp, 'handle') || ...
                    ~isvalid(childApp)
                error( ...
                    "OpenMebius2:ChildAppHost:InvalidChild", ...
                    "A valid child application handle is required.");
            end

        end % validateChild

        function validateSubscriptions(~, subscriptions)

            if ~iscell(subscriptions) || size(subscriptions, 2) ~= 2
                error( ...
                    "OpenMebius2:ChildAppHost:InvalidSubscriptions", ...
                    "Subscriptions must be an N-by-2 event/callback cell array.");
            end

            for subscriptionIndex = 1:size(subscriptions, 1)
                eventName = subscriptions{subscriptionIndex, 1};
                callback = subscriptions{subscriptionIndex, 2};

                if strlength(string(eventName)) == 0 || ...
                        ~isa(callback, 'function_handle')
                    error( ...
                        "OpenMebius2:ChildAppHost:InvalidSubscription", ...
                        "Each subscription requires an event name and callback.");
                end
            end

        end % validateSubscriptions

        function deleteListeners(~, listeners)

            for listenerIndex = 1:numel(listeners)
                try
                    if isvalid(listeners(listenerIndex))
                        delete(listeners(listenerIndex));
                    end
                catch
                end
            end

        end % deleteListeners

        function deleteChild(~, childApp)

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % deleteChild

    end % methods (Access = private)

end % classdef
