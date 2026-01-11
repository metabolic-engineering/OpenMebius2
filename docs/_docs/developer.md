---
title: For developers
author: Tatsumi Imada
date: 2025-10-03
category: Jekyll
layout: post
---

This page is for developers who want to improve or customize OpenMebius2.
The source code of OpenMebius2 is available on [GitHub](https://github.com/metabolic-engineering/OpenMebius2).

# Development environment

To set up a development environment, you need to have the following software installed:

- MATLAB R2025a or later
- MATLAB Optimization Toolbox
- MATLAB Statistics and Machine Learning Toolbox
- MATLAB Parallel Computing Toolbox (optional, for parallel processing)
- MATLAB Compiler (optional, for creating standalone applications)

# Data structure

## Model instance

The model instance is a MATLAB structure that contains the following fields:

| Field Name        | Type       | Description                                                                              |
| ----------------- | ---------- | ---------------------------------------------------------------------------------------- |
| `tableInfo`       | 5×2 table  | A table containing model information loaded from an Excel file.                          |
| `tableModel`      | N×3 table  | A table containing reactions loaded from an Excel file (N: reaction).                    |
| `tableMS`         | N×3 double | A table containing atom transition loaded from an Excel file (N: reaction).              |
| `tableBiomass`    | N×2 table  | A table containing biomass demands loaded from an Excel file (N: The number of biomass). |
| `tableXY`         | N×2 table  | A table containing positions of nodes in the metabolic pathway (N: The number of nodes). |
| `tableAtom`       | N×M table  | A table containing the number of atoms in each element (N: reaction, M: element).        |
| `fileTypeModel`   | string     | Model file type (e.g., `"xlsx"`).                                                        |
| `fileTypeLabel`   | string     | File type of label pattern information (e.g., `"json"`).                                 |
| `fileTypePathway` | string     | File type of pathway map (default: `"tiff"`).                                            |
| `fileModel`       | string     | Filename of the model file (default: `"metabolic_network"`).                             |
| `fileLabel`       | string     | Filename of the label pattern information (default: `"label"`).                          |
| `filePathway`     | string     | Filename of the pathway map (default: `"metabolic_pathway"`).                            |
| `modelRxn`        | N×4 table  | A table containing reaction information (N: reaction).                                   |
| `modelTrans`      | N×3 table  | A table containing atom transition information (N: reaction).                            |
| `MSRxn`           | N×3 table  | A table containing reaction information for mass spectrometry (N: reaction).             |
| `MSTrans`         | N×3 table  | A table containing atom transition information for mass spectrometry (N: reaction).      |


### Details of tables

- `modelRxn` fields:
  - `Properties.RowNames`: Reaction IDs (string)
  - `Reactants`: Cell array of reactant names (1xK cell, K: number of reactants)
  - `Products`: Cell array of product names (1xL cell, L: number of products)
  - `Reversible`: Logical value indicating if the reaction is reversible (true/false)
  - `Independent`: Logical value indicating if the reaction is designated as independent (true/false)

- `modelTrans` fields:
  - `Properties.RowNames`: Reaction IDs (string)
  - `Reactants`: Cell array of reactant atom patterns (1xK cell, K: number of reactants)
  - `Products`: Cell array of product atom patterns (1xL cell, L: number of products)
  - `Reversible`: Logical value indicating if the reaction is reversible (true/false)

- `MSRxn` fields:
  - `Properties.RowNames`: Fragment name (string)
  - `Reactants`: Cell array of reactant names (1xK cell, K: number of reactants)
  - `Products`: Cell array of product names (1xL cell, L: number of products)
  - `Reversible`: Logical value indicating if the reaction is reversible (true/false)

- `MSTrans` fields:
  - `Properties.RowNames`: Fragment name (string)
  - `Reactants`: Cell array of reactant atom patterns (1xK cell, K: number of reactants)
  - `Products`: Cell array of product atom patterns (1xL cell, L: number of products)
  - `Reversible`: Logical value indicating if the reaction is reversible (true/false)