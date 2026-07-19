---
title: Migration
author: Tatsumi Imada
date: 2026-07-19
category: Jekyll
layout: post
---

# Compatibility policy

Persisted data is migrated at repository boundaries. Migration produces the
current in-memory representation before application and numerical code receives
it. Unknown future schema versions are rejected instead of being guessed.

Migration must be deterministic, covered by a fixture, and must not change MFA
semantics silently. Keep old input fixtures under `tests/fixtures/compatibility`
and add cases to `MigrationCompatibilityTest`.

# Project metadata

Current projects use `setting.om2`; `setting.json` remains a readable legacy
alias. Both contain `Name`, `Author`, and `Organism`.

When a project containing only `setting.json` is opened through
`ProjectOperationController`, `ProjectMigrationService` writes canonical
metadata to `setting.om2` and refreshes the compatibility copy. Model,
experiment, and result files are not rewritten by this step.

# Batch JSON

The current Batch document schema is version 2.

| Input version | Shape | Migration |
|---|---|---|
| 0 | Unversioned array of batch objects | Wrap as `{schemaVersion: 1, batches: [...]}` |
| 1 | Versioned document without stable identity fields | Assign a stable `bat_<uuid>` ID and initialize `contentHash` |
| 2 | Current document | Normalize every config with `BatchConfig` |

Missing configuration fields are filled from `BatchConfig.defaultConfig()` and
validated. The obsolete `config.random` field is removed. Loading performs the
migration in memory; the next save writes schema version 2 atomically.

Batch `id` is stable identity and is never derived again after creation.
`contentHash` is a reproducibility fingerprint over semantic config, model
SHA-256, and ordered experiment names and SHA-256 values. Runtime status,
result-deletion policy, and random state are excluded from that hash.

# Result and manifest

Current analyses write two files with the same Batch ID:

```text
results/<batch-id>.h5
results/<batch-id>.manifest.json
```

Manifest schema version 1 records software versions, model and experiment
hashes, canonical analysis configuration, random generator state, timestamps,
completion state, and the HDF5 hash and size. An unversioned manifest is treated
as schema version 0 and normalized to version 1 on read.

Older HDF5 results without a manifest remain readable. A missing manifest means
that provenance fields are unavailable; readers must not fabricate hashes or
software versions. Saving a new analysis always creates a manifest.

# Migration checklist

1. Increment the owning migration class's current schema version.
2. Add one explicit `vNToVNPlus1` transformation.
3. Preserve all earlier transformations and reject versions newer than current.
4. Add old and expected-current fixtures without modifying the old fixture.
5. Test both direct migration and repository loading.
6. Update [Data format](format.md) in the same change.
