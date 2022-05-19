data <- read.csv2("./data/przykladoweDane-Projekt.csv", sep = ";")

num_cols <- unlist(lapply(data, is.numeric))

values <- data[, num_cols]
groups <- data[, !num_cols]
avg_values <- aggregate(values, groups, mean, na.rm = T)

na_values <- data.frame(which(is.na(data), arr.ind = TRUE))


#data[na_values$row, !num_cols]
