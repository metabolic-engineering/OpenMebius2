---
title: Architecture
author: Tatsumi Imada
date: 2026-07-19
category: Jekyll
layout: post
---

# Dependency direction

OpenMebius2 uses an inward dependency direction:

```text
App Designer views
        |
        v
Presentation (Presenter, Action, Context, ViewModel)
        |
        v
Application (Controller, UseCase, Session, Workflow)
        |
        +--------------------+
        v                    v
Domain values             MFA / EMU
        ^                    ^
        |                    |
Infrastructure repositories and adapters
```

The Composition Root in `openmebius.bootstrap.MainAppCompositionRoot` creates
the concrete repositories, services, controllers, and presenters used by the
main App. Infrastructure is selected at this outer boundary and supplied to
application services.

# Enforced rules

- `+application`, `+domain`, and `+mfa` must not reference
  `openmebius.presentation`, `matlab.ui.*`, `uitable`, `uiaxes`, or dialogs.
- Domain and MFA code must not read or write project directories directly.
- Repositories own JSON, Excel, HDF5, hashing, atomic replacement, and migration.
- App callbacks collect input, invoke an application controller, and render a
  view model. They do not mutate model, experiment, batch, or result internals.
- Child Apps receive a typed Context, emit an Action or event result, and are
  attached and closed by `ChildAppHost`.
- Application notifications use `openmebius.core.notification.Message` and a
  function-handle port. Presentation may map that value to App Designer events.
- Expected command failures return an `OperationOutcome` subtype. Corrupt files
  and programming errors use identified `MException` values.

`LayerDependencyBoundaryTest`, `MainAppDomainBoundaryTest`, and the child-App
boundary tests enforce these rules in the fast test profile.

# Runtime ownership

`MainApplicationSession` is the runtime owner of the current `ProjectSession`
and its model, experiment, batch, and result artifacts. The main App keeps
presentation state and delegates artifact access through
`MainApplicationController`.

| Concern | Current boundary |
|---|---|
| Project metadata and paths | `ProjectSession`, `ProjectPaths` |
| Loaded model document | `ModelDocument`, `ModelAggregate`, `MetabolicModel` |
| Experiment collection | `ExperimentSet`, `ExperimentCollection` |
| Batch definitions and execution | `BatchCollection`, `BatchSession`, `BatchRunService` |
| Result queries and tables | `ResultCatalog`, `ResultQueryService`, `ResultTableBuilder` |
| One MFA execution | `MFAAnalysisRun`, `MFAAnalysisController`, `MFAResultSession` |
| Stoichiometric state | `StoichiometricNetwork`, `StoichiometricReactionIndex`, `StoichiometricConstraintModel` |
| EMU construction and evaluation | `EMUNetworkBuilder`, `EMUMatrixBuilder`, `EMUMDVCalculator` |

# Repository boundary

`ModelLocation`, `ExperimentLocation`, and `ResultLocation` are immutable path
values. Repositories accept a Location and return validated application or
domain values. A failed project open constructs no new main session, so the
previous session remains usable.

Writes that replace JSON metadata use a temporary file followed by an atomic
replacement. Analysis checkpoints are coordinated by `AnalysisRunRepository`;
each HDF5 result has a corresponding manifest when produced by the current
version.
