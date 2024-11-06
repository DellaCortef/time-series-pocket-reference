# Statistical Models for Time Series

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Load and structure the data
demand <- read.csv("daily_demand_forecasting_orders.csv", sep=";")

## plotting the data in chronological order
plot(demand[, 'Fiscal.sector.orders'], type = 'b')
acf(y2)
pacf(y2)