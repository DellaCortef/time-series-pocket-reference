# Install packages
install.packages("ISOweek")
install.packages("forecast")
install.packages("data.table")

# Load the package
library(forecast)

# Load packages
library(ISOweek)
library(data.table)

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Read the Flu CSV using fread
flu <- fread("flu_train.csv")

# Ensure flu is a data.table
setDT(flu)  # Converts flu to data.table in-place

# Replace non-numeric values in TauxGrippe before conversion
flu[, TauxGrippe := as.character(TauxGrippe)]  # Ensure it's character
flu[TauxGrippe %in% c("", "NA", "unknown", "-"), TauxGrippe := NA]  # Replace invalid entries with NA

# Convert to numeric and store as flu.rate
flu[, flu.rate := as.numeric(TauxGrippe)]

# Replace NAs in flu.rate with 0 (if needed)
flu[is.na(flu.rate), flu.rate := 0]

# Print summary to check
summary(flu$flu.rate)

head(flu)

# NA checking
nrow(flu[is.na(flu.rate)]) / nrow(flu)

# Get unique region names where flu.rate is NA
unique(flu[is.na(flu.rate)]$region_name)  

# Extract year from 'week' column
flu[, year := as.numeric(substr(week, 1, 4))]  

# Extract week number from 'week' column
flu[, wk   := as.numeric(substr(week, 5, 6))]  

# Convert ISO week format to date
flu[, date := ISOweek2date(paste0(substr(as.character(week), 1, 4), "-W", 
                                  substr(as.character(week), 5, 6), "-1"))]  

# Filter data for Paris region
paris.flu = flu[region_name == "ILE-DE-FRANCE"]  

# Order data by date in ascending order
paris.flu = paris.flu[order(date, decreasing = FALSE)]  

# Select specific columns: week, date, flu rate
paris.flu[, .(week, date, flu.rate)]  

# Count number of entries per year
paris.flu[, .N, year]  

# Plot flu rate over time
paris.flu[, plot(date, flu.rate, 
                 type = "l", xlab = "Date", 
                 ylab = "Flu rate")]  

# Remove data for week 53
paris.flu <- paris.flu[week != 53]  

# Compute autocorrelation function (ACF) of flu rate
acf(paris.flu$flu.rate)  

# Compute ACF of flu rate with 52-week differencing
acf(diff(paris.flu$flu.rate, 52))  

# ACF with max lag of 104 weeks
acf(paris.flu$flu.rate, lag.max = 104)  

# ACF after seasonal differencing
acf(diff(paris.flu$flu.rate, 52), lag.max = 104)  

# Double seasonal differencing (52-week)
plot(diff(diff(paris.flu$flu.rate, 52), 52)) 

# Seasonal + first-order differencing
plot(diff(diff(paris.flu$flu.rate, 52), 1))  

# Set plotting area to 2 rows, 1 column
par(mfrow = c(2, 1)) 
# ACF of double differenced series
acf (diff(diff(paris.flu$flu.rate, 52), 1), lag.max = 104)  
# PACF of double differenced series
pacf(diff(diff(paris.flu$flu.rate, 52), 1), lag.max = 104)  

## ARIMA adjustment
## Let's estimate 2 weeks 1st time
first.fit.size <- 104  
# Forecast horizon of 2 weeks
h <- 2  
# Number of time steps for rolling forecast
n <- nrow(paris.flu) - h - first.fit.size  

# Fit SARIMA(2,1,0)(0,1,0)[52] model
first.fit <- arima(paris.flu$flu.rate[1:first.fit.size], order = c(2, 1, 0), 
                   seasonal = list(order = c(0, 1, 0), period = 52))  

# Get ARIMA order details
first.order <- arimaorder(first.fit)  

## Pre-allocate space for predictions and coefficients
# Array to store predictions
fit.preds <- array(0, dim = c(n, h))  
# Array to store model coefficients
fit.coefs <- array(0, dim = c(n, length(first.fit$coef)))  

## Iteratively fit ARIMA model for rolling forecasts
for (i in (first.fit.size + 1):(nrow(paris.flu) - h)) {
  # Expand training dataset
  data.to.fit = paris.flu[1:i]  
  fit = arima(data.to.fit$flu.rate, order = first.order[1:3],
              # Refit ARIMA model
              seasonal = first.order[4:6])  
  # Store forecast
  fit.preds[i - first.fit.size, ] <- forecast(fit, h = 2)$mean  
  # Store model coefficients
  fit.preds[i - first.fit.size, ] <- fit$coef  
}

# Define y-axis range for plotting
ylim <- range(paris.flu$flu.rate[300:400], 
              fit.preds[, h][(300-h):(400-h)])  

# Reset plotting layout
par(mfrow = c(1, 1))  
plot(paris.flu$date[300:400], paris.flu$flu.rate[300:400], 
     ylim = ylim, cex = 0.8, 
     main = "Actual and predicted flu with SARIMA (2, 1, 0), (0, 1, 0)", 
     xlab = "Date", ylab = "Flu rate")  # Plot actual flu rate

# Add SARIMA predictions
lines(paris.flu$date[300:400], fit.preds[, h][(300-h):(400-h)], 
      col = 2, type = "l", lty = 2, lwd = 2)  

## Pre-allocate vectors for coefficients and predictions
# Reset prediction array
fit.preds       <- array(0, dim = c(n, h))  
# Reset coefficient array
fit.coefs       <- array(0, dim = c(n, 100))  

## Convert flu rates to time series with Fourier terms
# Log transformation with small offset
flu.ts          <- ts(log(paris.flu$flu.rate + 1) + 0.0002, frequency = 52)  


## Generate exogenous regressors using Fourier series
# Fourier terms for seasonality
exog.regressors <- fourier(flu.ts, K = 2)  
# Store column names of Fourier regressors
exog.colnames   <- colnames(exog.regressors)  

## Rolling ARIMA model with Fourier regressors
for (i in (first.fit.size + 1):(nrow(paris.flu) - h)) {
  # Subset data
  data.to.fit       <- ts(flu.ts[1:i], frequency = 52)  
  # Subset exogenous regressors
  exogs.for.fit     <- exog.regressors[1:i,]  
  # Get future exog regressors
  exogs.for.predict <- exog.regressors[(i + 1):(i + h),]  
  
  # Fit ARIMA model with exog regressors
  fit <- auto.arima(data.to.fit,
                    xreg = exogs.for.fit,
                    seasonal = FALSE)  
  
  # Store coefficients
  fit.preds[i - first.fit.size, ] <- forecast(fit, h = h,
                                              xreg = exogs.for.predict)$mean  # Store predictions
  fit.coefs[i - first.fit.size, 1:length(fit$coef)] = fit$coef  
}

# Recalculate flu time series
flu.ts = ts(log(paris.flu$flu.rate + 1) + 0.0001, frequency = 52)  
# Fit final ARIMA model
fit <- auto.arima(data.to.fit, xreg = exogs.for.fit, seasonal = FALSE)  

# Store final prediction
fit.preds[i - first.fit.size, ] <- forecast(fit, h = h,
                                            xreg = exogs.for.predict)$mean  

# Set y-axis range
ylim = range(paris.flu$flu.rate)  
plot(paris.flu$date[300:400], paris.flu$flu.rate[300:400], 
     ylim = ylim, cex = 0.8,
     main = "Actual and predicted flu with ARIMA + harmonic regressors",
     xlab = "Date", ylab = "Flu rate")  # Plot actual flu rate

# Plot predicted flu rate with exponentiation
lines(paris.flu$date[300:400], exp(fit.preds[, h][(300-h):(400-h)]),
      lty = 2, lwd = 2)  

# Filter test data from week 201300 onward
test <- flu[week >= 201300]  
# Plot test flu rates
plot(test$flu.rate)  

# Identify weeks with extremely high flu rates
which(test$flu.rate > 1000)  
# Add vertical line at index 984
abline(v = 984)  
# Find index of maximum flu rate
which.max(test$flu.rate)  
# Add vertical line at index 1050
abline(v = 1050)  