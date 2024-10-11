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

plot(lag(diff(EuStockMarkets[, "SMI"]), 1), 
         diff(EuStockMarkets[, "DAX"]))









































