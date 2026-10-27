# =============================================================================
# Health, happiness and socio-economic factors in Europe
# European Social Survey, round 9 (2018), edition 3.2
#
# Samuel Placek & Eytan Zaghroun, ENSAE Paris, December 2025
# Course: Descriptive statistics with R
#
# Usage (from the root of the repository):
#   1. Download ESS9e03_2.csv (see README) and put it in data/
#   2. Rscript R/analysis.R
# Figures are written to figures/, key statistics are printed to the console.
# =============================================================================

data_path <- file.path("data", "ESS9e03_2.csv")
if (!file.exists(data_path)) {
  stop("Data file not found: download ESS9e03_2.csv from the ESS Data Portal ",
       "and place it in the data/ folder (see README).")
}
dir.create("figures", showWarnings = FALSE)

df <- read.csv(data_path)

# Saves the plot drawn by `draw` to figures/<name>.png
save_plot <- function(name, draw, width = 1400, height = 700) {
  png(file.path("figures", paste0(name, ".png")), width = width, height = height, res = 130)
  on.exit(dev.off())
  draw()
}

EU_COL <- "steelblue"
FR_COL <- "firebrick"

cat("Respondents:", nrow(df), "| in France:", sum(df$cntry == "FR"), "\n")


# -----------------------------------------------------------------------------
# 1. Subjective happiness: France vs. Europe
#    happy: 0 (extremely unhappy) to 10 (extremely happy); 77/88/99 = no answer
# -----------------------------------------------------------------------------
df_h <- subset(df, !(happy %in% c(77, 88, 99)))

happy_country <- sort(tapply(df_h$happy, df_h$cntry, mean))
save_plot("01_happiness_by_country", function() {
  barplot(happy_country, las = 2, ylim = c(0, 10),
          col = ifelse(names(happy_country) == "FR", FR_COL, "grey75"),
          xlab = "Country", ylab = "Mean subjective happiness (0-10)",
          main = "Mean subjective happiness by country (France in red)")
})

save_plot("02_happiness_distribution", function() {
  par(mfrow = c(1, 2))
  breaks <- seq(-0.5, 10.5, by = 1)
  hist(df_h$happy, breaks = breaks, freq = FALSE, col = EU_COL, border = "white",
       xlab = "Subjective happiness", ylab = "Share of respondents", main = "Europe")
  hist(df_h$happy[df_h$cntry == "FR"], breaks = breaks, freq = FALSE, col = FR_COL,
       border = "white", xlab = "Subjective happiness", ylab = "Share of respondents",
       main = "France")
})


# -----------------------------------------------------------------------------
# 2. Health: a key driver of happiness
#    health is coded 1 (very good) to 5 (very bad); 7/8/9 = no answer.
#    It is reversed so that higher = better health (1 = very bad, 5 = very good).
# -----------------------------------------------------------------------------
df2 <- subset(df, !(health %in% c(7, 8, 9)) & !(happy %in% c(77, 88, 99)))
df2$health <- 6 - df2$health

cat("Median subjective health - Europe:", median(df2$health),
    "| France:", median(df2$health[df2$cntry == "FR"]), "\n")

save_plot("03_health_distribution", function() {
  par(mfrow = c(1, 2))
  breaks <- seq(0.5, 5.5, by = 1)
  hist(df2$health, breaks = breaks, freq = FALSE, col = EU_COL, border = "white",
       xlab = "Subjective health (1 = very bad, 5 = very good)", ylab = "Share of respondents",
       main = "Europe")
  hist(df2$health[df2$cntry == "FR"], breaks = breaks, freq = FALSE, col = FR_COL,
       border = "white", xlab = "Subjective health (1 = very bad, 5 = very good)",
       ylab = "Share of respondents", main = "France")
})

happy_health_EU <- tapply(df2$happy, df2$health, mean)
happy_health_FR <- tapply(df2$happy[df2$cntry == "FR"], df2$health[df2$cntry == "FR"], mean)
cat("\nMean happiness by health level (1 = very bad ... 5 = very good)\n")
print(round(rbind(Europe = happy_health_EU, France = happy_health_FR), 2))

save_plot("04_happiness_by_health", function() {
  plot(1:5, happy_health_EU, type = "b", pch = 20, col = EU_COL, lwd = 2, ylim = c(3, 9),
       xlab = "Subjective health (1 = very bad, 5 = very good)",
       ylab = "Mean subjective happiness", main = "Happiness by subjective health")
  lines(1:5, happy_health_FR, type = "b", pch = 20, col = FR_COL, lwd = 2)
  legend("topleft", legend = c("Europe", "France"), col = c(EU_COL, FR_COL), lwd = 2, bty = "n")
}, width = 1000, height = 750)

save_plot("04b_happiness_by_health_boxplot_FR", function() {
  boxplot(happy ~ health, data = df2[df2$cntry == "FR", ], col = FR_COL,
          xlab = "Subjective health (1 = very bad, 5 = very good)",
          ylab = "Subjective happiness", main = "Happiness by subjective health in France")
}, width = 1000, height = 750)


# -----------------------------------------------------------------------------
# 3. Education (years of full-time education completed)
#    eduyrs: 77/88/99 = no answer; edulvlb: 5555-9999 = other / no answer
# -----------------------------------------------------------------------------
df3 <- subset(df2, !(eduyrs %in% c(77, 88, 99)) &
                   !(edulvlb %in% c(5555, 6666, 7777, 8888, 9999)))

# Summary statistics on years of education for a few countries (Table 2 of the report),
# weighted with the ESS post-stratification weights (pspwght); n = weighted sample size
weighted_median <- function(x, w) {
  o <- order(x)
  x[o][which(cumsum(w[o]) / sum(w) >= 0.5)[1]]
}
edu_valid <- subset(df, !(eduyrs %in% c(77, 88, 99)))
edu_table <- t(sapply(c(France = "FR", Spain = "ES", UK = "GB", Germany = "DE", Belgium = "BE"),
  function(cc) {
    s <- edu_valid[edu_valid$cntry == cc, ]
    c(n = round(sum(s$pspwght)), min = min(s$eduyrs), max = max(s$eduyrs),
      median = weighted_median(s$eduyrs, s$pspwght),
      mean = round(weighted.mean(s$eduyrs, s$pspwght), 1))
  }))
cat("\nYears of education by country (weighted)\n")
print(edu_table)

happy_edu_EU  <- tapply(df3$happy,  df3$eduyrs, mean)
health_edu_EU <- tapply(df3$health, df3$eduyrs, mean)
fr <- df3$cntry == "FR"
happy_edu_FR  <- tapply(df3$happy[fr],  df3$eduyrs[fr], mean)
health_edu_FR <- tapply(df3$health[fr], df3$eduyrs[fr], mean)

save_plot("05_education_happiness_health", function() {
  par(mfrow = c(2, 2))
  plot_edu <- function(y, col, ylab, main) {
    plot(as.numeric(names(y)), y, type = "b", pch = 20, col = col,
         xlab = "Years of education", ylab = ylab, main = main)
  }
  plot_edu(happy_edu_FR,  FR_COL, "Mean happiness", "Happiness - France")
  plot_edu(happy_edu_EU,  EU_COL, "Mean happiness", "Happiness - Europe")
  plot_edu(health_edu_FR, FR_COL, "Mean health",    "Health - France")
  plot_edu(health_edu_EU, EU_COL, "Mean health",    "Health - Europe")
}, width = 1400, height = 1000)


# -----------------------------------------------------------------------------
# 4. Income (household's total net income, in deciles)
#    hinctnta: 1 to 10; 77/88/99 = no answer
# -----------------------------------------------------------------------------
df4 <- subset(df3, !(hinctnta %in% c(77, 88, 99)))

save_plot("06_income_distribution", function() {
  hist(df4$hinctnta, breaks = seq(0.5, 10.5, by = 1), col = "grey60", border = "white",
       xaxt = "n", xlab = "Household income decile", ylab = "Respondents",
       main = "Distribution of household income deciles (Europe)")
  axis(1, at = 1:10)
}, width = 1000, height = 750)

# Mean happiness and mean health for each income decile
happy_income_EU  <- tapply(df4$happy,  df4$hinctnta, mean)
health_income_EU <- tapply(df4$health, df4$hinctnta, mean)
fr <- df4$cntry == "FR"
happy_income_FR  <- tapply(df4$happy[fr],  df4$hinctnta[fr], mean)
health_income_FR <- tapply(df4$health[fr], df4$hinctnta[fr], mean)
cat("\nMean happiness and health by income decile\n")
print(round(rbind(happiness_EU = happy_income_EU, happiness_FR = happy_income_FR,
                  health_EU = health_income_EU, health_FR = health_income_FR), 2))

save_plot("07_income_happiness_health", function() {
  par(mfrow = c(2, 2))
  plot_inc <- function(y, col, ylab, main) {
    plot(as.numeric(names(y)), y, type = "b", pch = 20, col = col, xaxt = "n",
         xlab = "Household income decile", ylab = ylab, main = main)
    axis(1, at = 1:10)
  }
  plot_inc(happy_income_FR,  FR_COL, "Mean happiness", "Happiness by income - France")
  plot_inc(happy_income_EU,  EU_COL, "Mean happiness", "Happiness by income - Europe")
  plot_inc(health_income_FR, FR_COL, "Mean health",    "Health by income - France")
  plot_inc(health_income_EU, EU_COL, "Mean health",    "Health by income - Europe")
}, width = 1400, height = 1000)

cat("\nDone: figures saved in figures/\n")
