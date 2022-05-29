if (!require("dplyr")) {
  install.packages("dplyr")
}
if (!require("openxlsx")) {
  install.packages("openxlsx")
}
if (!require("ggpubr")) {
  install.packages("ggpubr")
}
if (!require("car")) {
  install.packages("car")
}
if (!require("FSA")) {
  install.packages("FSA")
}
if (!require("dunn.test")) {
  install.packages("dunn.test")
}
if (!require("stringr")) {
  install.packages("stringr")
}

library("dplyr")
library("openxlsx")
library("ggpubr")
library("car")
library("FSA")
library("dunn.test")
library("stringr")

options(warn = -1)

data <- read.csv2("./data/przykladoweDane-Projekt.csv", sep = ";")
groups <- unique(data[[1]])
num_values <- unlist(lapply(data, is.numeric))

numeric_cols <- data[, num_values]
grupa <- names(data[1])

#zamiana braków dancu na średnie dla odpowiedniej grupy
write("Raport z zamiany braków", file = "./raport.txt")
for (i in which(sapply(data, is.numeric))) {
  for (j in which(is.na(data[, i]))) {

    new_value <- mean(data[data[, 1] == data[j, 1], i], na.rm = TRUE)
    data[j, i] <- new_value

    gr_name <- data[j, 1]
    cl_name <- names(data[i])

    text <- str_glue("Wpisanie {new_value} w {j}, {i} ({gr_name}, {cl_name})")
    write(text, "./raport.txt", append = TRUE)

  }
}

data[30, 1]

#wykrycie wartości odstających
write("\nWartosci odstające w danych", file = "./raport.txt", append = TRUE)
for (i in which(sapply(data, is.numeric))) {

  text <- c("Wartosci odstajace w kolumnie", names(data)[i], ":",
    boxplot(data[i], plot = FALSE)$out)
  write(text, "./raport.txt", sep = " ", append = TRUE,
    ncolumns = length(text))

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

#wpisanie charakterystyki do excela
sheets <- list()
for (i in seq_len(length(groups))) {
  df <- data.frame()
  for (j in seq_len(length(method_names))) {
    group_name <- paste(groups[i], method_names[j])
    line <- characteristics[[j]][i, -1]
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

#wykres rozkład normalny
dir.create("./wykresy/rozklad", recursive = TRUE)
for (i in seq_len(length(numeric_cols))) {
  col_name <- names(data[, num_values][i])
  file_name <- str_glue("{col_name}.png")
  print(file_name)
  ggdensity(data, x = col_name,
  color = names(data[1]), fill = names(data[1]))
  ggsave(path = "./wykresy/rozklad", filename = file_name)
}

#ocena homogeniczności
homogenity_values <- data.frame(
  lapply(data[, num_values], function(x)
  leveneTest(x ~ data[[1]], data = data)$"Pr(>F)"[1]))
homogenity_values <- data.frame(lapply(homogenity_values,
    function(x) if (is.numeric(x)) round(x, 3) else x))

check_normality <- function(values) {
  for (i in seq_len(length(values))) {
    if (values[i] < 0.05) {
      return(FALSE)
    }
  }
  return(TRUE)
}

#testy statystyczne
#do zrobienie:
dir.create("./wykresy/statystyka")
if (length(groups) == 2) { # nolint
  for (i in seq_len(length(numeric_cols))) {

    col <- data[, num_values][[i]]
    col_name <- names(data[, num_values][i])

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
    file_name <- str_glue("./wykresy/statystyka/{col_name}.png")

    png(file_name)

    plot(group1_val, type = "l", col = "red",
      main = chart_name, ylab = "Wartosci", xlab = "", xaxt = "n")
    lines(group2_val, col = "green")
    mtext(pvalue_com, side = 3, cex = 1)
    legend("topleft", groups, lty = c(1, 1), col = c("red", "green"))

    dev.off()

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

      pvalue <- round(pvalue, 4)

      if (pvalue < 0.05) {

        tukey <- TukeyHSD(aov(col ~ data[[1]], data = data))
        chart_name <- str_glue("Porównanie {col_name} między grupami")
        plot(tukey)
        mtext(chart_name, side = 3, cex =  2)

      }

    } else {

      pvalue <- kruskal.test(col ~ data[[1]], data = data)$p.value
      result <- str_glue("{col_name} p-value: {pvalue}")
      print(result)

      file_name <- str_glue("{col_name}.png")
      if (pvalue < 0.05) {

        dn <- dunnTest(col ~ data[[1]], data = data)
        print(dn)

        chart_name <- str_glue("Porównanie {col_name} między grupami")
        custom_g <- unlist(strsplit(dn$res$Comparison, " - "))
        first <- custom_g[c(TRUE, FALSE)]
        second <- custom_g[c(FALSE, TRUE)]
        pvalue <- round(dn$res$P.adj, 3)
        pos <- max(col) + 0.1 * max(col)
        step <- 0.3 * min(col)
        df <- data.frame(
          group1 = first,
          group2 = second,
          p = pvalue
        )

        ggplot(data, aes(x = grupa, y = col)) + geom_boxplot() + stat_pvalue_manual(df, # nolint
        y.position = pos, step.increase = 0.05, label = "p") + labs(title = chart_name, x = "grupy", y = col_name) #nolint
        ggsave(path = "./wykresy/statystyka", filename = file_name)

      } else {

        chart_name <- str_glue("Porównanie {col_name} między grupami. PVALUE: {pvalue}") # nolint

        ggplot(data, aes(x = grupa, y = col)) + geom_boxplot() + labs(title = chart_name, x = "grupy", y = col_name) #nolint
        ggsave(path = "./wykresy/statystyka", filename = file_name)

      }

      cat("\n\n")

    }
  }
}

#analizy korelacji
#do zrobienia
#zapis wykresów
dir.create("./wykresy/korelacja")
write("Analiza korelacji:\n", file = "./korelacja.txt")
for (i in seq_len(length(groups))) { # nolint

  current_group <- data %>% filter(data[1] == groups[i])

  for (j in seq_len(length(numeric_cols))) {
    for (z in j: length(numeric_cols)) {

      if (j != z) {

        column_f <- current_group[, num_values][[j]]
        column_s <- current_group[, num_values][[z]]

        correlation_test_result <- cor.test(column_f, column_s,
          method = "spearman")
        pvalue <- round(correlation_test_result$p.value, 3)

        if (pvalue > 0.5 || pvalue < -0.5) {
          name1 <- str_glue("{groups[i]}${names(current_group[, num_values][j])}") # nolint
          name2 <- str_glue("{groups[i]}${names(current_group[, num_values][z])}") # nolint
          result <- str_glue("Korelacja {name1}, {name2}: {pvalue}")

          write(result, file = "./korelacja.txt", append = TRUE)

          file_name <- str_glue("{name1}.{name2}.png")
          chart_name <- str_glue("Korelacja między {name1}, a {name2}")
          ggscatter(current_group,
            x = names(current_group[, num_values][j]),
            y = names(current_group[, num_values][z]), add = "reg.line",
            conf.int = TRUE, color = "green",
            cor.method = "spearman", cor.coef = TRUE) + labs(title = chart_name)
          ggsave(path = "./wykresy/korelacja", filename = file_name)

        }
      }
    }
  }
}
