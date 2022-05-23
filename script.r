library("dplyr")
library("gridExtra")
library("xlsx")
library("data.table")

data <- read.csv2("./data/przykladoweDane-Projekt.csv", sep = ";")

num_cols <- unlist(lapply(data, is.numeric))
values <- data[, num_cols]
avg_values <- aggregate(values, data[1], mean, na.rm = T)
avg_values

#zamiana braków dancu na średnie dla odpowiedniej grupy
write("Raport z zamiany braków", file = "./raport.txt")
for (i in which(sapply(data, is.numeric))) {
  for (j in which(is.na(data[, i]))) {
    new_value <- mean(data[data[, 1] == data[j, 1], i], na.rm = TRUE)
    data[j, i] <- new_value

    text <- c("Zamiana w", j, "i", i, "na", new_value)
    write(text, "./raport.txt", sep = " ", append = TRUE,
      ncolumns = length(text))

    #cat(text, "\n", sep = " ")
  }
}

#wykrycie wartości odstających
write("\nWartosci odstające w danych", file = "./raport.txt", append = TRUE)
for (i in which(sapply(data, is.numeric))) {
  text <- c("Wartosci odstajace w kolumnie", names(data)[i], ":",
    boxplot(data[i], plot = FALSE)$out)
  write(text, "./raport.txt", sep = " ", append = TRUE,
    ncolumns = length(text))

  #cat(text, "\n", sep = " ")
}

data_mean <- data.frame(
  data %>%
    group_by(data[1]) %>%
    summarise(across(where(is.numeric), mean))
)
#cat("Charakterystyka danych: srednie wartosci:\n")
#data_mean

data_mean <- data.frame(
  data %>%
    group_by(data[1]) %>%
    summarise(across(where(is.numeric), mean))
)