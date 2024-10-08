#____________________________________*****____________________________________#

############################### Seasonal Data #################################

### When it comes to data, seasonality is any type of recurring behavior in 
### which the frequency is stable. It can occur at many different frequencies 
### and at the same time. For example, human behavior is prone to having a daily 
### seasonality (always having lunch at the same time), a weekly seasonality 
### (going to the gym every Monday), and an annual seasonality (little traffic 
### on New Year's Day). Physical periods also have seasonality, such as the 
### period it takes for the Earth to revolve around the Sun.

### Identifying and dealing with seasonality is part of the **modeling** 
### process. On the other hand, it is also a form of **data cleaning**. 

### To see what seasonal data smoothing can do, we'll go back to the canonical 
### dataset of airline passenger counts. A quick look reveals that this is 
### highly seasonal data, but only if we plot it correctly.

### Note the difference between using the standard R graph (which uses points) 
### versus adding the argument to indicate that you want a line.

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

air  <- fread("AirPassengers.csv") 
air

air_scatter_plot <- plot(air$V2)

air_line_plot    <- plot(air$V2, type = 'l')

### The scatter chart shows some information more clearly than the line chart. 
### The variance of our data is increasing, as is the mean, which is most 
### obvious when we see a cloud of data points projecting outwards and 
### conically, tilted upwards.

### In addition to the evidence of seasonality in the line graph, we also obtain 
### useful information:
  #### information about what *type* of seasonality. that is, we see that the 
  #### data is not just seasonal, but seasonal in a multiplicative way. As 
  #### overall values increase, so do seasonal swings (think of this as scaling 
  #### the fluctuation between peak and trough levels or peak-value swings).

### We can easily decompose the data into its seasonal, trend and other 
### components in just one line:

air_periodic_plot <- plot(stl(AirPassengers, "periodic"))

#### Figure with decomposition of the original time series into a seasonal 
#### component, a trend and residuals

















