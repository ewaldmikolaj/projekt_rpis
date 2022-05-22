library("dplyr")
library("data.table")

data <- read.csv2("./data/przykladoweDane-Projekt.csv", sep = ";")

num_cols <- unlist(lapply(data, is.numeric))
values <- data[, num_cols]
avg_values <- aggregate(values, data[1], mean, na.rm = T)
avg_values

#zamiana braków dancu na średnie dla odpowiedniej grupy
for (i in which(sapply(data, is.numeric))) {
  for (j in which(is.na(data[, i]))) {
    data[j, i] <- mean(data[data[, 1] == data[j, 1], i], na.rm = TRUE)
  }
}

#wykrycie wartości odstających
for (i in which(sapply(data, is.numeric))) {
  cat("Wartosci odstajace w", names(data)[i], ":", boxplot(data[i], 
    plot = FALSE)$out, "\n")
}


data.table(aggregate(values, data[1], mean))