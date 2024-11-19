# State Space Models for Time Series

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Installing packages


# Loading packages


# rocket will take 100 time slots
ts.length <- 100

# acceleration will drive movement
a <- rep(0.5, ts.length)

# position and velocity start at 0
x <- rep(0, ts.length)
v <- rep(0, ts.length)
for (ts in 2:ts.length) {
  x[ts] <- v[ts - 1] * 2 + x[ts - 1] + 1/2 * a[ts - 1] ^2
  # stochastic component
  x[ts] <- x[ts] + rnorm(1, sd = 20) 
  v[ts] <- v[ts - 1] + 2 * a[ts - 1]
}
