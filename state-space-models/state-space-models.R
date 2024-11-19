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

# plotting position, velocity and acceleration
# Set up a plotting area with 3 rows and 1 column for multiple plots
par(mfrow = c(3, 1))
# Plot position data (x) as a line chart
plot(x, main = "Position",     type = 'l')
# Plot velocity data (v) as a line chart
plot(v, main = "Velocity",     type = 'l')
# Plot acceleration data (a) as a line chart
plot(a, main = "Acceleration", type = 'l')

# Reset the plotting area to a single plot
par(mfrow = c(1, 1))
# Generate a noisy version of x by adding random noise
z <- x + rnorm(ts.length, sd = 300)
# Plot the original position data (x) with an appropriate y-axis range to include z
plot(x, ylim = range(c(x, z)))
# Overlay the noisy version (z) as a line on the same plot
lines(z)

# Define a Kalman filter function for linear motion
kalman.motion <- function(z, Q, R, A, H) {
  
  # Q: Process noise covariance matrix
  # R: Measurement noise covariance matrix
  # A: State transition matrix
  # H: Observation matrix
  # z: Observations (measurements)
  
  # Get the dimension of the state vector
  dimState <- dim(Q)[1]  # Number of state variables
  
  # Initialize arrays for storing the Kalman filter outputs
  # Predicted state (prior estimate) for each time step
  xhatminus <- array(rep(0, ts.length * dimState), c(ts.length, dimState))
  
  # Updated state (posterior estimate) for each time step
  xhat <- array(rep(0, ts.length * dimState), c(ts.length, dimState))
  
  # Predicted covariance (prior covariance) for each time step
  Pminus <- array(rep(0, ts.length * dimState * dimState), c(ts.length, dimState, dimState))
  
  # Updated covariance (posterior covariance) for each time step
  P <- array(rep(0, ts.length * dimState * dimState), c(ts.length, dimState, dimState))
  
  # Kalman gain for each time step
  K <- array(rep(0, ts.length * dimState), c(ts.length, dimState))
  
  # Initial state estimates are set to zero for all variables
  xhat[1, ] <- rep(0, dimState)  # Initial state estimate
  P[1, , ] <- diag(dimState)     # Initial covariance estimate (identity matrix)
  
  # Loop through time steps to perform the Kalman filter iterations
  for (k in 2:ts.length) {
    # Prediction (Time Update)
    # Predict the next state using the state transition matrix
    xhatminus[k, ] <- A %*% matrix(xhat[k-1, ])
    
    # Predict the next covariance using the process noise
    Pminus[k, , ] <- A %*% P[k-1, , ] %*% t(A) + Q
    
    # Calculate the Kalman gain
    K[k, ] <- Pminus[k, , ] %*% H %*% solve(t(H) %*% Pminus[k, , ] %*% H + R)
    
    # Update (Measurement Update)
    # Update the state estimate using the new measurement
    xhat[k, ] <- xhatminus[k, ] + K[k, ] %*% (z[k] - t(H) %*% xhatminus[k, ])
    
    # Update the covariance estimate
    P[k, , ] <- (diag(dimState) - K[k, ] %*% t(H)) %*% Pminus[k, , ]
  }
  
  # Return the smoothed and predicted state estimates
  return(list(xhat = xhat, xhatminus = xhatminus))
}

# Noise parameters
# Measurement variance - this value must be defined according to the limits
# Known physics of the measuring tool. We will define according to the 
# noise we add to 'x' to produce 'x' in data generation above 
# process variance, generally considered a hyperparameter to be 
# Tuned in order to maximize performance
R <- 10 ^ 2 
Q <- 10

# Parâmetros dinâmicos
A <- matrix(1) ## x_t = A * x_t-1 (how prior x affects later x)
H <- matrix(1) ## y_t = H * x_t   (translating state to measurement)

# Running the data through the Kalman filtering method
t <- kalman.motion(z, diag(1) * Q, R, A, H)[[1]]

# plotting t
# Assuming that the following vectors are already defined:
# - x: true position
# - z: measured position (with noise)
# - t: estimated position (Kalman filter result)

# Configure the range for the chart to include all series
plot_range <- range(c(x, z, t))

# Create the base graph with the true position
plot(x, type = "l", col = "blue", lwd = 2, ylim = plot_range, 
     main = "Position: True, Measured and Estimated",
     xlab = "Time", ylab = "Position")

# Add the measured position (with noise)
lines(z, col = "red", lwd = 2, lty = 2)

# Add estimated position (after Kalman filter)
lines(t, col = "green", lwd = 2, lty = 3)

# Add caption
legend("topright", legend = c("Verdadeira", "Medida", "Estimada"), 
       col = c("blue", "red", "green"), lty = c(1, 2, 3), lwd = 2)
