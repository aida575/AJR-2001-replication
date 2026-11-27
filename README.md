# Replication and Extension of Acemoglu, Johnson & Robinson (2001)

Paper: Acemoglu, D., Johnson, S. & Robinson, J. A. (2001), "The Colonial Origins of Comparative Development: An Empirical Investigation", *American Economic Review* 91(5), 1369-1401.
Replication package of the authors: https://economics.mit.edu/people/faculty/daron-acemoglu/data-archive

This repository contains two parts:

- **Replication (R):** `replication.R` replicates Figure 1 (reduced form), Figure 3 (first stage) and Table 4 (IV regressions of log GDP per capita, Panels A-C, columns 1-9). Output goes to `output/`.
- **Extension (Python):** `AJR_section5_results.ipynb` re-estimates the baseline 2SLS with income measured in other years and in an extended sample (Section 5 of the report). Output goes to `results/` and `figures/section5/`. See [Extension](#extension-section-5) below.

## Data
The original datasets are available from the MIT Data Archive (https://economics.mit.edu/people/faculty/daron-acemoglu/data-archive) of Daron Acemoglu.
Download `maketable1.zip` and `maketable4.zip` from the authors' replication package and place both files in the `data/` folder without extracting them. 
The master script reads the Stata datasets directly from the ZIP archives.

## Folder Structure
```
AJR-2001-replication/
├── replication.R                  # Replication: master script (R)
├── AJR_section5_results.ipynb     # Extension: notebook (Python)
├── AJR-2001-replication.Rproj      # RStudio project
├── README.md
├── .gitignore                     # Git exclusions
├── data/
│   ├── maketable1.zip             # Original authors' data
│   ├── maketable4.zip             # Original authors' data
│   └── source/                    # Extension input data (included; see data/source/README.md)
├── output/                        # Replication output (automatically created)
├── results/                       # Extension tables (created by the notebook)
└── figures/section5/              # Extension figure (created by the notebook)
```

`replication.R` generates the following files in the `output/` folder:

- `figure1_R.png` and `figure3_R.png`
- `table4_panel_A_R.csv`, `table4_panel_B_R.csv`, and `table4_panel_C_R.csv`
- `session_info.txt`

Missing-value counts and summary statistics are displayed in the R console.

## Software
R 4.6.1 (RStudio 2026.10.1); packages `haven` 2.5.5, `AER` 1.2.17, `ggplot2` 4.0.3. The versions used are also recorded in `output/session_info.txt` when the script runs.

## How to run
1. Install R (and RStudio if using the RStudio project).
2. Download or clone this repository.
3. Ensure that `maketable1.zip` and `maketable4.zip` are located in the `data/` folder.
4. Open `AJR-2001-replication.Rproj` in RStudio.
5. Open `replication.R` and click **Source** to run the entire script.

Alternatively, run `Rscript replication.R` from the project directory in a terminal.

The script automatically installs missing R packages, loads the original datasets, checks missing values, calculates summary statistics, and reproduces Figures 1 and 3 and Table 4 (Panels A–C, columns 1–9).
All steps are executed sequentially in a single master script, `replication.R`. No additional scripts are required.

The generated figures, tables, and software version information are saved in the `output/` folder. Missing-value counts and summary statistics are displayed in the R console.

## Data Check (Summary Statistics and Missing Values)
The script reports missing-value counts for the original datasets and summary statistics for the samples used in Figures 1 and 3 and the Table 4 baseline sample. These results are displayed in the R console.
The Table 4 baseline sample contains 64 countries. The number of observations varies across specifications due to sample restrictions and missing values.

## Samples
- **Table 4 and Figure 3:** The 64 base-sample countries (`baseco == 1`).
- **Figure 1:** The paper reports 75 countries. Since the replication files do not provide a figure-specific sample indicator, six countries (FRA, GBR, CHN, KOR, THA and SUR) were excluded from maketable1.dta based on a visual comparison with the published figure. This yields the reported 75 observations.
The figures are reconstructed using the available data and the information reported in the paper.

## Extension (Section 5)

`AJR_section5_results.ipynb` re-estimates AJR's baseline 2SLS (Table 4, column 1) with income measured in 1970, 1975, 1980, 1995, 2000, 2009 and 2025, and in a sample extended by seven Middle Eastern countries with an oil-rich indicator. It tests H0: β_t = 0, H0: β_t = 0.94 and H0: β_t = β_s (long run and crisis windows) with two-sided t-tests and homoskedastic standard errors, as in AJR.

**Data:** all inputs are in `data/source/` (sources in `data/source/README.md`); nothing is downloaded.

**Output:**
- `results/table2.csv`, `results/table2.tex`: estimates by year and sample (Section 5 table and Appendix).
- `results/change_tests.csv`: tests of change in β (Appendix).
- `figures/section5/beta_by_year.png`: coefficient by year.

**How to run** (Python 3.9.6, `numpy` 2.0.2, `pandas` 2.3.3, `scipy` 1.13.1, `matplotlib` 3.9.4; takes a few seconds):
```
pip install numpy pandas scipy matplotlib nbconvert ipykernel
python3 -m nbconvert --to notebook --execute --inplace AJR_section5_results.ipynb
```
Alternatively, open the notebook and choose **Run All**.
