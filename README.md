<h1 align="center"> projekt RPiS 2022 </h1>
Mikołaj Ewald, 469494

&nbsp;<br>

## manual uruchomienia programu

&nbsp;<br>

## sprawozdanie

### przygotowanie danych wejściowych

W celu przygotowania danych wyjściowych w pliku [*przykladoweDane-Projekt.csv*](https://github.com/ewaldmikolaj/projekt_rpis/blob/main/data/przykladoweDane-Projekt.csv) program zaczyna od uzupełnienia braków w danych, czyli wartości NA. Wartości puste uzupełniane są przez **średnią** obliczaną dla grupy znajdującej się w pierwszej kolumnie zbioru danych. <br>
Wartości NA uzupełnione przez program:

- 5 rząd, 10 kolumna (gr: CHOR1, kl: MON): 0.8579167
- 13 rząd, 7 kolumna (gr: CHOR1, kl: HGB): 12.41141
- 68 rząd, 7 kolumna (gr: KONTROLA, kl: HGB): 11.26357

Następnie w celu oceny danych program raportuje **wartości odstające**, czyli wartości, które są odegłe od pozostałych elementów próby. Zazwyczaj takie wartości świadczą o błędach danych spowodowanych błędnym pomiarem lub pomyłce we wprowadzaniu danych. 

Wartości odstające w analizowanym plik:

| kolumna | wartości                        |
|---------|---------------------------------|
| hsCRP   | 20.1548 16.4069 42.6499 19.2124 |
| ERY     | 33                              |
| PLT     | 456 434                         |
| HGB     | 22.2318                         |
| HCT     | 0.0423                          |
| MCHC    | 38.8674 38.203 32.0573 32.2234  |
| MON     | 1.5 1.52 0.14 1.61 7            |

Wartości te są wyszukiwane na podstawie wykresu pudełkowego, a dokładniej są to wartości, których położenie na wykresie znajduje się daleko od prostokątu (pudełka).