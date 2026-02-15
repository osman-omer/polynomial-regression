# --------------------------------------------------------
# Project: Polynomial Regression
# Goal: Examine non-linear relationships between age/BMI and 
#       insurance charges using polynomial terms
#
# Variables:
#   - Outcome (Y): Charges (USD) — Continuous
#   - Predictors (X): 
#       * Age (Years) — Continuous
#       * Age² — Polynomial term
#       * BMI — Continuous
#       * BMI² — Polynomial term
#
# Key Concepts:
#   1. Non-linear relationships
#   2. Polynomial terms (quadratic, cubic)
#   3. Model comparison (linear vs polynomial)
#   4. Overfitting risk
#   5. Optimal degree selection
#
# Author: Osman Omer Mustafa (Medical Student & Data Analyst Trainee)
# Date: February 2026
# --------------------------------------------------------

# 0) Load required libraries
library(tidyverse)
library(broom)
library(ggfortify)

# 1) Read data
data <- read_csv("insurance.csv")

# 2) Basic checks
glimpse(data)
summary(data)
sum(is.na(data))

# 3) Ensure categorical variables are factors
data <- data %>% 
  mutate(
    sex = as.factor(sex),
    smoker = as.factor(smoker),
    region = as.factor(region)
  )

glimpse(data)

# --------------------------------------------------------
# EXPLORATORY DATA ANALYSIS
# --------------------------------------------------------

# 4) Scatter plot: Age vs Charges
scatter_age <- ggplot(data, aes(x = age, y = charges)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess", color = "red", se = FALSE) +
  geom_smooth(method = "lm", color = "blue", se = FALSE) +
  labs(
    x = "Age (Years)",
    y = "Insurance Charges (USD)",
    title = "Age vs Charges: Linear (Blue) vs Smoothed (Red)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
scatter_age

# 5) Scatter plot: BMI vs Charges
scatter_bmi <- ggplot(data, aes(x = bmi, y = charges)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess", color = "red", se = FALSE) +
  geom_smooth(method = "lm", color = "blue", se = FALSE) +
  labs(
    x = "Body Mass Index (BMI)",
    y = "Insurance Charges (USD)",
    title = "BMI vs Charges: Linear (Blue) vs Smoothed (Red)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
scatter_bmi

# --------------------------------------------------------
# MODELS: AGE POLYNOMIAL
# --------------------------------------------------------

# 6) Linear model (baseline)
model_age_linear <- lm(charges ~ age, data = data)

# 7) Quadratic model
model_age_quad <- lm(charges ~ age + I(age^2), data = data)

# 8) Cubic model
model_age_cubic <- lm(charges ~ age + I(age^2) + I(age^3), data = data)

# 9) View results
tidy_age_linear <- tidy(model_age_linear, conf.int = TRUE)
tidy_age_linear

tidy_age_quad <- tidy(model_age_quad, conf.int = TRUE)
tidy_age_quad

tidy_age_cubic <- tidy(model_age_cubic, conf.int = TRUE)
tidy_age_cubic

# 10) Model performance
glance_age_linear <- glance(model_age_linear)
glance_age_quad <- glance(model_age_quad)
glance_age_cubic <- glance(model_age_cubic)

age_performance <- bind_rows(
  glance_age_linear %>% mutate(model = "Linear"),
  glance_age_quad %>% mutate(model = "Quadratic"),
  glance_age_cubic %>% mutate(model = "Cubic")
) %>%
  select(model, r.squared, adj.r.squared, AIC, BIC)

age_performance

# --------------------------------------------------------
# MODELS: BMI POLYNOMIAL
# --------------------------------------------------------

# 11) Linear model (baseline)
model_bmi_linear <- lm(charges ~ bmi, data = data)

# 12) Quadratic model
model_bmi_quad <- lm(charges ~ bmi + I(bmi^2), data = data)

# 13) Cubic model
model_bmi_cubic <- lm(charges ~ bmi + I(bmi^2) + I(bmi^3), data = data)

# 14) View results
tidy_bmi_linear <- tidy(model_bmi_linear, conf.int = TRUE)
tidy_bmi_linear

tidy_bmi_quad <- tidy(model_bmi_quad, conf.int = TRUE)
tidy_bmi_quad

tidy_bmi_cubic <- tidy(model_bmi_cubic, conf.int = TRUE)
tidy_bmi_cubic

# 15) Model performance
glance_bmi_linear <- glance(model_bmi_linear)
glance_bmi_quad <- glance(model_bmi_quad)
glance_bmi_cubic <- glance(model_bmi_cubic)

bmi_performance <- bind_rows(
  glance_bmi_linear %>% mutate(model = "Linear"),
  glance_bmi_quad %>% mutate(model = "Quadratic"),
  glance_bmi_cubic %>% mutate(model = "Cubic")
) %>%
  select(model, r.squared, adj.r.squared, AIC, BIC)

bmi_performance

# --------------------------------------------------------
# MODEL COMPARISON
# --------------------------------------------------------

# 16) ANOVA: Age models
anova(model_age_linear, model_age_quad, model_age_cubic)

# 17) ANOVA: BMI models
anova(model_bmi_linear, model_bmi_quad, model_bmi_cubic)

# --------------------------------------------------------
# VISUALIZATION: POLYNOMIAL CURVES
# --------------------------------------------------------

# Create plots directory
if (!dir.exists("plots")) dir.create("plots")

# 18) Age: Fitted curves comparison
age_range <- seq(min(data$age), max(data$age), length.out = 100)

predictions_age <- data.frame(age = age_range) %>%
  mutate(
    linear = predict(model_age_linear, newdata = .),
    quadratic = predict(model_age_quad, newdata = .),
    cubic = predict(model_age_cubic, newdata = .)
  ) %>%
  pivot_longer(cols = c(linear, quadratic, cubic), 
               names_to = "model", 
               values_to = "predicted")

age_curves <- ggplot() +
  geom_point(data = data, aes(x = age, y = charges), alpha = 0.3) +
  geom_line(data = predictions_age, 
            aes(x = age, y = predicted, color = model), 
            linewidth = 1.2) +
  labs(
    x = "Age (Years)",
    y = "Insurance Charges (USD)",
    title = "Age vs Charges: Polynomial Model Comparison",
    color = "Model"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("plots/age_polynomial_curves.png", age_curves, width = 8, height = 5)
age_curves

# 19) BMI: Fitted curves comparison
bmi_range <- seq(min(data$bmi), max(data$bmi), length.out = 100)

predictions_bmi <- data.frame(bmi = bmi_range) %>%
  mutate(
    linear = predict(model_bmi_linear, newdata = .),
    quadratic = predict(model_bmi_quad, newdata = .),
    cubic = predict(model_bmi_cubic, newdata = .)
  ) %>%
  pivot_longer(cols = c(linear, quadratic, cubic), 
               names_to = "model", 
               values_to = "predicted")

bmi_curves <- ggplot() +
  geom_point(data = data, aes(x = bmi, y = charges), alpha = 0.3) +
  geom_line(data = predictions_bmi, 
            aes(x = bmi, y = predicted, color = model), 
            linewidth = 1.2) +
  labs(
    x = "Body Mass Index (BMI)",
    y = "Insurance Charges (USD)",
    title = "BMI vs Charges: Polynomial Model Comparison",
    color = "Model"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("plots/bmi_polynomial_curves.png", bmi_curves, width = 8, height = 5)
bmi_curves

# --------------------------------------------------------
# DIAGNOSTIC PLOTS: BEST MODEL
# --------------------------------------------------------

# 20) Choose best model based on adjusted R² and AIC
# For Age: compare models
best_age_model <- model_age_quad  # Usually quadratic is sufficient

# 21) Diagnostic plots for age quadratic model
autoplot(best_age_model, which = 1:4, ncol = 2)

# For BMI: compare models
best_bmi_model <- model_bmi_quad

# 22) Diagnostic plots for BMI quadratic model
autoplot(best_bmi_model, which = 1:4, ncol = 2)

# --------------------------------------------------------
# COMBINED MODEL WITH POLYNOMIAL TERMS
# --------------------------------------------------------

# 23) Full model with both polynomial terms
model_combined <- lm(charges ~ age + I(age^2) + bmi + I(bmi^2), 
                     data = data)

tidy_combined <- tidy(model_combined, conf.int = TRUE)
tidy_combined

glance_combined <- glance(model_combined)
glance_combined

# 24) Compare with simple multiple regression
model_simple_multiple <- lm(charges ~ age + bmi, data = data)

anova(model_simple_multiple, model_combined)

# 25) Performance comparison
comparison <- bind_rows(
  glance(model_simple_multiple) %>% mutate(model = "Linear (age + bmi)"),
  glance_combined %>% mutate(model = "Polynomial (age² + bmi²)")
) %>%
  select(model, r.squared, adj.r.squared, AIC, BIC)

comparison

# --------------------------------------------------------
# OVERFITTING CHECK
# --------------------------------------------------------

# 26) Test very high degree polynomial (overfitting example)
model_age_overfit <- lm(charges ~ poly(age, degree = 10, raw = TRUE), 
                        data = data)

glance_age_overfit <- glance(model_age_overfit)
glance_age_overfit

# 27) Compare reasonable vs overfit
overfit_comparison <- bind_rows(
  glance_age_quad %>% mutate(model = "Quadratic (degree 2)"),
  glance_age_overfit %>% mutate(model = "Overfit (degree 10)")
) %>%
  select(model, r.squared, adj.r.squared, AIC, BIC)

overfit_comparison

# --------------------------------------------------------
# END OF SCRIPT
# --------------------------------------------------------
