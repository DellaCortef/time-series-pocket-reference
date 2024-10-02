# CLEANING DATASETS

## missing data;
## frequency change of a time series (upsampling and downsampling);
## data smoothing;
## dealing with seasonality in data;
## prevention of unintentional lookaheads;

### Missing Data
### We will work with monthly unemployment data, freely available for download (https://data.bls.gob/timeseries/LNS14000000), released by the US government since 1948. We will then generate two sets of data from this baseline data : one where the data is indeed randomly missing, and another where it is the highest unemployment months in history.

#### Even if generalizing, we can see that missing data in time series are more common than in cross-sectional data analyses, due to the burden of longitudinal sampling being quite heavy: incomplete time series are quite common. The most used methods are:
##### - imputation:
#####   _ when we fill in missing data based on observations about the entire data set;
##### - interpolation:
#####   _ when we use neighboring data points in order to estimate the missing value;
##### - exclusion of affected time periods:
#####   _ when we choose not to use time periods that have missing data;

# installing libs
install.packages("zoo")
install.packages("readr")
install.packages("rmarkdown")
install.packages("data.table")

# loading libs
library(readr)
library(data.table)

require(zoo)         ## the zoo provides the resources for time series
require(data.table)  ## 'data.table' is a high-performance dataframe

setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/getting-time-series-datasets/datasets/')

unemp <- fread("UNRATE.csv")     
unemp[, DATE := as.Date(DATE)]
setkey(unemp, DATE)

## generating a dataset in which data is randomly missing
rand.unemp.idx <- sample(1:nrow(unemp), 1*nrow(unemp))
rand.unemp     <- unemp[-rand.unemp.idx]

## generating a dataset in which data has a higher probability of absence when unemployment is high
high.unemp.idx <- which(unemp$UNRATE > 8)
num.to.select  <- .2 * length(high.unemp.idx)
high.unemp.idx <- sample(high.unemp.idx,)
bias.unemp.    <- unemp[-high.unemp.idx]


## Since we deleted rows from our data tables to create a dataset with missing data, we will need to read the missing dates and NA values. To do this, we will use the merge *rolling join* from the 'data.table' package









