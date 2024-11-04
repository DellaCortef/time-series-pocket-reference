# Statistical Models for Time Series
##### We will map some linear statistical models to **time series**.
##### These models are related to linear regression, but represent 
##### correlations between data points in the same **time series**, 
##### unlike standard methods applied to cross-sectional data, where 
##### Each data point is assumed to be independent of the others in the sample. 
##### We will analyze the following models:
  ##### - autoregressive models (AR), moving average models (MA) and models 
  ##### autoregressive integrated moving average (ARIMA);
  ##### - vector autoregression (VAR);
  ##### - hierarchical models;
##### Traditionally, these models have been the driving force in forecasting 
##### **time series** and continue to be used in a wide range of 
##### situations, from academic research to modeling in various fields 
##### of acting.

## Why Not Use Linear Regression
##### As a data analyst, chances are you are already familiar with 
##### *linear regressions*. If not, a *linear regression* assumes you 
##### has *independent and identically distributed data (iid)*. According to 
##### we studied previously, this does not occur with **series data 
##### temporal**. In them, nearby points in time are usually strongly 
##### correlated with each other. In reality, when there are no correlations 
##### temporal, **time series** data are hardly useful for 
##### traditional tasks, such as predicting the future or understanding dynamics 
##### temporal.

##### Não raro, os tutoriais e os livros de **séries temporais** nos passam a 
##### impressão indevida de que a *regressão linear* não serve para **séries 
##### temporais**. O que faz os alunos acreditarem que *regressões lineares* 
##### simples não são suficientes. Mas não é assim que funciona. A *regressão 
##### linear* de mínimos quadrados ordinários pode ser aplicada aos dados de 
##### **séries temporais**, desde que as seguintes condições sejam atendidas:

##### *Assumptions regarding the behavior of the **time series**:*
  ##### - the **time series** has a linear response to its predictors;
  ##### - no input variable is constant over time or 
  ##### perfectly correlated with another input variable. Thus, the 
  ##### traditional requirement of *linear regression* of independent variables if 
  ##### amplifies to consider the temporal dimension of the data.
##### *Assumptions regarding the error:*
  ##### - for each point in time, the expected value of the error given all 
  ##### explanatory variables for all time periods (step forward 
  ##### [forward] and step backward [backward]), is 0;
  ##### - 
  ##### 
  #####



