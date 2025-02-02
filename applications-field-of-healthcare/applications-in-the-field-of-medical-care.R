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
h              <- 2
n              <- nrow(paris.flu) - h - first.fit.size

## Gets the default dimensions for fits that we will produce
## and related information such as coefficients
first.fit <- arima(paris.flu$flu.rate[1:first.fit.size], order = c(2, 1, 0), 
                   seasonal = list(order = c(0, 1, 0), period = 52))
first.order <- arimaorder(first.fit)

## Pré-alocar espaço para armazenar nossas predições e coeficientes
fit.preds <- array(0, dim = c(n, h))
fit.coefs <- array(0, dim = c(n, length(first.fit$coef)))

## Após ajuste inicial, avançamos o ajuste uma semana de cada vez, cada vez 
## reajustando o modelo e salvando os novos coeficientes e a nova previsao
for (i in (first.fit.size + 1):(nrow(paris.flu) - h)) {
  ## predict for an increasingly large window
  data.to.fit = paris.flu[1:i]
  fit = arima(data.to.fit$flu.rate, order = first.order[1:3],
              seasonal = first.order[4:6])
  fit.preds[i - first.fit.size, ] <- forecast(fit, h = 2)$mean
  fit.preds[i - first.fit.size, ] <- fit$coef
}
