library("dplyr")
library("openxlsx")
library("ggpubr")
library("car")

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
characteristic_methods <- c(mean, sd, median)
method_names <- c("srednia", "odchylenie_standardowe", "wariancja")
sheets <- list()

for (i in seq_len(length(characteristic_methods))) {
  df <- data.frame(
    data %>%
    group_by(data[1]) %>%
    summarise(across(where(is.numeric), characteristic_methods[i],
      .names = "{.col}"))
  )
  df <- data.frame(lapply(df,
    function(x) if (is.numeric(x)) round(x, 2) else x))
  sheets[[method_names[i]]] <- df
}
write.xlsx(sheets, file = "./charakterystyka.xlsx")

#ocena zgodności z rozkładem normalnym
normality_values <- data.frame(
data %>%
group_by(data[1]) %>%
summarise(across(where(is.numeric), function(x) shapiro.test(x)$p.value)))
normality_values <- data.frame(lapply(normality_values,
    function(x) if (is.numeric(x)) round(x, 3) else x))

#utworzyć wykresy dla zgodności!!

#ocena homogeniczności
num_values <- unlist(lapply(data, is.numeric))
homogenity_values <- data.frame(
  lapply(data[, num_values], function(x)
  leveneTest(x ~ data[[1]], data = data)$"Pr(>F)"[1]))
homogenity_values <- data.frame(lapply(homogenity_values,
    function(x) if (is.numeric(x)) round(x, 3) else x))
homogenity_values