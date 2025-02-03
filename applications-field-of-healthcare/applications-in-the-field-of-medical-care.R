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

unique(flu[is.na(flu.rate)]$region_name)

flu[, year := as.numeric(substr(week, 1, 4))]
flu[, wk   := as.numeric(substr(week, 5, 6))]

flu[, date := ISOweek2date(paste0(substr(as.character(week), 1, 4), "-W", substr(as.character(week), 5, 6), "-1"))]

# Lets focus on Paris
paris.flu = flu[region_name == "ILE-DE-FRANCE"]
paris.flu = paris.flu[order(date, decreasing = FALSE)]

paris.flu[, .(week, date, flu.rate)]

paris.flu[, .N, year]

paris.flu[, plot(date, flu.rate,
                 type = "l", xlab = "Date",
                 ylab = "Flu rate")]

paris.flu <- paris.flu[week != 53]           

acf(paris.flu$flu.rate,        )
acf(diff(paris.flu$flu.rate, 52))

acf(paris.flu$flu.rate,         , lag.max = 104)
acf(diff(paris.flu$flu.rate, 52), lag.max = 104)

plot(diff(diff(paris.flu$flu.rate, 52), 52))
plot(diff(diff(paris.flu$flu.rate, 52),  1))

par(mfrow = c(2, 1))
acf (diff(diff(paris.flu$flu.rate, 52), 1), lag.max = 104)
pacf(diff(diff(paris.flu$flu.rate, 52), 1), lag.max = 104)

## Arima adjustment
## Let's estimate 2 weeks 1st time
first.fit.size <- 104
h <- 2
n <- nrow(paris.flu) - h - first.fit.size

## Gets the default dimensions for fits that we will produce
## and related information such as coefficients
first.fit <- arima(paris.flu$flu.rate[1:first.fit.size], order = c(2, 1, 0), 
                   seasonal = list(order = c(0, 1, 0), period = 52))
first.order <- arimaorder(first.fit)

## Pre-allocate space to store our predictions and coefficients
fit.preds <- array(0, dim = c(n, h))
fit.coefs <- array(0, dim = c(n, length(first.fit$coef)))

## After initial adjustment, we advance the adjustment one week at a time, each time 
## readjusting the model and saving the new coefficients and the new prediction
for (i in (first.fit.size + 1):(nrow(paris.flu) - h)) {
  ## predict for an increasingly large window
  data.to.fit = paris.flu[1:i]
  fit = arima(data.to.fit$flu.rate, order = first.order[1:3],
              seasonal = first.order[4:6])
  fit.preds[i - first.fit.size, ] <- forecast(fit, h = 2)$mean
  fit.preds[i - first.fit.size, ] <- fit$coef
}

ylim <- range(paris.flu$flu.rate[300:400],
              fit.preds[, h][(300-h):(400-h)])
par(mfrow = c(1, 1))
plot(paris.flu$date[300:400], paris.flu$flu.rate[300:400], 
     ylim = ylim, cex = 0.8, 
     main = "Actual and predicted flu with SARIMA (2, 1, 0), (0, 1, 0)", 
     xlab = "Date", ylab = "Flu rate")
lines(paris.flu$date[300:400], fit.preds[, h][(300-h):(400-h)], 
      col = 2, type = "l", lty = 2, lwd = 2)

## Pre-allocate vectors to maintain coefficients and adjustments
fit.preds       <- array(0, dim = c(n, h))
fit.coefs       <- array(0, dim = c(n, 100))

## Exogenous regressors that are components of the Fourier series fitted to the data
flu.ts          <- ts(log(paris.flu$flu.rate + 1) + 0.0002, frequency = 52)

## Add small offsets as small values cause problems
exog.regressors <- fourier(flu.ts, K = 2)
exog.colnames   <- colnames(exog.regressors)

## Adjust the model again each week with the expansion window
## of training data
for (i in (first.fit.size + 1):(nrow(paris.flu) - h)) {
  data.to.fit       <- ts(flu.ts[1:i], frequency = 52)
  exogs.for.fit     <- exog.regressors[1:i,]
  exogs.for.predict <- exog.regressors[(i + 1):(i + h),]
  
  fit <- auto.arima(data.to.fit,
                    xreg = exogs.for.fit,
                    seasonal = FALSE)
  
  fit.preds[i - first.fit.size, ] <- forecast(fit, h = h,
                                              xreg = exogs.for.predict)$mean
  fit.coefs[i - first.fit.size, 1:length(fit$coef)] = fit$coef 
}

flu.ts = ts(log(paris.flu$flu.rate + 1) + 0.0001,
            frequency = 52)
fit <- auto.arima(data.to.fit, xreg = exogs.for.fit, seasonal = FALSE)

fit.preds[i - first.fit.size, ] <- forecast(fit, h = h,
                                            xreg = exogs.for.predict)$mean

ylim = range(paris.flu$flu.rate)
plot(paris.flu$date[300:400], paris.flu$flu.rate[300:400], 
     ylim = ylim, cex = 0.8,
     main = "Actual and predicted flu with ARIMA + harmonic regressors",
     xlab = "Date", ylab = "Flu rate"
     )
lines(paris.flu$date[300:400], exp(fit.preds[, h][(300-h):(400-h)]),
      lty = 2, lws = 2)

test <- flu[week >= 201300]
plot(test$flu.rate)
which(test$flu.rate > 1000)
abline(v = 984)
which.max(test$flu.rate)
abline(v = 1050)
