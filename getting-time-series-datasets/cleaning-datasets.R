# CLEANING DATASETS

## missing data;
## frequency change of a time series (upsampling and downsampling);
## data smoothing;
## dealing with seasonality in data;
## prevention of unintentional lookaheads;

### Missing Data
#### Even if generalizing, we can see that missing data in time series are more common than in cross-sectional data analyses, due to the burden of longitudinal sampling being quite heavy: incomplete time series are quite common. The most used methods are:
##### - imputation:
#####   _ when we fill in missing data based on observations about the entire data set;
##### - interpolation:
#####   _ when we use neighboring data points in order to estimate the missing value;
##### - exclusion of affected time periods:
#####   _ when we choose not to use time periods that have missing data;

