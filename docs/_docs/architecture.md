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

# Unified notification delivery

Every user-facing message and operational diagnostic is represented by
`openmebius.core.notification.Message`. Producers do not select UI, file,
console, or Slack destinations. Application services create the value through
`NotificationEmitter` and publish it once through an injected function-handle
port.

```mermaid
flowchart LR
    P["Application / presentation producer"] --> E["NotificationEmitter"]
    E --> M["core.notification.Message"]
    M --> D["NotificationDispatcher"]
    D --> R["RoutingPolicy"]
    R --> U["UI log sink"]
    R --> A["UI alert sink"]
    R --> F["Rotating file sink"]
    R --> C["stdout / stderr sink"]
    R --> S["Slack sink"]
```

The message carries a stable event ID, optional correlation ID, event code,
severity, user text, diagnostic text, source, structured context, audience,
attention requirement, and kind. `NotificationDispatcher` suppresses repeated
event IDs and isolates sink failures so a logging or remote-delivery failure
cannot fail the application operation.

| Sink | Default desktop policy |
|---|---|
| File | `debug` and above; explicit append with size-based rotation |
| Console | `warning` and above; normal output uses stdout, failures use stderr |
| UI log | `info` and above, excluding progress and developer-only messages |
| UI alert | Action-required non-failure messages; warnings, errors, and fatal failures remain in the UI log only |
| Slack | Allow-listed terminal batch event codes only |

UI sinks are registered after the App Designer controls exist and removed when
the main App closes. `MainAppCompositionRoot` owns the long-lived dispatcher
and non-UI sinks. Test mode disables console delivery. The file sink replaces
MATLAB `diary`, so log ownership, rotation, and failure handling are explicit.

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

After initial-flux generation and scoring, `MFAInitialFluxApplicationWorkflow`
retains only the first `IterationCount` ranked candidates in its return value
and `MFAAnalysisRunContext`. Surplus fluxes, right-hand sides, and objective
values are released before checkpoint persistence and nonlinear optimization,
so parallel iteration callbacks do not capture unused initial candidates.
If fewer candidates are available, all are retained for the existing reduced
iteration run. Candidate generation and ranking are unchanged.

# Repository boundary

Result views use purpose-specific reads. The index reads ID, status, minimum
RSS, and the chi-square threshold; Overview, MDV, and comparison tables read
only the best iteration. Confidence-interval plots read a hyperslab for the
selected reaction. Full iteration histories remain available through
`loadResultFile` / `loadResultFiles` for exports and analysis. RSS histograms
do not request per-iteration exit flags.

Each `ResultQueryService` owns its cache for one result directory. Index
refreshes scan directory metadata once and read only new or changed files.
Detailed entries use an LRU cache with a default 64 MiB data budget. File size
and modification time detect external changes; `ResultCatalog.invalidateCache`
also handles writes that preserve that signature. Batch result notifications
invalidate the affected ID, including the final notification after the batch
checkpoint. Manual Reload clears the cache, and opening another project creates
a new query service. Missing or corrupt index entries do not hide valid results.

`ResultPlotRenderer` retains graphics while the plot kind is unchanged, and
`ResultTableRenderer` updates changed index rows and groups identical styles.
Changing plot kind, clearing axes, and closing the figure discard graphics
state. Range plots reuse their interval, marker, and grid objects and remove
unused objects when the number of displayed rows or series decreases.

`ModelLocation`, `ExperimentLocation`, and `ResultLocation` are immutable path
values. Repositories accept a Location and return validated application or
domain values. A failed project open constructs no new main session, so the
previous session remains usable.

Writes that replace JSON metadata use a temporary file followed by an atomic
replacement. Analysis checkpoints are coordinated by `AnalysisRunRepository`;
each HDF5 result has a corresponding manifest when produced by the current
version.
