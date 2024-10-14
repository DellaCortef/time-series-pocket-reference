# Exploratory Data Analysis

### Known Methods

#### Data exploration techniques typically used on **time series** datasets. 
#### The process is the same as that used for data that are not time series 
#### (for example, cross-sectional data). We would like to know the available 
#### columns, their value ranges, and which logical units of measurement 
#### work best.

#### Questions to ask:
  #### Are there strong correlations between the columns? Which?
  #### What is the overall mean of a relevant variable? What is your variance?
  #### What is the range of values we perceive? Do they vary by time period 
  #### or other logical unit of analysis?
  #### Does the data seem consistent and measured in a uniform way, or does it 
  #### suggest changes in measurement or behavior over time?
  
#### To answer the questions, we can use known techniques, such as:
  #### plotting;
  #### statistical synthesis;
  #### histograms;
  #### scatter plots;

#### To answer all these questions, it is necessary that the methods mentioned 
#### above take the temporal axis into account. And to implement this behavior, 
#### we will incorporate time into our statistics as an axis in our graphs or 
#### as *group by* operations.


#____________________________________*****____________________________________#

### Graphs and Plots

## dataset with daily closing prices of the four main European stock market 
## indices from 1991 to 1998
head(EuStockMarkets)

## plotting time series
plot(EuStockMarkets)

## Note that the image is automatically segmented into different time series. 
## This occurs because we are using an *mts* object from **R**. If there was 
## only one time series in the dataset, it would be a *ts* object

## *ts* dataset objects:

## *frequency* to find out the annual frequency of the data
frequency(EuStockMarkets)

## *start* and *end* to find the first and [last time represented
start(EuStockMarkets)

end(EuStockMarkets)

## *window* to get a temporal section of the data
window(EuStockMarkets, start = 1997, end = 1998)


### Histograms

## standard histogram
hist(     EuStockMarkets[, "SMI"], 30)

## histogram with time axis
hist(diff(EuStockMarkets[, "SMI"], 30))

## In **time series**, a *hist()* of the data difference is usually more 
## interesting than a *hist()* of the untransformed data. After all, in 
## **time series**, the most interesting thing is how the value changes from 
## one measurement to the next instead of changing to the actual measurement 
## of that same value. 
## This is even more true for plotting, as taking the histogram of data with a 
## trend does not generate a very informative visualization.


### Scatter Plots
### The traditional method of using scatter plots is just as advantageous for 
### **time series** data as it is for other types of data. We can use scatter 
### plots to determine how two stocks are linked at a specific time and how 
### their price changes are related over time.

## values of two different stocks over time
plot(     EuStockMarkets[, "SMI"],      EuStockMarkets[, "DAX"])

## values of daily changes in relation to these variables
plot(diff(EuStockMarkets[, "SMI"]), diff(EuStockMarkets[, "DAX"]))


### As we have seen, the actual values are less informative than the differences 
### between adjacent time points, so we plot the differences on a second 
### scatterplot. The supposed correlations above are interesting, but we must 
### consider that when a stock is rising or falling, the other shares with which 
### it is correlated will also be, since we are making correlations of values 
### at identical points of time. What we need to do is find out whether the 
### earlier change in timing of one action can predict the later change in 
### timing of another action. To do this, we will set back one of the stock 
### differences by 1 before analyzing the scatter plot

## The *lag()* function is a time jump into the future
plot(lag(diff(EuStockMarkets[, "SMI"]), 1), 
         diff(EuStockMarkets[, "DAX"]))

## We can see when analyzing the graph above that the correlations between 
## shares disappear as soon as we insert a *lag* of time, indicating that the 
## **SMI** does not seem to predict the **DAX**

## That is, it is the relationship between data at different points or change 
## over time that tells you more about how your data behaves



#____________________________________*****____________________________________#

### Time Series Specific Exploratory Methods

### Several time series data analysis methods focus on the relationships of 
### values at different times in the same series

### Concepts

#### Seasonality
  #### what does it mean for a time series to be stationary and a statistical test for stationarity

#### Self-correlation
  #### what it means to say that a time series correlates with itself and what this correlation indicates about the underlying dynamics of the time series

#### Spurious correlations
  #### What does a spurious correlation mean and how can we find it


### The first thing we can ask about a **time series** is whether it depicts a 
### "stable" system or one that is constantly changing. It is essential to 
### assess the level of stability or *stationarity*, as we need to know how past 
### behavior throughout the system reflects long-term future behavior. After 
### analyzing the "stability" of a **time series**, we will try to identify 
### whether there are internal dynamics in that series (i.e. seasonal changes). 
### We will be looking for *self-correlations* to answer the question: how 
### accurately does past data, whether distant or recent, predict future data? 
### Finally, when we encounter certain behavioral dynamics within the system, we 
### need to make sure that we are not identifying relationships based on 
### dynamics that do not in any way involve the causal relationships we want to 
### discover; therefore, we must look for *spurious correlations*.


################################# Stationarity ################################

### In short, a *stationary* **time series** has reasonably stable statistical 
### properties over time, especially with regard to mean and variance.

### However, stationarity is a misleading concept, especially when applied to 
### real **time series** data. As it is intuitive and we are easily mistaken, we 
### naturally trust it. So, before we see a usual stationarity test and the 
### practical details of how to apply this concept, we must analyze the **time 
### series** intuitively and formally.

#### Intuition
  #### A *stationary* **time series** is one whose measurement reflects a system 
  #### in a stable state. We can visually analyze whether the average is 
  #### increasing/decreasing, the distance between the peak-valley oscillations 
  #### (as well as the variance of the process), or whether the **time series** 
  #### presents a strong seasonal behavior in relation to the data distributed 
  #### in the analyzed period.

## installing libs
install.packages("zoo")
install.packages("dplyr")
install.packages("forecast")
install.packages("tidyverse")

library(zoo)
library(dplyr)
library(forecast)
library(tidyverse)

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Load and structure the data
air <- read.csv("AirPassengers.csv", sep=";")
ts_data <- ts(air, start=c(1949, 1), frequency=12)

# Decompose the series
decomposed_data <- decompose(ts_data, type="multiplicative")

# Visualize the decomposition
autoplot(decomposed_data) + labs(title="Time Series Decomposition")


### Using Window Functions

############################### Rolling windows ###############################
#### A common and distinct function in **time series** is a window function: any 
### type of function where you aggregate data to compress it or to smooth it.

#### In addition to the uses already discussed, smoothed data and 
#### window-aggregated data provide informative exploratory visualizations. We 
#### can calculate a moving average and do other linear function calculations 
#### for a series of points with the *filter()* function:

## calculates a moving average
## filter function
x <- rnorm(n = 100, mean = 0, sd = 10) + 1:100
df_x <- data.frame(x)
mn <- function(n) rep(1/n, n)

plot(x, type = 'l',               lwd = 1)
lines(filter(df_x, mn(1  )), col = 2, lwd = 3, lty = 2)
lines(filter(df_x, mn(100)), col = 3, lwd = 3, lty = 3)

## custom functions
require(zoo)

f1 <- rollapply(zoo(x), 20, function(w) min(w),
                align = "left", partial = TRUE)

f2 <- rollapply(zoo(x), 20, function(w) min(w),
                align = "right", partial = TRUE)

plot(x,            lwd = 1,          type = 'l')
lines(f1, col = 2, lwd = 3, lty = 2)
lines(f2, col = 3, lwd = 3, lty = 3)


############################## Expanding windows ###############################
### Expanding windows has a more restricted use. They only make sense in cases 
### where we are estimating a statistical synthesis that is believed to be a 
### stable process, rather than evolving over time or fluctuating significantly. 
### An epansion window starts with a certain minimum size, but as it progresses 
### through the **time series**, it expands to include all points up to a 
### certain time, rather than only a finite, constant size.

### An expanding window provides greater certainty in your estimation of test 
### statistics over the long term, enabling you to benefit from going "deeper" 
### into a specific time series. However, it only works if you assume that your 
### underlying system is stationary. This type of window can help keep 
### statistical summaries “online” as we estimate in real time as we gather more 
### information.

## expanding window
plot(x, type = 'l', lwd = 3)
lines(cummax(x),             col = 2, lwd = 3, lty = 2) # max
lines(cumsum(x)/1:length(x), col = 3, lwd = 3, lty = 3) # mean





























































