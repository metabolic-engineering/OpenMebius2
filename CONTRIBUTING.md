# Contributing

## MATLAB test profiles

The test catalog is split into disjoint profiles. Every `*Test.m` file is
automatically assigned to exactly one profile.

| Profile | Scope | Default execution |
|---|---|---|
| `fast` | dependency boundaries, child-App contexts, composition, Session, and `.mlapp` synchronization | every pull request and push to `main` |
| `domain` | application, domain, presentation, and repository unit tests | local or manual CI |
| `numerical` | MFA, EMU, flux, confidence interval, and solver tests | weekly and manual CI |
| `integration` | GUI and cross-component integration tests | manual CI only |
| `all` | all profiles | local or manual CI |

Run the fast profile before submitting a pull request:

```powershell
matlab -batch "addpath('tests'); runFastTests"
```

To also write a JUnit report:

```powershell
matlab -batch "addpath('tests'); runFastTests(ReportDirectory='test-results')"
```

The fast suite is assembled from `tests/testProfileFiles.m`. It includes:

- all `*BoundaryTest.m` tests;
- all `*ContextTest.m` tests;
- Composition Root and Main Application Session tests;
- the profile catalog self-test;
- `OpenMebius2SourceSyncTest`, which compares every `.mlapp` code store with
  its corresponding exported source.

Name new dependency-boundary and child-App context tests using these
conventions so they are automatically included in pull-request CI.

Run another profile using the common runner:

```powershell
matlab -batch "addpath('tests'); runTestProfile('domain')"
matlab -batch "addpath('tests'); runTestProfile('numerical')"
matlab -batch "addpath('tests'); runTestProfile('integration')"
```

Run every profile with coverage and JUnit/Cobertura output through the legacy
entry point:

```powershell
matlab -batch "run('src/TestAll.m')"
```

`TestAll.m` no longer clears the MATLAB session or sends Slack notifications.
Test reporting is limited to runner output and files under `test-results/`.

## Continuous integration

`.github/workflows/matlab-fast-tests.yml` runs the fast profile for pull
requests and pushes to `main`.

`.github/workflows/matlab-extended-tests.yml` runs the numerical profile every
Saturday at 18:00 UTC. It can also be started manually with `domain`,
`numerical`, `integration`, or `all`. Extended runs use Windows so App Designer
integration tests execute on the same operating-system family as the primary
development environment.

## App Designer source synchronization

The `.mlapp` file is the application source of record. Keep its code in sync
with the corresponding `*_exported.m` review artifact in the same change.
Pull-request CI rejects changes when either the exported code or one of the
internal `.mlapp` code stores differs.
