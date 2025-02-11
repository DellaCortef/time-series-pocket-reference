# Install packages
install.packages("pageviews")
installed.packages()["prophet", ]
install.packages("prophet", dependencies=TRUE)

# Load packages
library(prophet)
library(pageviews)

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

