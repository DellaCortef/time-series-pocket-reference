# CLEANING DATASETS

### missing data;
### frequency change of a time series (upsampling and downsampling);
### data smoothing;
### dealing with seasonality in data;
### prevention of unintentional lookaheads;

# Missing Data
### We will work with monthly unemployment data, freely available for download 
### (https://data.bls.gob/timeseries/LNS14000000), released by the US 
### government since 1948. We will then generate two sets of data from this 
### baseline data : one where the data is indeed randomly missing, and another 
### where it is the highest unemployment months in history.

#### Even if generalizing, we can see that missing data in time series are more 
### common than in cross-sectional data analyses, due to the burden of 
### longitudinal sampling being quite heavy: incomplete time series are quite 
### common. The most used methods are:
  ##### - imputation:
  #####   _ when we fill in missing data based on observations about the entire 
  #### data set;
  ##### - interpolation:
  #####   _ when we use neighboring data points in order to estimate the 
  #### missing value;
  ##### - exclusion of affected time periods:
  #####   _ when we choose not to use time periods that have missing data;


#____________________________________*****____________________________________#

# Imputations

## installing libs
install.packages("zoo")
install.packages("readr")
install.packages("rmarkdown")
install.packages("data.table")

## loading libs
library(readr)
library(data.table)

require(zoo)         ## the zoo provides the resources for time series
require(data.table)  ## 'data.table' is a high-performance dataframe

setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/getting-time-series-datasets/datasets/')

UNRATE <- read_csv("UNRATE.csv")
unemp  <- fread("UNRATE.csv")     
unemp[, DATE := as.Date(DATE)]
setkey(unemp, DATE)

## generating a dataset in which data is randomly missing
rand.unemp.idx <- sample(1:nrow(unemp), 1*nrow(unemp))
rand.unemp     <- unemp[-rand.unemp.idx]

## generating a dataset in which data has a higher probability of absence when unemployment is high
high.unemp.idx <- which(unemp$UNRATE > 8)
num.to.select  <- .2 * length(high.unemp.idx)
high.unemp.idx <- sample(high.unemp.idx,)
bias.unemp     <- unemp[-high.unemp.idx]


## Since we deleted rows from our data tables to create a dataset with missing data, we will need to read the missing dates and NA values. To do this, we will use the merge *rolling join* from the 'data.table' package
all.dates <- seq(from = unemp$DATE[1], to = tail(unemp$DATE, 1), by = "months")

## labeling missing data to plot it more easily
rand.unemp = rand.unemp[J(all.dates), roll = 0]
bias.unemp = bias.unemp[J(all.dates), roll = 0]
rand.unemp[, rpt := is.na(UNRATE)]

## Using *rolling join*, we generate the sequence of all dates that should be 
## available from start to finish. Now that we have a dataset with missing 
## values, let's look at some specific ways to fill numbers into these missing 
## values:
  ## forward fill method;
  ## moving average;
  ## interpolation;



### Foward Fill Method
## One of the simplest ways to fill in missing values ​​is by transferring the 
## last known value to the previous missing value, an approach known as 
## *forward fill*. Just take the data that was available and move forward in 
## time.

## We were able to apply the forward fill method using *na.locf* from 
## the **zoo** package

rand.unemp[, impute.ff := na.locf(UNRATE, na.rm = FALSE)]
bias.unemp[, impute.ff := na.locf(UNRATE, na.rm = FALSE)]

## To plot a sample graph that shows the flat parts
unemp[350:400, plot(DATE, UNRATE,
                    col = 1, lwd = 2, type = 'b')]

rand.unemp[350:400, lines(DATE, impute.ff,
                         col = 2, lwd = 2, lty = 2)]

rand.unemp[350:400][rpt == TRUE, points(DATE, impute.ff,
                                        col = 2, pch = 6, cex = 2)]

## Advantages of *forward fill*:
  ## it is not computationally demanding;
  ## can be easily applied to real-time data;
  ## does a decent job regarding imputation;


# Moving Average
### We can impute data with a moving average or median. *Moving average* is 
### similar to *forward fill* in that it uses past values to predict missing 
### future values (imputation can be a form of prediction). But with the moving 
### average, we can use inputs coming from *multiple* recent times in the past.

### There are several situations in which a moving average imputation is better 
### suited to the task at hand than a forward fill. For example, if the data is 
### noisy and we have reason to doubt the value of any individual data point 
### relative to an overall average, it is recommended to use a moving average 
### instead of forward fill. Forward fill can include more random noise than 
### the true metric we are interested in, while averaging can remove some of 
### that noise.

## moving average without lookahead
rand.unemp[, impute.rm.nolookahead := rollapply(c(NA, NA, UNRATE), 3,
                                                function(x) {
                                                  if (!is.na(x[3])) x[3] 
                                                  else mean(x, na.rm = TRUE)
                                                })]

bias.unemp[, impute.rm.nolookahead := rollapply(c(NA, NA, UNRATE), 3,
                                                function(x) {
                                                  if (!is.na(x[3])) x[3] 
                                                  else mean(x, na.rm = TRUE)
                                                })]
### We define the values of missing data with the average of the values that 
### come before them (because we index the final value and use it to determine 
### if it is missing and how to replace it).                                                

### If we are not worried about a lookahead, our best estimate will include 
### points before and after the missing daods, because this will maximize the 
### information that goes into our estimates. We can implement a *rolling 
### window*, as shown below with *rollapply()* from the **zoo** package

## moving average with lookahead
rand.unemp[, complete.rm := rollapply(c(NA, UNRATE, NA), 3, 
                                      function(x) {
                                        if (!is.na(x[2]))
                                          x[2]
                                        else
                                          mean(x, na.rm = TRUE)
                                      })]

### Using past and future information is convenient for visualizations and 
### record keeping in an application, but as mentioned previously, this is 
### not appropriate if you are preparing your data to feed into a 
### predictive model

### A moving average data imputation reduces data variance. This is something 
### we need to keep in mind when calculating model accuracy, the coefficient of 
### determination (**Rˆ2**), or other error metrics. Our calculation may 
### overestimate the performance of your model, a common problem when 
### building a time series model


#____________________________________*****____________________________________#

# Interpolation
### Interpolation is a method for determining values of missing data points 
### based on geometric constraints on how we want the data to behave. For 
### example, a linear interpolation constrains missing data to a linear fit 
### consistent with known neighboring points

### Linear interpolation is very useful and interesting because it allows you 
### to use your knowledge of how the system behaves over time. For example, if 
### you know that a system behaves linearly, we can architect things so that 
### only linear trends are used to impute missing data. As with a moving 
### average, interpolation can be done in a way that considers past and future 
### data or just one direction. Only allow your interpolation to access future 
### data if we accept that it creates a lookahead and are sure that it does not 
### pose a problem in our task


## Linear interpolation
rand.unemp[, impute.li := na.approx(UNRATE)]
bias.unemp[, impute.li := na.approx(UNRATE)]

## Polynomial interpolation
rand.unemp[, impute.sp := na.spline(UNRATE)]
bias.unemp[, impute.sp := na.spline(UNRATE)]

use.idx = 70:120
unemp[use.idx, plot(DATE, UNRATE, col = 1, type = 'b')]
rand.unemp[use.idx, lines(DATE, impute.li, col = 2, lwd = 2, lty = 2)]
rand.unemp[use.idx, lines(DATE, impute.sp, col = 3, lwd = 3, lty = 3)]


#____________________________________*****____________________________________#

# Comparing different data imputations and their behaviors

### We will generate two datasets with missing data, one with randomly missing 
### data and one with unfavorable data points (high unemployment). We will 
### compare the methods previously applied to see which one generates better 
### results

sort(rand.unemp[, lapply(.SD, function(x) mean((x - unemp$UNRATE)^2,
                                                na.rm = TRUE)),
                 .SDcols = c("impute.ff", "impute.rm.nolookahead", "impute.li", 
                             "impute.sp")])

sort(bias.unemp[ , lapply(.SD, function(x) mean((x - unemp$UNRATE)^2, 
                                                na.rm = TRUE)),
                 .SDcols = c("impute.ff", "impute.rm.nolookahead", "impute.li", 
                             "impute.sp")])













