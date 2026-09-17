# Wissenschaftsbarometer — eine Seite für eine bestehende R-Markdown-Website

Studierende beantworten sechs Aussagen aus dem **Wissenschaftsbarometer
Schweiz**; die Seite liest die Antworten bei jedem Rendern direkt aus der
Google-Tabelle und legt das Kursprofil als Spinnennetz über die Werte der
Schweizer Bevölkerung.

Dies ist **eine zusätzliche Seite**, keine eigene Website: alles Nötige liegt in
einer Datei plus einem Ordner.

## Einbauen

1. `wissenschaftsbarometer.Rmd` ins **Wurzelverzeichnis** der bestehenden
   Website legen (dorthin, wo `index.Rmd` und `_site.yml` liegen).
2. Den Ordner `wsb/` daneben legen — er enthält Code, Daten, Schriften und CSS.
3. In `_site.yml` einen Navigationseintrag ergänzen:

```yaml
navbar:
  left:
    - text: "Wissenschaftsbarometer"
      href: wissenschaftsbarometer.html
```

4. Rendern: in RStudio die Seite öffnen und **Knit** drücken (RStudio erkennt
   `_site.yml` und baut die Seite inklusive Navbar), oder aus dem
   Wurzelverzeichnis:

```r
rmarkdown::render_site("wissenschaftsbarometer.Rmd")   # nur diese Seite
rmarkdown::render_site()                               # ganze Website
```

`wsb/render_page.R` macht dasselbe als Einzeiler: `Rscript wsb/render_page.R`.

```
wissenschaftsbarometer.Rmd    die Seite
wsb/R/data.R                  liest die Antworten live aus der Google-Tabelle
wsb/R/radar.R                 Spinnennetz + Verteilungsbalken, reines Base-R
wsb/R/fonts.R                 registriert die Schriften für die Grafiken
wsb/www/styles.css            Gestaltung, vollständig auf `.wsb` beschränkt
wsb/www/fonts/                TeX Gyre Heros: .otf für R, .woff fürs Web
wsb/data/items.csv            Itemtexte DE/EN/FR + keyword zur Spaltenzuordnung
wsb/data/barometer_reference.csv   Gesamt + SVP, SP, Mitte, FDP, Grüne
wsb/data/student_responses_example.csv   simulierte Antworten (n = 38)
wsb/survey/                   Umfrage aufsetzen (Google Forms + Apps Script)
wsb/render_page.R             rendert nur diese Seite
```

Zusätzliche Pakete: **showtext** für die Schriften in den Grafiken
(`install.packages("showtext")`). Fehlt es, läuft das Rendern trotzdem durch,
die Grafiken nutzen dann die Standardschrift.

## Was die Seite nicht anfasst

- **Theme und Navbar** kommen weiterhin aus `_site.yml`; die Seite setzt kein
  eigenes Theme.
- **Das CSS wirkt nur auf diese Seite.** Jede Regel in `wsb/www/styles.css`
  hängt an der Klasse `.wsb`, und der Seiteninhalt steht im Rmd in einem Block
  `::::: {.wsb}` … `:::::`. Andere Seiten der Website sehen davon nichts.
- **Dateinamen** sind so gewählt, dass sie mit nichts kollidieren (kein
  `index.Rmd`, kein `styles.css` im Wurzelverzeichnis).

Wenn die Barometer-Typografie mit dem Theme der Website beisst: die Zeile
`css: wsb/www/styles.css` im YAML-Kopf auskommentieren — dann sieht die Seite
aus wie der Rest der Website, die Grafiken bleiben unverändert.

## Umfrage anbinden

`wsb/survey/google-form.md` folgen (Formular anlegen, Tabelle freigeben), dann
im YAML-Kopf von `wissenschaftsbarometer.Rmd` eintragen:

```yaml
params:
  sheet_csv: "https://docs.google.com/spreadsheets/d/1AbC.../edit#gid=1234567"
  sheet_gid: ""
  course: "Vorlesung Wissenschaftskommunikation, Universität Basel"
```

R holt die Antworten bei **jedem Rendern direkt aus der Tabelle** — nichts
herunterladen, keine CSV im Repo. `sheet_csv` akzeptiert dreierlei:

| Eingabe | Voraussetzung |
|---|---|
| Normale Tabellen-Adresse (`.../d/<ID>/edit#gid=...`) oder nur die ID | Tabelle auf **„Jede Person mit dem Link – Betrachter"** freigeben |
| „Im Web veröffentlichen"-Adresse (`.../pub?...output=csv`) | einmal veröffentlichen |
| Lokaler Pfad zu einer CSV | — |

Ist die Tabelle nicht öffentlich lesbar, liefert Google eine Anmeldeseite statt
Daten — die Seite erkennt das, fällt auf die Beispieldaten zurück und schreibt
den Grund oben hin, statt mit einer kryptischen Fehlermeldung abzubrechen.
Solange `sheet_csv` leer ist, laufen ebenfalls die Beispieldaten: die Seite
lässt sich also einbauen und rendern, bevor die erste Antwort da ist.

**Private Tabelle ohne jede Freigabe?** `install.packages("googlesheets4")` und
im Setup-Chunk `resp <- wsb_read_gs4(params$sheet_csv)` verwenden; beim ersten
Rendern öffnet sich der Browser zur Google-Anmeldung.

## Formulierung der Items

Die Aussagen folgen dem Wissenschaftsbarometer, sind aber
geschlechtergerecht formuliert: wo das Original von „Wissenschaftlern" spricht,
steht hier **„Forschende"**, und Item D fragt neutral, „zu welchen Themen
geforscht wird". Der Methodenabschnitt der Seite weist darauf hin — die
Abweichung vom Originalwortlaut gehört zu den Dingen, die im Kurs zu
diskutieren sind.

Eigene Formulierungen: `wsb/data/items.csv` bearbeiten. Die Spalte `keyword`
muss ein eindeutiges Wort aus der jeweiligen Spaltenüberschrift des Formulars
enthalten — darüber werden Formularspalten und Items zugeordnet, nicht über die
Reihenfolge. Zusätzliche Fragen im Formular stören deshalb nicht.

## Schriften

Seite und Grafiken verwenden **TeX Gyre Heros** und **Heros Cn** — einen freien
Helvetica-Klon, also den Schweizer Grotesk-Look des gedruckten Barometers. Die
Dateien liegen in `wsb/www/fonts/` (GUST Font License, Weitergabe erlaubt):
`styles.css` bindet die `.woff`-Dateien per `@font-face` ein, `R/fonts.R`
registriert die `.otf`-Dateien über `showtext` für die Grafiken. Es wird nichts
von Google Fonts nachgeladen.

Die Skalierung der Grafikschrift hängt an `showtext_opts(dpi = ...)`; dieser
Wert muss mit der `dpi`-Chunkoption im Rmd übereinstimmen (beide 150).

## In der Vorlesung

- **Wo weicht der Kurs ab?** Studierende stimmen den Items A–C typischerweise
  stärker zu als die Bevölkerung, bei E („Forschende wissen am besten") oft
  weniger — ein Einstieg in *technokratische* versus *partizipative* Modelle von
  Wissenschaft.
- **Mittelwert versus Verteilung.** Ein Mittelwert von 3.0 kann Konsens oder
  Polarisierung bedeuten; die Verteilungsgrafik zeigt, was zutrifft.
- **Wer ist die Vergleichsgruppe?** Ein Kurs gegen eine Bevölkerungsstichprobe
  von 625–1499 Befragten: Selbstselektion, Alter, Bildungsniveau, sozial
  erwünschtes Antworten.
- **Parteipanels.** Welcher Anhängerschaft ähnelt der Kurs am meisten — und was
  sagt das über die Studierenden, was über den Messansatz?

## Anpassen

| Ziel | Vorgehen |
|---|---|
| Weitere Items | Zeile in `wsb/data/items.csv` **und** Spalten in `wsb/data/barometer_reference.csv` ergänzen — das Spinnennetz passt sich an die Anzahl an |
| Andere Skala | `rmin`/`rmax` in den `radar_plot()`-Aufrufen ändern |
| Farben | `WSB_COL` / `WSB_FILL` in `wsb/R/radar.R`, `--red` etc. in `wsb/www/styles.css` |
| Mehrere Jahrgänge vergleichen | zweite Antwortquelle einlesen und als dritte Serie an `radar_plot()` übergeben |

## Datenquelle

Referenzwerte: **Wissenschaftsbarometer Schweiz**, Frage „Wie sollte das
Verhältnis von Wissenschaft, Politik und Öffentlichkeit aussehen?", Basis
625–1499 Befragte, Standardabweichungen 1.2–1.6, Antwortskala 1–5. Die Werte in
`wsb/data/barometer_reference.csv` stammen aus der abgebildeten Berichtsseite;
vor der Publikation bitte gegen die Originalpublikation prüfen und diese auf der
Seite zitieren.
