---
title: Build and release
author: Tatsumi Imada
date: 2026-07-19
category: Jekyll
layout: post
---

# App Designer source synchronization

The `.mlapp` file is the source of record. The matching `*_exported.m` file is a
review artifact and must contain equivalent code.

Verify every App before committing:

```matlab
addpath("src");
addpath("tests");
results = runtests("tests/OpenMebius2SourceSyncTest.m");
assertSuccess(results);
```

When an exported file intentionally contains the newer code and the `.mlapp`
code store must be repaired, run:

```matlab
addpath("tools");
synchronizeMlappSource("OpenMebius2");
```

This command replaces the App's internal code store. Reopen the App in App
Designer and inspect the diff afterward. It does not recreate UI layout.

# Test profiles

```matlab
addpath("tests");
runTestProfile("fast");
runTestProfile("domain");
runTestProfile("numerical");
runTestProfile("integration");
```

`fast` is required for each pull request. `domain` covers application and
repository behavior. `numerical` includes characterization data. `integration`
opens App Designer workflows and is run manually. `runAllTests()` executes all
profiles with coverage when used by the release workflow.

# Build validation

`BuildMyApp` resolves all paths relative to its own source file, so it can be
called from any current directory. A compiler-free validation returns the exact
build plan:

```matlab
addpath("src");
planResult = BuildMyApp( ...
    ValidateOnly = true, ...
    RunFastTests = false, ...
    VerifySourceSync = true);
disp(planResult.Plan);
```

# Standalone application and installer

MATLAB Compiler is required. By default the build runs the fast profile, checks
App source synchronization, compiles the standalone application, and creates an
installer.

```matlab
addpath("src");
result = BuildMyApp();
```

Default outputs are:

```text
build/openmebius2/     standalone build
installer/             platform installer
```

Use `OutputDirectory`, `InstallerDirectory`, or `CreateInstaller=false` for a
local build variant. Do not disable `RunFastTests` or `VerifySourceSync` for a
release build.

# Release handoff

N3 release verification must run all test profiles, confirm `.mlapp` source
synchronization, create the platform package, and inspect reproducibility
metadata in a newly generated result manifest. The application version returned
by `System.getCurrentVersion()` must match the release tag before packaging.
