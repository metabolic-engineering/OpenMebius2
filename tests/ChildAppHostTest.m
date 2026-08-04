classdef ChildAppHostTest < matlab.unittest.TestCase

    methods (Test)

        function attachForwardsEventsAndDetachKeepsChild(testCase)

            host = openmebius.presentation.lifecycle.ChildAppHost();
            child = fixtures.ChildAppProbe();
            appliedCount = 0;
            host.attach( ...
                "editor", ...
                child, ...
                {"Applied", @onApplied});

            child.apply();
            detachedChild = host.detach("editor");
            child.apply();

            testCase.verifyEqual(appliedCount, 1);
            testCase.verifySameHandle(detachedChild, child);
            testCase.verifyFalse(host.isAttached("editor"));
            testCase.verifyTrue(isvalid(child));

            function onApplied(~, ~)
                appliedCount = appliedCount + 1;
            end

        end

        function replacingEntryClosesPreviousChild(testCase)

            host = openmebius.presentation.lifecycle.ChildAppHost();
            first = fixtures.ChildAppProbe();
            second = fixtures.ChildAppProbe();

            host.attach("editor", first);
            host.attach("editor", second);

            testCase.verifyFalse(isvalid(first));
            testCase.verifyTrue(isvalid(second));
            testCase.verifySameHandle(host.child("editor"), second);

        end

        function closeAndCloseAllDeleteOwnedChildren(testCase)

            host = openmebius.presentation.lifecycle.ChildAppHost();
            first = fixtures.ChildAppProbe();
            second = fixtures.ChildAppProbe();
            host.attach("first", first);
            host.attach("second", second);

            host.close("first");
            host.closeAll();

            testCase.verifyFalse(isvalid(first));
            testCase.verifyFalse(isvalid(second));
            testCase.verifyFalse(host.isAttached("first"));
            testCase.verifyFalse(host.isAttached("second"));

        end

        function invalidSubscriptionsAreRejected(testCase)

            host = openmebius.presentation.lifecycle.ChildAppHost();
            child = fixtures.ChildAppProbe();

            testCase.verifyError( ...
                @() host.attach("editor", child, {"Applied"}), ...
                "OpenMebius2:ChildAppHost:InvalidSubscriptions");

        end

    end

end
