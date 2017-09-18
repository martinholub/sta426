# Read the data
df <- read.csv("homework/hw1_data.csv")

# The column names are:
cnames <- colnames(df)

# The row names are
rnames <- rownames(df)

# The dimensions are
dfdims <- dim(df)

# How many rows do we have?
nrows <-dim(df)[1]

# Here we print first 6 rows
df[1:6,] # also head(df, 6)

#Print last 6 rows
tail(df, 6)

# How many missing values in Ozone?
miss_in_ozone = sum(is.na(df$Ozone))

# Mean of "Ozone" col without missing vals
mean_Oz_dropna <- mean(df$Ozone[!is.na(df$Ozone)])

# Some more complicated logical indexing
df[!is.na(df$Ozone) && (df$Ozone > 31) && (df$Temp > 90) && !is.na(df&Temp)]

# Get means of columns, excluding nans.
col_means <- vector(mode = "numeric", length = 0)
for (i in 1 : dim(df)[2]){
  col_means[i] = mean(df[i][!is.na(df[i])])
}
# Get stdevs for columns, exclude nans
col_sds <- apply(X = df, MARGIN = 2, sd ,na.rm = TRUE)

# Get per month ozone means
mt_means <- vector(mode = "numeric", length = 0)
id = 0
for (mt in unique(df$Month)){
  id =id + 1
  mt_means[id] = mean(df$Ozone[(df$Month == mt) & !is.na(df$Ozone)])
}

# Sample rows from data frame
df[sample(nrow(df), 5),]

