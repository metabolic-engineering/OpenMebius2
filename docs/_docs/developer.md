---
title: For developers
author: Tatsumi Imada
date: 2026-07-19
category: Jekyll
layout: post
---

This page describes the supported development workflow for OpenMebius2. The
source code is available on
[GitHub](https://github.com/metabolic-engineering/OpenMebius2).

# Development environment

- MATLAB R2025a or later. CI currently runs with R2026a.
- Optimization Toolbox.
- Statistics and Machine Learning Toolbox.
- Parallel Computing Toolbox for parallel analysis.
- MATLAB Compiler only when creating a standalone application or installer.

Clone the repository and run MATLAB with the repository as the current folder.
Source and tests are added explicitly by each command; permanent path changes
are not required.

# Repository structure

| Path | Responsibility |
|---|---|
| `src/*.mlapp` | App Designer source of record |
| `src/*_exported.m` | Reviewable App Designer code export |
| `src/+openmebius/+presentation` | Presenter, view model, child-App context, and UI policy |
| `src/+openmebius/+application` | Use cases, controllers, sessions, and workflow coordination |
| `src/+openmebius/+domain` | Validated domain values and aggregates |
| `src/+openmebius/+mfa` | UI-independent MFA and EMU numerical logic |
| `src/+openmebius/+infrastructure` | Repository, filesystem, HDF5, JSON, logging, and notification adapters |
| `src/+openmebius/+bootstrap` | Main application Composition Root |
| `tests` | Unit, boundary, characterization, migration, and UI smoke tests |
| `tools` | Development-only source synchronization utilities |

# Development rules

1. Preserve the dependency direction documented in
   [Architecture](architecture.md).
2. Pass filesystem locations through `ModelLocation`, `ExperimentLocation`,
   `ResultLocation`, or `ProjectPaths`; do not make domain objects discover
   directories themselves.
3. Keep migration in repositories and migration services. Runtime classes must
   consume the current in-memory representation.
4. Report messages through a callback accepting
   `openmebius.core.notification.Message`. Application and numerical code must
   not publish App Designer events.
5. Change `.mlapp` files in App Designer and update the corresponding exported
   source in the same change. The synchronization utility is a repair tool and
   overwrites the code store inside the `.mlapp` file.
6. Add a boundary test when introducing a new architectural constraint.

# Verification

Run the pull-request profile first:

```matlab
addpath("tests");
runFastTests();
```

Run the profile covering the changed behavior:

```matlab
runTestProfile("domain");
runTestProfile("numerical");
runTestProfile("integration");
```

See [Build and release](build.md) for source synchronization, packaging, and
release commands. Persisted formats and compatibility behavior are described in
[Data format](format.md) and [Migration](migration.md).
