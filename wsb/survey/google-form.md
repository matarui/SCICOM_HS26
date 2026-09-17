# Die Umfrage aufsetzen (Google Forms)

## 1. Formular anlegen

Entweder von Hand (sechs Fragen vom Typ **Linear scale / Skala**, 1–5, Texte
siehe Abschnitt 4) oder per Skript — `create_form.gs` legt Formular *und*
Antworttabelle fertig konfiguriert an.

### create_form.gs verwenden

Die Datei wird **nicht hochgeladen**, ihr Inhalt wird in den Apps-Script-Editor
kopiert:

1. Mit dem Google-Konto anmelden, in dem das Formular liegen soll.
2. [script.google.com](https://script.google.com) öffnen → **Neues Projekt**.
3. Im Editor steht eine leere `function myFunction() {}` — alles markieren und
   löschen.
4. `wsb/survey/create_form.gs` in einem Texteditor öffnen, den gesamten Inhalt
   kopieren und im Editor einfügen. Speichern (⌘S / Strg+S).
5. Oben in der Funktionsauswahl **`createBarometerForm`** wählen → **Ausführen**.
6. Beim ersten Mal fragt Google nach der Berechtigung, in deinem Drive
   Formulare und Tabellen anzulegen: **Berechtigungen prüfen** → Konto wählen →
   die Warnung „Diese App ist nicht verifiziert" mit **Erweitert → Zu
   „Unbenanntes Projekt" (unsicher)** bestätigen → **Zulassen**. Die Warnung ist
   bei selbst geschriebenen Skripten normal; „die App" bist du.
7. Unten öffnet sich das **Ausführungsprotokoll** mit drei Links: Formular zum
   Teilen, Formular zum Bearbeiten, Antworttabelle.

Formular und Tabelle liegen anschliessend in deinem Drive („Meine Ablage").

> Jeder Durchlauf legt ein **neues** Formular an. Zum Ändern also nicht erneut
> ausführen, sondern das bestehende Formular bearbeiten — sonst sammeln sich
> Duplikate, und die Antworten verteilen sich auf mehrere Tabellen.

## 2. Einstellungen

| Einstellung | Wert | Warum |
|---|---|---|
| E-Mail-Adressen erfassen | **aus** | anonyme Teilnahme, keine Personendaten |
| Auf 1 Antwort beschränken | **aus** | sonst Login nötig |
| Antworten bearbeitbar | aus | |
| Fragen obligatorisch | **an** | vermeidet fehlende Werte |
| Fragenreihenfolge mischen | aus | Reihenfolge A–F entspricht der Auswertung |

## 3. Die Tabelle für R lesbar machen

R liest die Antworten bei jedem Knit direkt aus der Tabelle. Dafür genügt
**eine** der beiden Varianten:

**A · Link-Freigabe (einfacher).** In der Antworttabelle: **Freigeben →
Allgemeiner Zugriff → Jede Person mit dem Link → Betrachter**. Dann unten das
Registerblatt **„Formularantworten 1" anklicken** und erst danach die Adresse
aus der Browserzeile kopieren:

```
https://docs.google.com/spreadsheets/d/1AbCdEf.../edit#gid=1234567
```

Der Teil `#gid=1234567` benennt das Registerblatt und muss mitkopiert werden —
ohne ihn liest R das erste Blatt der Tabelle, und das ist nicht zwingend das
mit den Antworten. (Das Skript `create_form.gs` gibt diese Adresse fertig im
Ausführungsprotokoll aus.)

**B · Im Web veröffentlichen.** **Datei → Freigeben → Im Web veröffentlichen** →
Blatt „Formularantworten 1" → Format **Kommagetrennte Werte (.csv)** →
*Veröffentlichen*:

```
https://docs.google.com/spreadsheets/d/e/2PACX-1vT.../pub?gid=0&single=true&output=csv
```

Beide Adressen kommen in `wissenschaftsbarometer.Rmd` unter `params: sheet_csv:` — der Bericht
erkennt die Form selbst. Unterschied: A gibt die Tabelle nur frei, wer den Link
kennt; B stellt eine Dauerkopie ins offene Netz und aktualisiert sie mit ein
paar Minuten Verzögerung. Für eine Erhebung in der Vorlesung reicht A.

Soll gar nichts freigegeben werden: `googlesheets4` verwenden, siehe README.

> Freigegeben wird nur diese eine Tabelle, und sie enthält weder Namen noch
> E-Mail-Adressen. Trotzdem: den Studierenden vor der Teilnahme sagen, dass die
> aggregierten Ergebnisse öffentlich auf einer Webseite erscheinen.

## 4. Die sechs Aussagen

Antwortskala: **1 = stimme überhaupt nicht zu … 5 = stimme voll und ganz zu**

| | Deutsch | English |
|---|---|---|
| **A** | Forschende sollten die Öffentlichkeit über ihre Arbeit informieren. | Researchers should inform the public about their work. |
| **B** | Wissenschaftliche Forschung sollte staatlich unterstützt werden. | Scientific research should be supported by the state. |
| **C** | Politische Entscheidungen sollten auf wissenschaftlichen Erkenntnissen beruhen. | Political decisions should be based on scientific evidence. |
| **D** | Leute wie ich sollten mitentscheiden, zu welchen Themen geforscht wird. | People like me should have a say in which topics are researched. |
| **E** | Forschende wissen am besten, was gut für die Zukunft der Schweiz ist. | Researchers know best what is good for the future of Switzerland. |
| **F** | Forschende stecken mit Politik und Wirtschaft unter einer Decke. | Researchers are in cahoots with politics and business. |

Die Fragetexte **wörtlich** übernehmen, wenn die Ergebnisse mit dem
Wissenschaftsbarometer verglichen werden sollen — und weil `wissenschaftsbarometer.Rmd` die
Spalten über Stichwörter (`informieren`, `staatlich`, `Erkenntnissen`,
`mitentscheiden`, `Zukunft`, `Decke`) zuordnet. Andere Formulierungen sind
möglich, dann aber die Spalte `keyword` in `wsb/data/items.csv` anpassen.

## 5. Optional: weitere Fragen

Zusätzliche Fragen (Studienfach, Semester, politische Selbsteinstufung links–rechts)
stören die Auswertung nicht — die Zuordnung erfolgt über Stichwörter, nicht über
die Spaltenposition. Eine Selbsteinstufung erlaubt später den Vergleich mit den
Parteipanels.
