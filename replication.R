# Replication of  Acemoglu, D., Johnson, S. & Robinson, J. A. (2001), "The Colonial Origins of Comparative Development: An Empirical Investigation", *American Economic Review* 91(5), 1369-1401.
# Figure 1, Figure 3, and Table 4 (Panels A-C, columns 1-9)

# Install missing packages
packages <- c("haven", "ggplot2", "AER")

missing_packages <- packages[
  !sapply(packages, requireNamespace, quietly = TRUE)
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

library(haven)
library(ggplot2)
library(AER)

# Project folders
data_dir <- "data"
output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE)

# Check that the working directory is correct
stopifnot(file.exists(file.path(data_dir, "maketable1.zip")))
stopifnot(file.exists(file.path(data_dir, "maketable4.zip")))

# Read a Stata file directly from a ZIP archive
read_zipped_dta <- function(zip_path, dta_name) {
  temp_dir <- tempfile("stata_")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)
  unzip(zip_path, files = dta_name, exdir = temp_dir)
  as.data.frame(read_dta(file.path(temp_dir, dta_name)))
}

# Load original datasets
figure_data <- read_zipped_dta(
  file.path(data_dir, "maketable1.zip"), "maketable1.dta"
)

table_raw <- read_zipped_dta(
  file.path(data_dir, "maketable4.zip"), "maketable4.dta"
)

# ---------------------------------------------------------------
# DATA CHECKS: Missing values
# ---------------------------------------------------------------

figure_vars <- c("logpgp95", "logem4", "avexpr", "baseco")
table_vars <- c("logpgp95", "loghjypl", "avexpr",
                "logem4", "lat_abst", "baseco")

cat("\nMISSING VALUES: FIGURE DATASET\n")
print(colSums(is.na(figure_data[figure_vars])))

cat("\nMISSING VALUES: TABLE 4 DATASET\n")
print(colSums(is.na(table_raw[table_vars])))

# ---------------------------------------------------------------
# FIGURE 1: Reduced-form relationship between income and mortality
# ---------------------------------------------------------------

fig1 <- figure_data[
  complete.cases(figure_data[, c("logpgp95", "logem4")]),
]

excluded_fig1 <- c("FRA", "GBR", "CHN", "KOR", "THA", "SUR")
fig1 <- fig1[!(fig1$shortnam %in% excluded_fig1), ]

# Summary statistics for Figure 1
cat("\nSUMMARY STATISTICS: FIGURE 1\n")
print(summary(fig1[c("logpgp95", "logem4")]))
print(sapply(fig1[c("logpgp95", "logem4")], sd, na.rm = TRUE))

model_fig1 <- lm(logpgp95 ~ logem4, data = fig1)

cat("\nFIGURE 1\n")
cat("Observations:", nrow(fig1), "\n")
print(coef(model_fig1))

plot_fig1 <- ggplot(fig1, aes(x = logem4, y = logpgp95)) +
  geom_point(color = "black", size = 1.5) +
  geom_text(aes(label = shortnam), size = 2.5, vjust = -0.5) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
              color = "black", linewidth = 0.5) +
  labs(
    title = "Figure 1. Reduced-Form Relationship Between Income and Settler Mortality",
    x = "Log of Settler Mortality",
    y = "Log GDP per capita, PPP, 1995"
  ) +
  theme_classic(base_size = 11)

print(plot_fig1)

ggsave(file.path(output_dir, "figure1_R.png"),
       plot_fig1, width = 10, height = 6, dpi = 300)

# ---------------------------------------------------------------
# FIGURE 3: First-stage relationship between mortality and institutions
# ---------------------------------------------------------------

fig3 <- figure_data[
  !is.na(figure_data$baseco) &
    figure_data$baseco == 1 &
    complete.cases(figure_data[, c("logem4", "avexpr")]),
]

# Summary statistics for Figure 3
cat("\nSUMMARY STATISTICS: FIGURE 3\n")
print(summary(fig3[c("logem4", "avexpr")]))
print(sapply(fig3[c("logem4", "avexpr")], sd, na.rm = TRUE))

model_fig3 <- lm(avexpr ~ logem4, data = fig3)

cat("\nFIGURE 3\n")
cat("Observations:", nrow(fig3), "\n")
print(coef(model_fig3))

plot_fig3 <- ggplot(fig3, aes(x = logem4, y = avexpr)) +
  geom_point(color = "black", size = 1.5) +
  geom_text(aes(label = shortnam), size = 2.5, vjust = -0.5) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
              color = "black", linewidth = 0.5) +
  labs(
    title = "Figure 3. First-Stage Relationship Between Settler Mortality and Expropriation Risk",
    x = "Log of Settler Mortality",
    y = "Average Protection Against Expropriation Risk, 1985–95"
  ) +
  theme_classic(base_size = 11)

print(plot_fig3)

ggsave(file.path(output_dir, "figure3_R.png"),
       plot_fig3, width = 10, height = 6, dpi = 300)

# ---------------------------------------------------------------
# TABLE 4: 2SLS, first-stage OLS, and OLS, columns 1-9
# ---------------------------------------------------------------

table_data <- table_raw[
  !is.na(table_raw$baseco) & table_raw$baseco == 1,
]

table_data$other_cont <- as.integer(
  table_data$shortnam %in% c("AUS", "MLT", "NZL")
)

# Missing values in the Table 4 baseline sample
cat("\nMISSING VALUES: TABLE 4 BASELINE SAMPLE\n")
print(colSums(is.na(table_data[
  c("logpgp95", "loghjypl", "avexpr", "logem4", "lat_abst")
])))

# Summary statistics for Table 4 baseline sample
cat("\nSUMMARY STATISTICS: TABLE 4 BASELINE SAMPLE\n")
print(summary(table_data[c("logpgp95", "loghjypl",
                           "avexpr", "logem4", "lat_abst")]))

print(sapply(table_data[c("logpgp95", "loghjypl",
                          "avexpr", "logem4", "lat_abst")],
             sd, na.rm = TRUE))

# Extract coefficient and standard error; blank if variable absent.
coef_se <- function(model, variable) {
  estimates <- coef(summary(model))
  if (!(variable %in% rownames(estimates))) return("")
  sprintf("%.2f (%.2f)", estimates[variable, "Estimate"],
          estimates[variable, "Std. Error"])
}

# Row order matches the published table (Asia before Africa).
rows_A <- c("Protection against expropriation", "Latitude", "Asia dummy",
            "Africa dummy", "Other continent dummy", "Observations")

rows_B <- c("Log settler mortality", "Latitude", "Asia dummy",
            "Africa dummy", "Other continent dummy", "R-squared", "Observations")

rows_C <- c("Protection against expropriation", "Latitude", "Asia dummy",
            "Africa dummy", "Other continent dummy", "R-squared", "Observations")

panel_A <- matrix("", nrow = length(rows_A), ncol = 9,
                  dimnames = list(rows_A, as.character(1:9)))

panel_B <- matrix("", nrow = length(rows_B), ncol = 9,
                  dimnames = list(rows_B, as.character(1:9)))

panel_C <- matrix("", nrow = length(rows_C), ncol = 9,
                  dimnames = list(rows_C, as.character(1:9)))

for (col in 1:9) {
  sample <- table_data
  controls <- character(0)
  y_var <- if (col == 9) "loghjypl" else "logpgp95"
  
  if (col %in% c(2, 4, 6, 8)) {
    controls <- c(controls, "lat_abst")
  }
  
  if (col %in% c(3, 4)) {
    sample <- sample[!is.na(sample$rich4) & sample$rich4 != 1, ]
  }
  
  if (col %in% c(5, 6)) {
    sample <- sample[!is.na(sample$africa) & sample$africa != 1, ]
  }
  
  if (col %in% c(7, 8)) {
    controls <- c(controls, "africa", "asia", "other_cont")
  }
  
  needed <- c(y_var, "avexpr", "logem4", controls)
  sample <- sample[complete.cases(sample[, needed, drop = FALSE]), ]
  
  # Structural equation
  outcome_formula <- reformulate(
    c("avexpr", controls), response = y_var
  )
  
  # Instrumental-variable equation
  iv_formula <- as.formula(paste(
    paste(deparse(outcome_formula), collapse = ""), "|",
    paste(c("logem4", controls), collapse = " + ")
  ))
  
  first_formula <- reformulate(
    c("logem4", controls), response = "avexpr"
  )
  
  iv_model <- ivreg(iv_formula, data = sample)    # Panel A: 2SLS
  first_model <- lm(first_formula, data = sample) # Panel B: first stage
  ols_model <- lm(outcome_formula, data = sample) # Panel C: OLS
  
  # All coefficients, including continent dummies
  for (item in list(c("Latitude", "lat_abst"),
                    c("Asia dummy", "asia"),
                    c("Africa dummy", "africa"),
                    c("Other continent dummy", "other_cont"))) {
    
    label <- item[1]
    variable <- item[2]
    
    panel_A[label, col] <- coef_se(iv_model, variable)
    panel_B[label, col] <- coef_se(first_model, variable)
    panel_C[label, col] <- coef_se(ols_model, variable)
  }
  
  panel_A["Protection against expropriation", col] <- coef_se(iv_model, "avexpr")
  panel_B["Log settler mortality", col] <- coef_se(first_model, "logem4")
  panel_C["Protection against expropriation", col] <- coef_se(ols_model, "avexpr")
  
  panel_B["R-squared", col] <- sprintf("%.2f", summary(first_model)$r.squared)
  panel_C["R-squared", col] <- sprintf("%.2f", summary(ols_model)$r.squared)
  
  panel_A["Observations", col] <- as.character(nrow(sample))
  panel_B["Observations", col] <- as.character(nrow(sample))
  panel_C["Observations", col] <- as.character(nrow(sample))
}

cat("\nPANEL A: TWO-STAGE LEAST SQUARES\n")
print(noquote(panel_A), quote = FALSE)

cat("\nPANEL B: FIRST STAGE\n")
print(noquote(panel_B), quote = FALSE)

cat("\nPANEL C: ORDINARY LEAST SQUARES\n")
print(noquote(panel_C), quote = FALSE)

# Save table results
write.csv(panel_A, file.path(output_dir, "table4_panel_A_R.csv"))
write.csv(panel_B, file.path(output_dir, "table4_panel_B_R.csv"))
write.csv(panel_C, file.path(output_dir, "table4_panel_C_R.csv"))

# ---------------------------------------------------------------
# SOFTWARE AND PACKAGE VERSIONS
# ---------------------------------------------------------------

cat("\nSESSION INFORMATION\n")
print(sessionInfo())

# Save software and package versions
capture.output(sessionInfo(),
               file = file.path(output_dir, "session_info.txt"))

cat("\nReplication completed. Results saved in the output folder.\n")
