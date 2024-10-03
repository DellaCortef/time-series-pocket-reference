### Rolling Join Example

## We have a small data.table of donation dates
donations <- data.table(
  amt = c(99, 100, 5, 15, 11, 1200),
  dt = as.Date(c("2019-2-27", "2019-3-2", "2019-6-13",
                 "2019-8-1", "2019-8-31", "2019-9-15"))
)

## We also have information about the dates of each advertising campaign
publicity <- data.table(
  identifier = c("q4q42", "4299hj", "bbg2"),
  dt         = as.Date(c("2019-1-1",
                         "2019-4-1",
                         "2019-7-1"))
)

## We will define a primary key in each data.table
setkey(publicity, "dt")
setkey(donations, "dt")

## Labeling each donation according to the advertising campaign that most 
## recently preceded it. Labeling each donation according to the advertising 
## campaign that most recently preceded it. We can easily see this 
## with roll = TRUE

publicity[donations, roll = TRUE]
