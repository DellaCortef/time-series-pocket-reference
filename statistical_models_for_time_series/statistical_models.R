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
