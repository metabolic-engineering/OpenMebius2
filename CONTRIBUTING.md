# Contributing

## MATLAB test profiles

Run the fast boundary suite before submitting a pull request:

```powershell
matlab -batch "addpath('tests'); runFastTests"
```

To also write a JUnit report:

```powershell
matlab -batch "addpath('tests'); runFastTests(ReportDirectory='test-results')"
```

The fast suite is assembled by `tests/ciFastTestSuite.m`. It includes:

- all `*BoundaryTest.m` tests;
- all `*ContextTest.m` tests;
- Composition Root and Main Application Session tests;
- `OpenMebius2SourceSyncTest`, which compares every `.mlapp` code store with
  its corresponding exported source.

Name new dependency-boundary and child-App context tests using these
conventions so they are automatically included in pull-request CI.

Numerical analysis and GUI integration tests are intentionally excluded from
this profile. Run `src/TestAll.m` when the full local regression suite is
required.

## App Designer source synchronization

The `.mlapp` file is the application source of record. Keep its code in sync
with the corresponding `*_exported.m` review artifact in the same change.
Pull-request CI rejects changes when either the exported code or one of the
internal `.mlapp` code stores differs.
