# Install packages
install.packages("ggplot2")
install.packages("remotes")
install.packages("devtools")
install.packages("pageviews")
installed.packages()["prophet", ]
install.packages("AnomalyDetection")
install.packages("prophet", dependencies=TRUE)
remotes::install_github("twitter/AnomalyDetection")

11# Load packages
library(ggplot2)
library(prophet)
library(pageviews)
library(AnomalyDetection)

df_wiki = article_pageviews(project   = "en.wikipedia",
                            article   = "Facebook",
                            start     = as.Date('2015-11-01'),
                            end       = as.Date('2018-11-02'),
                            user_type = c("user"),
                            platform  = c("mobile-web"))

colnames(df_wiki)                            

## We divide the data according to what we need and provide them with the 
## expected column names
df = df_wiki[, c("date", "views")]
colnames(df) = c("ds", "y")

## We also use the logarithmic transformation, because the data changes so much 
## extremes in values that large values divide the normal variation
df$y = log(df$y)

## We will create a 'future' data frame that includes the future dates we would like 
## to predict
m = prophet(df)
future <- make_future_dataframe(m, periods = 365)
tail(future)

## We will generate the forecast for the dates of interest
forecast <- predict(m, future)
tail(forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')])

## Now that we have predictions for our value of interest
## Finally, we will plot a graph to see how the package is evaluated qualitatively
plot(df$ds, df$y, col = 1, type = 'l', xlim = range(forecast$ds), 
     main = "Actual and predicted Wikipedia pageviews of 'Facebook'")
points(forecast$ds, forecast$yhat, type = 'l', col = 2)

prophet_plot_components(m, forecast)

data("raw_data")
head(raw_data)

# Check if the Function Exists
exists("AnomalyDetectionTs", where = "package:AnomalyDetection")

## Detects a high percentage of anomalies in any direction
general_amons <- AnomalyDetectionTs(raw_data, max_anoms = 0.4, direction = 'both')

## Detecta uma porcentagem menor de anomalias apenas na direção pos
high_amons <- AnomalyDetectionTs(raw_data, max_anoms = 0.4, direction = 'both')

# Check the Anomaly Column Names
colnames(general_amons$anoms)

# Plotting the graphs
## Extract anomalies and rename columns if necessary
anomalies_general <- general_amons$anoms

## Ensure column names match raw_data
colnames(anomalies_general) <- colnames(raw_data)

## Create time series plot
ggplot(raw_data, aes(x = timestamp, y = count)) +
  geom_line(color = "blue") +  # Plot the time series
  geom_point(data = anomalies_general, aes(x = timestamp, y = count), 
             color = "red", size = 3) +  # Highlight anomalies
  labs(title = "Anomaly Detection (5% anomalies, both directions)",
       x = "Timestamp", y = "Count") +
  theme_minimal()

