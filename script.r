library("dplyr")
library("openxlsx")
library("data.table")

data <- read.csv2("./data/przykladoweDane-Projekt.csv", sep = ";")

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

#charakterystyka danych
characteristic_methods <- c(mean, var)
method_names <- c("srednia", "wariancja")
sheets <- list()

for (i in seq_len(length(characteristic_methods))) {
  df <- data.frame(
    data %>%
    group_by(data[1]) %>%
    summarise(across(where(is.numeric), characteristic_methods[i]))
  )
  df <- data.frame(lapply(df,
    function(x) if(is.numeric(x)) round(x, 2) else x))
  sheets[[method_names[i]]] <- df
}

write.xlsx(sheets, file = "charakterystyka.xlsx")