# Install packages
install.packages("data.table")

# Load packages
library(ggplot2)
library(data.table)

# Setting the dataset path
setwd('/Users/dellacorte/py-projects/data-science/time-series-pocket-reference/datasets/')

df = fread("311.csv")
colnames(df)

# Convert column names to snake_case using gsub
colnames(df) <- tolower(gsub(" ", "_", colnames(df)))

# Check updated column names
colnames(df)

# Convert 'created_date' and 'closed_date' to POSIXct format
df$created_date <- as.POSIXct(df$created_date, format = "%m/%d/%Y %I:%M:%S %p")
df$closed_date <- as.POSIXct(df$closed_date, format = "%m/%d/%Y %I:%M:%S %p")

# Compute the difference in days
df$duration_days <- as.numeric(difftime(df$closed_date, df$created_date, units = "days"))

# Summary of the duration in days
summary(df$duration_days)

# Get created_date range
range(df$created_date)

# Ensure created_date is in the Correct Format
str(df$created_date)

# Ensure index column exists
df$index <- seq_len(nrow(df)) 

# Add an index column for row numbers
df$index <- seq_len(nrow(df))

# Sort the data by created_date
df <- df[order(df$created_date), ]

# Create the line plot
ggplot(df, aes(x = index, y = created_date, group = 1)) +
  geom_line(color = "blue") +
  labs(title = "Cumulative Record Count Over Time",
       x = "Cumulative Record Count",
       y = "Created Date") +
  theme_minimal()

