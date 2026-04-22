# Droplet Collision Boundary Fitting with Parameter Sweep & Validation

This computational script performs **high-resolution parameter sweeping and validation** for droplet collision regime boundaries on a **Weber number (We) vs impact parameter (B)** map.

It improves upon basic plotting by:

- Sweeping model parameters (`aa`, `bb`, `cc`)
- Detecting and rejecting **physically invalid curves**
- Evaluating **classification accuracy** against experimental data
- Recording parameter performance metrics
- Plotting only valid boundary curves

---

## Overview

The script:

1. Reads experimental droplet collision data from Excel
2. Separates **bouncing vs non-bouncing regimes**
3. Sweeps through a large parameter space (`aa`, `bb`, `cc`)
4. Generates theoretical boundary curves
5. Detects **abnormal (non-physical) curves**
6. Filters out invalid parameter combinations
7. Computes classification accuracy
8. Stores all valid parameter results
9. Plots valid boundaries over experimental data

---

## Key Features

-  Efficient memory usage (`clearvars` instead of `clear all`)
-  High-resolution parameter sweep
-  Automatic detection of non-monotonic (invalid) curves
-  Accuracy evaluation for classification
-  Intelligent filtering of bad parameter sets
-  Visualization of valid model boundaries

---

## Input Data

### Excel File

```matlab
All_data-gw80.xlsx
