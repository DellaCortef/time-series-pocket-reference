# Install packages
install.packages("ISOweek")
install.packages("data.table")

# Load packages
library(ISOweek)
library(data.table)

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

# Read the Flu CSV using fread
flu <- fread("flu_train.csv")

# Ensure flu is a data.table
setDT(flu)  # Converts flu to data.table in-place

# Replace non-numeric values in TauxGrippe before conversion
flu[, TauxGrippe := as.character(TauxGrippe)]  # Ensure it's character
flu[TauxGrippe %in% c("", "NA", "unknown", "-"), TauxGrippe := NA]  # Replace invalid entries with NA

# Convert to numeric and store as flu.rate
flu[, flu.rate := as.numeric(TauxGrippe)]

# Replace NAs in flu.rate with 0 (if needed)
flu[is.na(flu.rate), flu.rate := 0]

# Print summary to check
summary(flu$flu.rate)

head(flu)

# NA checking
nrow(flu[is.na(flu.rate)]) / nrow(flu)

unique(flu[is.na(flu.rate)]$region_name)

flu[, year := as.numeric(substr(week, 1, 4))]
flu[, wk   := as.numeric(substr(week, 5, 6))]

flu[, date := ISOweek2date(paste0(substr(as.character(week), 1, 4), "-W", substr(as.character(week), 5, 6), "-1"))]

# Lets focus on Paris
paris.flu = flu[region_name == "ILE-DE-FRANCE"]
paris.flu = paris.flu[order(date, decreasing = FALSE)]

paris.flu[, .(week, date, flu.rate)]

paris.flu[, .N, year]

paris.flu[, plot(date, flu.rate,
                 type = "l", xlab = "Date",
                 ylab = "Flu rate")]

paris.flu <- paris.flu[week != 53]           

acf(paris.flu$flu.rate,        )
acf(diff(paris.flu$flu.rate, 52))
    