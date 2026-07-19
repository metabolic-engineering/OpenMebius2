---
title: Data format
author: Tatsumi Imada
date: 2025-10-03
category: Jekyll
layout: post
---

# Model data format

Metabolic model consists of an Excel file defining the metabolic network, ```metabolic_network.xlsx```, a ```label.json``` file defining labeling information, and an image file of the metabolic map, ```metabolic_pathway.tiff```.
Each file is described below.

## Metabolic model Excel file

The metabolic model Excel file consists of these sheets, ```info```, ```model```, ```MS```, ```atom```, ```biomass```, and ```position```.

| Sheet name     | Description                                             |
| -------------- | ------------------------------------------------------- |
| ```info```     | General information about the model                     |
| ```model```    | Definition of reactions in the metabolic model          |
| ```MS```       | Observed mass fragments for metabolites                 |
| ```atom```     | The number of atoms for each element in the metabolites |
| ```biomass```  | The biomass coefficients for the biomass equation       |
| ```position``` | Positions of reactions in the metabolic map image       |

### info sheet
The ```info``` sheet contains general information about the model, such as the model name, author, date, and description.

{: align="center"}
![info_sheet](../../assets/images_dataformat/model_info.png)

### model sheet
The ```model``` sheet defines the reactions in the metabolic model. Each row represents a reaction, with columns for reaction ID, reaction, and atom mapping information.
Each reaction is represented in the format "A + B --> C + D", where A, B, C, and D are metabolite IDs.

#### Reaction format

| Symbol    | Meaning                               |
| --------- | ------------------------------------- |
| (space)   | Separates each metabolite and symbol. |
| ```+```   | Indicates multiple metabolites.       |
| ```-->``` | Indicates the irreversible reaction.  |
| ```<=>``` | Indicates the reversible reaction.    |

| Metabolite name | Meaning                                                                             |
| --------------- | ----------------------------------------------------------------------------------- |
| ```A```         | Indicates metabolite A.                                                             |
| ```Subs_A```    | Indicates substrate A and this metabolite will become efflux reaction in the model. |
| ```Sym_A```     | Indicates symbiotic metabolite A such as a succinate.                               |

| Column name       | Description                                                                                                                                                                         |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ```ID```          | Reaction ID, that must be unique in the model.                                                                                                                                      |
| ```Reaction```    | Reaction formula as described above.                                                                                                                                                |
| ```Transition```  | Atom mapping information for the reaction. The number of parts must match that of the reaction. Each part describes the mapping from substrate to product.                          |
| ```Independent``` | Boolean value indicating whether the reaction sets as independent (TRUE) or dependent (FALSE) in the model. If TRUE, the reaction flux will be enforced to be independent variable. |

{: align="center"}
![model_sheet](../../assets/images_dataformat/model_model.png)

### MS sheet
The ```MS``` sheet lists the observed mass fragments for metabolites. Each row corresponds to a metabolite, with columns for metabolite ID, name, and the mass fragments observed in the experiment.

| Column name      | Description                                                                                                                                                |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ```ID```         | Metabolite ID, that must not be duplicated in the model (including model shhet).                                                                           |
| ```Reaction```   | Reaction formula for producing the metabolite to be measured.                                                                                              |
| ```Transition``` | Atom mapping information for the reaction. The number of parts must match that of the reaction. Each part describes the mapping from substrate to product. |
| ```Used```       | Boolean value indicating whether the mass fragment is used (TRUE) or not (FALSE) in the model fitting.                                                     |

{: align="center"}
![ms_sheet](../../assets/images_dataformat/model_ms.png)

### biomass sheet
The ```biomass``` sheet defines the biomass coefficients for the biomass equation. Each row represents a metabolite and its coefficient in the biomass equation.

| Column name     | Description                                                                            |
| --------------- | -------------------------------------------------------------------------------------- |
| ```Precursor``` | Metabolite name in the biomass equation (must match the metabolite name in the model). |
| ```Biomass```   | Coefficient of the metabolite in the biomass equation in ```mmol gDCW^-1```.           |

{: align="center"}
![biomass_sheet](../../assets/images_dataformat/model_biomass.png)

### position sheet
The ```position``` sheet specifies the positions of reactions in the metabolic map image.

| Column name | Description                                                                   |
| ----------- | ----------------------------------------------------------------------------- |
| ```ID```    | Reaction ID, that must match the reaction ID in the model sheet.              |
| ```x```     | X-coordinate of the reaction position in the metabolic map image (in pixels). |
| ```y```     | Y-coordinate of the reaction position in the metabolic map image (in pixels). |

{: align="center"}
![position_sheet](../../assets/images_dataformat/model_position.png)

## ```label.json``` file
The ```label.json``` file defines the tracer labeling information for each substrate metabolite.
In general, the file is automatically generated when the user inputs tracer information through the GUI.
Each metabolite is represented as a JSON object, with the following structure:

```json
{
    "x_1_Glc": {
        "name": "[1]Glc",
        "num": 6,
        "label": [
            "#100000",
            "#000000"
        ],
        "ratio": [
            0.99,
            0.01
        ]
    },
    "x_12_Glc": {
        "name": "[12]Glc",
        "num": 6,
        "label": [
            "#110000",
            "#100000",
            "#010000",
            "#000000"
        ],
        "ratio": [
            0.98,
            0.01,
            0.01,
            0
        ]
    },
    ...
}
```

| Key         | Description                                                                                                      |
| ----------- | ---------------------------------------------------------------------------------------------------------------- |
| Tracer key  | Tracer key generated from a tracer name automatically (e.g., ```x_1_Glc```). Edited manually is not recommended. |
| ```name```  | Tracer name (e.g., ```[1]Glc``` for glucose labeled at carbon 1). ```name``` was defined by the user.            |
| ```num```   | Number of labeled atoms in the metabolite (e.g., 6 for glucose).                                                 |
| ```label``` | List of labeling patterns represented as binary strings (e.g., ```#100000``` for glucose labeled at carbon 1).   |
| ```ratio``` | List of fractions corresponding to each labeling pattern. The sum of the ratios must be 1.                       |

# Experiment workbook

Each experiment is stored as an `.xlsx` workbook in `experiments/`. The workbook
name, without its extension, is the experiment name used by Batch definitions.

| Sheet | Required | Content |
|---|---|---|
| `info` | Yes | `mu`, `ODi`, and `ODf` numeric values |
| `substrate` | Yes | Row-named substrate table with `Uptake` and `Label` |
| `MS` | Yes for measured data | Raw mass-isotopomer measurements |
| `MS (Normalized)` | Derived | Normalized MS values |
| `MDV` | Derived | Corrected mass distribution vectors |
| `MDV (biomass)` | Derived | Biomass-corrected MDVs |
| `Enrichment` | Derived | Calculated enrichment values |

The repository can reconstruct missing derived sheets from available inputs.
Derived sheets are persisted when the experiment is saved. Older aliases for
derived sheet names are resolved by `ExperimentWorkbookStore`.

# Project directory

A project uses the following canonical layout:

```text
project/
|-- setting.om2
|-- setting.json
|-- model/
|-- experiments/
|   `-- batch.json
`-- results/
    |-- <batch-id>.h5
    `-- <batch-id>.manifest.json
```

`setting.om2` is the current metadata file. `setting.json` is maintained as a
compatibility copy. Both contain `Name`, `Author`, and `Organism`.

# Batch JSON

The current Batch schema is version 2:

```json
{
  "schemaVersion": 2,
  "batches": [
    {
      "id": "bat_0123456789abcdef",
      "name": "baseline",
      "exp": ["WT"],
      "description": "",
      "config": {},
      "contentHash": "sha256:..."
    }
  ]
}
```

`config` is normalized and validated by `BatchConfig`. `id` is stable identity.
`contentHash` is not shown in the GUI and represents semantic analysis inputs;
it excludes random state and transient runtime fields.

# Result manifest

Each current HDF5 result is accompanied by a version 1 JSON manifest. Its
top-level sections are:

| Section | Content |
|---|---|
| `batch` | Stable ID, content hash, and hash algorithm version |
| `result` | HDF5 filename, SHA-256, byte size, and completion status |
| `software` | OpenMebius2 version, MATLAB release/version, and Toolboxes |
| `model` | Model filename and SHA-256 |
| `experiments` | Ordered experiment names, filenames, and SHA-256 values |
| `analysis` | Metadata schema version and canonical analysis config |
| `random` | Generator type, seed, and state used for execution |
| `run` | UTC start/end timestamps and error/cancellation flags |

The manifest filename is `<batch-id>.manifest.json`. Older `.h5` files without a
manifest remain readable but cannot provide complete provenance. See
[Migration](migration.md) for compatibility rules.
