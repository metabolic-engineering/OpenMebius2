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

After editing and saving an App in App Designer, refresh the review artifact:

```matlab
addpath("tools");
synchronizeExportedSource("OpenMebius2");
```

Synchronization is intentionally one-way from `.mlapp` to `*_exported.m`.
Do not copy exported source back into `.mlapp`: exported source includes
generated regions whose formatting is not the App Designer component model.
Reverse replacement can make an App open as modified and can lose edits in
read-only generated methods.

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
