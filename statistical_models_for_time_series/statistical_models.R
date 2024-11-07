# Statistical Models for Time Series

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Load and structure the data
demand <- read.csv("daily_demand_forecasting_orders.csv", sep=";")

# Choosing one columns
demand_banking <- demand[, 'Banking.orders..2.']

## plotting the data in chronological order
plot(demand_banking, type = 'b')
acf(demand_banking)
pacf(demand_banking)

## applying ar() function
fit <- ar(demand_banking, method = "mle")
fit

## applying arima() function to adjust ar()
est <- arima(x = demand_banking, order = c(3, 0, 0))
est

## applying arima() function with knowledge
est.1 <- arima(x = demand_banking, order = c(3, 0, 0), 
               fixed = c(0, NA, NA, NA), transform.pars = FALSE)
est.1

## plotting residuals ACF
acf(est.1$residuals)

## applying box-ljung test
Box.test(est.1$residuals, lag = 10, type = 'Ljung', fitdf = 3)

## plotting the forecast one step ahead
require(forecast)
plot(demand_banking, type = 'l')
lines(fitted(est.1), col = 3, lwd = 2) # using forecast package

## multi-step ahead forecasting
var(fitted(est.1, h = 3), na.rm = TRUE) # it down not work

## type of the object
class(est.1)

## inspecting the contents
str(est.1)

# Remove NA values (if any)
est.1 <- na.omit(est.1)

# Ensure it's purely numeric
est.1 <- as.numeric(est.1)
est.1 <- ts(est.1)  # Convert back to a time series if needed

# Try extracting the first element if it's a time series
est.1 <- est.1[[1]]

is.numeric(est.1)  # Should return TRUE
is.ts(est.1)       # Should return TRUE

## assuming est.1 is a time series (ts object)
arima_model <- auto.arima(est.1)

## three-step ahead forecasting
forecast_results <- forecast(arima_model, h = 3)
print(forecast_results)
