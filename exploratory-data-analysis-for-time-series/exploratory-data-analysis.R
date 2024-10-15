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
install.packages("data.table")

library(zoo)
library(dplyr)
library(forecast)
library(tidyverse)
library(data.table)

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Load and structure the data
air <- read.csv("AirPassengers.csv", sep=";")
ts_data <- ts(air, start=c(1949, 1), frequency=12)

# Decompose the series
decomposed_data <- decompose(ts_data, type="multiplicative")

# Visualize the decomposition
autoplot(decomposed_data) + labs(title="Time Series Decomposition")

#____________________________________*****____________________________________#
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


#____________________________________*****____________________________________#
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

## applying custom functions with rollapply():
plot(x, type = 'l', lwd = 1)
lines(rollapply(zoo(x), seq_along(x), function(w) max(w),
               partial = TRUE, align = "right"),
      col = 2, lwd = 3, lty = 2)
lines(rollapply(zoo(x), seq_along(x), function(w) mean(w),
                partial = TRUE, align = "right"),
      col = 3, lwd = 3, lty = 3)



#____________________________________*****____________________________________#
############################### Self-correlation ##############################

### The term self-correlation is, in essence, the idea that a value in a **time series** at a certain point in time can be correlated with the value at another point in time.

### Perhaps we will identify a possible fact about the system, indicating that 
### there is long-term predictability. On the other hand, we can find the 
### correlation close to zero, where you will also have found something 
### interesting.


### Autocorrelation function

### Autocorrelation is the correlation of a signal with a delayed copy of 
### itself. Informally, it is the similarity between observations as a function 
### of the time lag between them.

### Autocorrelation gives an idea of how data points at different points in time 
### are linearly related to each other as a function of their time difference.

## autocorrelation
x <- 1:100
y <- sin(x * pi/3)

plot(y, type = 'b')
acf(y)

## calculating ACF using **data.table**'s *shift()* function
cor(y, shift(y, 1), use = "pairwise.complete.obs")

cor(y, shift(y, 2), use = "pairwise.complete.obs")


#____________________________________*****____________________________________#
### Partial autocorrelation function

### The partial autocorrelation of a **time series** for a given lag is the 
### partial correlation of that time series with itself at that lag, given all 
### the information between the two points in time. It means we need to 
### calculate a series of conditional correlations and subtract them from the 
### total correlation. Calculating PACF is not that simple and there are a 
### variety of methods to estimate it.

y <- sin(x * pi/3)
plot(y[1:30], type = 'b')
pacf(y)

#### In the case of a sinusoidal series, the PACF function diverges remarkably 
#### from an ACF function. PACF shows which data points are informative and 
#### which are harmonic points over shorter time periods.

#### In a seasonal, noiseless process such as the sine function with period T, 
#### the same ACF value will be seen at T, T2, T3, and so on to infinity. An ACF 
#### cannot eliminate these redundant correlations. In contrast, PACF reveals 
#### which correlations are "true" informative correlations for specific lags, 
#### rather than redundancies. This is invaluable because when we collect enough 
#### information, we can get a long enough window on a time scale that suits our 
#### data.


#____________________________________*****____________________________________#
### Let's look at a more complex example. Let's consider the sum of two sine 
### curves under the following conditions:
  #### no noise;
  #### low noise;
  #### high noise.

#### No noise
y1 <- sin(x * pi/3)
plot(y1, type = 'b')
acf(y1)
pacf(y1)

y2 <- sin(x * pi/10)
plot(y2, type = 'b')
acf(y2)
pacf(y2)

## combining the two series by adding them
y <- y1 + y2
plot(y, type = 'b')
acf(y)
pacf(y)

## As we can see, our ACF graph is consistent with the previously mentioned 
## properties: the ACF sum of two **time series** is the sum of the individual 
## ACFs. We can clearly see this through 
## the positive -> negative -> positive -> negative sections of the ACF 
## correlated with the slower oscillations of the function.

## The PACF is not a direct sum of the PACF functions of the individual 
## components. It is simple to understand a PACF after calculating it, but 
## generating or predicting it is more difficult. This PACF function indicates 
## that partial autocorrelation is more substantial in the summed series than in 
## any of the original series. In other words, the correlation between points 
## separated by a certain lag, when calculating the values of the points between 
## them, is more informative in the summed series than in the original. This is 
## related to the two different periods of the series, resulting in any point 
## being less determined by the values of neighboring points as the location 
## within the cycle of the two periods becomes less fixed as the oscillations 
## continue at different frequencies.


#### Low noise
noise1 <- rnorm(100, sd = 0.05)
noise2 <- rnorm(100, sd = 0.05)

w1 <- y1 + noise1
w2 <- y2 + noise2
w <- w1 + w2

plot(w1, type = 'b')
acf(w1)
pacf(w1)

plot(w2, type = 'b')
































































