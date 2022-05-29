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

Wartości te są wyszukiwane na podstawie wykresu pudełkowego, a dokładniej są to wartości, których położenie na wykresie znajduje się daleko od prostokątu (pudełka). <br>
Kolejnym etapem analizy zestawu danych jest wykonanie charakterystyk dla badanych grup. W tym przypadku mamy trzy grupy: CHOR1, CHOR2, KONTROLA.
<br><br>
Charakterystyka dla **CHOR1**:
| group\_name | wiek  | hsCRP | ERY  | PLT    | HGB   | HCT  | MCHC  | MON  | LEU   |
| ----------- | ----- | ----- | ---- | ------ | ----- | ---- | ----- | ---- | ----- |
| CHOR1 sr    | 29,56 | 6,1   | 5,36 | 225,28 | 12,41 | 0,36 | 35,13 | 0,86 | 12,02 |
| CHOR1 os    | 5,88  | 8,82  | 5,77 | 54,22  | 1,19  | 0,03 | 0,88  | 0,29 | 2,58  |
| CHOR1 med   | 29    | 3,97  | 4,2  | 217    | 12,4  | 0,36 | 35,05 | 0,76 | 11,66 |


Charakterystyka dla **CHOR2**:
| group\_name | wiek  | hsCRP | ERY  | PLT    | HGB   | HCT  | MCHC  | MON  | LEU   |
| ----------- | ----- | ----- | ---- | ------ | ----- | ---- | ----- | ---- | ----- |
| CHOR2 sr    | 30,04 | 5,54  | 4,2  | 209,12 | 12,81 | 0,35 | 35,55 | 0,95 | 12,04 |
| CHOR2 os    | 5,9   | 4,65  | 0,47 | 75,22  | 2,37  | 0,07 | 1,29  | 1,3  | 2,32  |
| CHOR2 med   | 30    | 3,45  | 4,27 | 195    | 12,57 | 0,36 | 35,55 | 0,66 | 12    |


Charakterystyka dla **KONTROLA**:
| group\_name  | wiek  | hsCRP | ERY  | PLT    | HGB   | HCT  | MCHC  | MON  | LEU   |
| ------------ | ----- | ----- | ---- | ------ | ----- | ---- | ----- | ---- | ----- |
| KONTROLA sr  | 32,32 | 5,3   | 4,01 | 225,88 | 11,26 | 0,34 | 34,4  | 0,76 | 11,36 |
| KONTROLA os  | 5,61  | 4     | 0,46 | 63,81  | 1,06  | 0,03 | 1,12  | 0,19 | 3,08  |
| KONTROLA med | 32    | 4,22  | 3,98 | 214    | 11,44 | 0,34 | 34,55 | 0,76 | 10,68 |

Jak można zauważyć pomiędzy CHOR1, a KONTROLA występują znaczące różnice w dwóch kolumnach, hsCRP i ERY. W przypadku CHOR2 i KONTROLA największe różnice możemy zauważyć w kolumnie PLT. 

