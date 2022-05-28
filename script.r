library("dplyr")
library("openxlsx")
library("ggpubr")
library("car")
library("FSA")
library("dunn.test")
library("stringr")

data <- read.csv2("./data/przykladowe2Grupy.csv", sep = ";")
groups <- unique(data[[1]])
num_values <- unlist(lapply(data, is.numeric))

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
method_names <- c("sr", "os", "med")
characteristics <- list()

for (i in seq_len(length(characteristic_methods))) {
  df <- data.frame(
    data %>%
    group_by(data[1]) %>%
    summarise(across(where(is.numeric), characteristic_methods[i],
      .names = "{.col}"))
  )
  df <- data.frame(lapply(df,
    function(x) if (is.numeric(x)) round(x, 2) else x))
  characteristics[[method_names[i]]] <- df
}

sheets <- list()
for (i in seq_len(length(groups))) {
  df <- data.frame()
  for (j in seq_len(length(method_names))) {
    group_name <- paste(groups[i], method_names[j])
    line <- characteristics[[j]][1, -1]
    df <- rbind(df, data.frame(group_name, line))
  }
  sheets[[groups[i]]] <- df
}
write.xlsx(sheets, file = "./charakterystyka.xlsx")

#ocena zgodności z rozkładem normalnym
normality_values <- data.frame(
data %>%
group_by(data[1]) %>%
summarise(across(where(is.numeric), function(x) shapiro.test(x)$p.value)))
normality_values <- data.frame(lapply(normality_values,
    function(x) if (is.numeric(x)) round(x, 3) else x))
normality_values

#utworzyć wykresy dla zgodności!!

#ocena homogeniczności
homogenity_values <- data.frame(
  lapply(data[, num_values], function(x)
  leveneTest(x ~ data[[1]], data = data)$"Pr(>F)"[1]))
homogenity_values <- data.frame(lapply(homogenity_values,
    function(x) if (is.numeric(x)) round(x, 3) else x))
homogenity_values

check_normality <- function(values) {
  for (i in seq_len(length(values))) {
    if (values[i] < 0.05) {
      return(FALSE)
    }
  }
  return(TRUE)
}

numeric_cols <- data[, num_values]
grupa <- names(data[1])
if (length(groups) == 2) {
  for (i in seq_len(length(numeric_cols))) {

    col <- data[, num_values][[i]]
    col_name <- names(data[, num_values][1])

    if (check_normality(normality_values[[i]])) {

      if (homogenity_values[[i]] > 0.05) {

        pvalue <- t.test(col ~ data[[1]], var.equal = TRUE)$p.value
        pvalue <- round(pvalue, 4)

      } else {

        pvalue <- t.test(col ~ data[[1]], var.equal = FALSE)$p.value
        pvalue <- round(pvalue, 4)

      }
    } else {

      pvalue <- wilcox.test(col ~ data[[1]], data = data)$p.value
      pvalue <- round(pvalue, 4)

    }

    chart_name <- str_glue("Porónanie {col_name} między grupami")
    pvalue_com <- str_glue("PVALUE: {pvalue}")
    group1_val <- col[data[1] == groups[1]]
    group2_val <- col[data[1] == groups[2]]
    plot(group1_val, type = "l", col = "red",
      main = chart_name, ylab = "Wartosci", xlab = "", xaxt = "n")
    lines(group2_val, col = "green")
    mtext(pvalue_com, side = 3, cex = 1)
    legend("topleft", groups, lty = c(1, 1), col = c("red", "green"))
    
  }
} else if (length(groups) > 2) {
  for (i in seq_len(length(numeric_cols))) {

    col <- data[, num_values][[i]]
    col_name <- names(data[, num_values][i])

    if (check_normality(normality_values[[i]]) &&
          homogenity_values[[i]] > 0.05) {
      pvalue <- summary(aov(col ~ data[[1]], data = data))[[1]][["Pr(>F)"]][[1]]
      result <- str_glue("{col_name} p-value: {pvalue}")
      print(result)

      if (pvalue < 0.05) {
        print("Istotne różnice")
        tukey <- TukeyHSD(aov(col ~ data[[1]], data = data))
        chart_name <- str_glue("Porównanie {col_name} między grupami")
        plot(tukey)
        mtext(chart_name, side = 3, cex =  2)
      }

    } else {

      pvalue <- kruskal.test(col ~ data[[1]], data = data)$p.value
      result <- str_glue("{col_name} p-value: {pvalue}")
      print(result)

      if (pvalue < 0.05) {
        print("Istotne różnice")
        dn <- dunnTest(col ~ data[[1]], data = data)
        print(dn)
        chart_name <- str_glue("Porównanie {col_name} między grupami")
        stripchart(P.adj ~ Comparison,
          main = chart_name,
          data = dn$res,
          xlab = "p-value",
          ylab = "grupy",
          xlim = c(0, 0.9),
          col = "red"
        )
        abline(v = 0.05, col = "blue")
      }

      cat("\n\n")
    }
  }
}
