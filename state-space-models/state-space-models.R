# State Space Models for Time Series

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Installing packages
install.packages("bsts")
install.packages("igraph")
install.packages("depmixS4")
install.packages("data.table")

# Loading packages
library(bsts)
library(igraph)
library(depmixS4)
library(data.table)

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
legend("topright", legend = c("True", "Measured", "Estimated"), 
       col = c("blue", "red", "green"), lty = c(1, 2, 3), lwd = 2)

# Viterbi Algorithm example
# Define HMM parameters
states <- c("Rainy", "Sunny")
observations <- c("Walk", "Shop", "Clean")
start_probs <- c(0.6, 0.4)  # Start probabilities
transition_probs <- matrix(c(0.7, 0.3, 0.4, 0.6), nrow = 2, byrow = TRUE,
                           dimnames = list(states, states))
emission_probs <- matrix(c(0.1, 0.4, 0.5, 0.6, 0.3, 0.1), nrow = 2, byrow = TRUE,
                         dimnames = list(states, observations))
obs_seq <- c("Walk", "Shop", "Clean")  # Observation sequence

# Viterbi Algorithm
viterbi <- function(obs_seq, states, start_probs, transition_probs, emission_probs) {
  n_obs <- length(obs_seq)
  n_states <- length(states)
  
  # Initialize matrices for probabilities and paths
  v <- matrix(0, nrow = n_states, ncol = n_obs)
  path <- matrix(0, nrow = n_states, ncol = n_obs)
  
  # Initialization step
  for (i in 1:n_states) {
    v[i, 1] <- start_probs[i] * emission_probs[i, obs_seq[1]]
    path[i, 1] <- i
  }
  
  # Recursion step
  for (t in 2:n_obs) {
    for (i in 1:n_states) {
      probs <- v[, t - 1] * transition_probs[, i] * emission_probs[i, obs_seq[t]]
      v[i, t] <- max(probs)
      path[i, t] <- which.max(probs)
    }
  }
  
  # Termination step
  final_state <- which.max(v[, n_obs])
  most_probable_path <- numeric(n_obs)
  most_probable_path[n_obs] <- final_state
  
  for (t in (n_obs - 1):1) {
    most_probable_path[t] <- path[most_probable_path[t + 1], t + 1]
  }
  
  return(states[most_probable_path])
}

# Run the Viterbi algorithm
obs_indices <- match(obs_seq, observations)  # Convert obs_seq to indices
result <- viterbi(obs_indices, states, start_probs, transition_probs, emission_probs)
print(result)  # Most probable state sequence

# Plot the observation and hidden states
plot_states <- function(obs_seq, states_seq) {
  time_steps <- seq_along(obs_seq)
  plot(time_steps, rep(1, length(obs_seq)), type = "n", xaxt = "n", yaxt = "n",
       xlab = "Time", ylab = "State/Observation", ylim = c(0.5, 2.5))
  axis(1, at = time_steps, labels = time_steps)
  axis(2, at = c(1, 2), labels = c("Observation", "State"))
  
  # Add observation labels
  text(time_steps, rep(1, length(obs_seq)), labels = obs_seq, col = "blue", cex = 1.2)
  
  # Add state labels
  text(time_steps, rep(2, length(states_seq)), labels = states_seq, col = "red", cex = 1.2)
  
  # Connect observations and states
  for (i in time_steps) {
    arrows(i, 1.2, i, 1.8, col = "gray", lty = 2)
  }
}

plot_states(obs_seq, result)

# Improved Plot Function
plot_states <- function(obs_seq, states_seq) {
  time_steps <- seq_along(obs_seq)
  
  # Plot observations as a time series
  plot(time_steps, rep(1, length(obs_seq)), type = "b", col = "blue", lwd = 2, 
       xlab = "Time", ylab = "State/Observation", ylim = c(0.5, 2.5),
       main = "Time Series: Observations and Hidden States", pch = 16, xaxt = "n", yaxt = "n")
  
  # Customize axes
  axis(1, at = time_steps, labels = paste("Day", time_steps))
  axis(2, at = c(1, 2), labels = c("Observation", "State"))
  
  # Add state sequence as a time series
  points(time_steps, rep(2, length(states_seq)), type = "b", col = "red", lwd = 2, pch = 17)
  
  # Add arrows to connect observations to states
  for (i in time_steps) {
    arrows(i, 1.2, i, 1.8, col = "gray", lty = 3)
  }
  
  # Add legend
  legend("top", legend = c("Observations", "Hidden States"), col = c("blue", "red"), 
         pch = c(16, 17), lty = 1, lwd = 2, bty = "n")
}

# Call the function with observation sequence and result
plot_states(obs_seq, result)

# Defining a seed
set.seed(123)

# Definition of parameters for the distribution of each state we want to represent
bull_mu <- 0.1
bull_sd <- 0.1

neutral_mu <- 0.02
neutral_sd <- 0.08

bear_mu <- 0.03
bear_sd <- 0.2

panic_mu <- 0.1
panic_sd <- 0.3

# Collecting these parameters into vectors to facilitate indexing
mus <- c(bull_mu, neutral_mu, bear_mu, panic_mu)
sds <- c(bull_sd, neutral_sd, bear_sd, panic_sd)

# Defining some constants to represent the time series we will generate
NUM.PERIODS     <- 10
SMALLEST.PERIOD <- 20
LONGEST.PERIOD  <- 40

# Stochastically determining a series of day counts
days <- sample(SMALLEST.PERIOD:LONGEST.PERIOD, NUM.PERIODS, replace = TRUE)

# For each number of days in the vector, we will generate a time series for a given market state
returns   <- numeric()
true.mean <- numeric()
for (d in days) {
  idx = sample(1:4, 1, prob = c(0.2, 0.6, 0.18, 0.02))
  returns <- c(returns, rnorm(d, mean = mus[idx], sd = sds[idx]))
  true.mean <- c(true.mean, rep(mus[idx], d))
}

# Frequency of each state
table(true.mean)

# Create a data frame for the frequency table
freq_table <- data.frame(
  true.mean = c(0.02, 0.03, 0.10),
  Frequency = c(142, 66, 111)
)

# Display the table with knitr::kable
knitr::kable(freq_table, caption = "Frequency Table of true.mean")

# tunning HMM explanation
hmm.model  <- depmix(returns ~ 1, family = gaussian(),
                    nstates = 4, data=data.frame(returns=returns))
model.fit  <- fit(hmm.model)
post_probs <- posterior(model.fit)

# Visualizing the states with the measured values
plot(returns, type = 'l', lwd = 3, col = 1, 
     yaxt = "n", xaxt = "n", ylab = "",
     ylim = c(-0.6, 0.6))

# Example setup for the plot
plot(1:length(returns), type = "n", ylim = c(-1, 1), xlab = "Time", ylab = "Returns")

# Ensure 'post_probs$state' contains valid values for alpha (0-1 range)
lapply(0:(length(returns) - 1), function(i) {
  ## Add a rectangle with the appropriate background color to indicate the state during the interval
  rect(i, -0.6, i + 1, 0.6,
       col = rgb(0.0, 0.0, 0.0, alpha = 0.2 * post_probs$state[i + 1]),
       border = NA)
})

# Extracts the "response" attribute from the model.fit object, which contains the fitted sub-models for each hidden state.
attr(model.fit, "response")