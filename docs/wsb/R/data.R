## data.R ----------------------------------------------------------------
## Antworten direkt aus der Google-Tabelle lesen — ohne Download, bei jedem
## Knit frisch. Kein Paket nötig; R holt die CSV-Adresse selbst.
##
## `src` darf sein:
##   * eine "Im Web veröffentlichen"-Adresse  (.../pub?gid=0&single=true&output=csv)
##   * die normale Tabellen-Adresse           (.../spreadsheets/d/<ID>/edit#gid=123)
##   * die blosse Tabellen-ID                 ("1AbC...")
##   * ein lokaler Dateipfad                  ("data/....csv")
## In den mittleren beiden Fällen wird die CSV-Exportadresse gebaut; dafür muss
## die Tabelle auf „Jede Person mit dem Link – Betrachter" stehen.
## -----------------------------------------------------------------------

## Tabellen-ID aus einer Adresse ziehen (oder die ID selbst durchreichen)
wsb_sheet_id <- function(x) {
  m <- regmatches(x, regexpr("/spreadsheets/d/(e/)?[A-Za-z0-9_-]{20,}", x))
  if (length(m) == 1) return(sub(".*/d/", "", m))
  if (grepl("^[A-Za-z0-9_-]{20,}$", x)) return(x)
  NA_character_
}

## gid (Registerblatt) aus einer Adresse ziehen
wsb_sheet_gid <- function(x) {
  m <- regmatches(x, regexpr("[#&?]gid=([0-9]+)", x))
  if (length(m) == 1) return(sub(".*gid=", "", m))
  NA_character_
}

## -> direkte CSV-Adresse
wsb_csv_url <- function(src, gid = NULL) {
  if (!nzchar(src)) return(src)
  if (file.exists(src)) return(src)
  ## bereits eine CSV-Adresse (veröffentlicht oder export)
  if (grepl("output=csv|format=csv", src, fixed = FALSE)) return(src)
  id <- wsb_sheet_id(src)
  if (is.na(id)) return(src)
  if (is.null(gid) || !nzchar(as.character(gid))) {
    gid <- wsb_sheet_gid(src)
    if (is.na(gid)) gid <- "0"
  }
  if (startsWith(id, "e/"))   # veröffentlichte Tabelle ohne output=csv
    return(sprintf("https://docs.google.com/spreadsheets/d/%s/pub?gid=%s&single=true&output=csv",
                   id, gid))
  sprintf("https://docs.google.com/spreadsheets/d/%s/export?format=csv&gid=%s", id, gid)
}

#' Antworten einlesen
#'
#' @return Liste mit $data (data.frame), $url (tatsächlich gelesene Quelle),
#'   $fallback (TRUE, wenn auf die Beispieldaten ausgewichen wurde) und
#'   $message (Erklärung im Fehlerfall).
wsb_read_responses <- function(src,
                               gid = NULL,
                               fallback = "data/student_responses_example.csv") {

  out <- function(df, url, fb = FALSE, msg = "")
    list(data = df, url = url, fallback = fb, message = msg)

  read_csv_lines <- function(path) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    if (length(lines) == 0) stop("Die Quelle ist leer.")
    ## Google liefert bei fehlender Freigabe eine Anmeldeseite statt CSV
    if (any(grepl("^\\s*<(!DOCTYPE|html)", head(lines, 5), ignore.case = TRUE)))
      stop("Es kam HTML statt CSV zurück — die Tabelle ist nicht ",
           "öffentlich lesbar. Freigabe auf „Jede Person mit dem Link ",
           "– Betrachter\" setzen oder die Tabelle im Web veröffentlichen.")
    read.csv(text = lines, check.names = FALSE, stringsAsFactors = FALSE)
  }

  use_fallback <- function(msg) {
    df <- read_csv_lines(fallback)
    out(df, fallback, TRUE, msg)
  }

  if (is.null(src) || !nzchar(src))
    return(use_fallback("Keine Quelle gesetzt (params$sheet_csv ist leer)."))

  url <- wsb_csv_url(src, gid)
  res <- tryCatch(read_csv_lines(url),
                  error = function(e) conditionMessage(e))

  if (is.character(res)) return(use_fallback(res))
  if (nrow(res) == 0)
    return(use_fallback(paste0(
      "Gelesen, aber ohne Zeilen: ", url, " — entweder ist noch keine ",
      "Antwort da, oder die Adresse zeigt auf das falsche Registerblatt. ",
      "Die Tabelle mit geöffnetem Blatt „Formularantworten 1\" aufrufen ",
      "und die Adresse inklusive #gid=... kopieren.")))
  out(res, url)
}

## -----------------------------------------------------------------------
## Variante für PRIVATE Tabellen (keine Link-Freigabe gewünscht):
## einmalig install.packages("googlesheets4"), dann im Setup-Chunk
##
##   resp <- wsb_read_gs4(params$sheet_csv)
##
## Beim ersten Aufruf öffnet sich der Browser zur Google-Anmeldung; das Token
## wird zwischengespeichert. Funktioniert nur beim lokalen Knit, nicht in CI.
## -----------------------------------------------------------------------
wsb_read_gs4 <- function(src, sheet = 1) {
  if (!requireNamespace("googlesheets4", quietly = TRUE))
    stop("Paket 'googlesheets4' fehlt: install.packages(\"googlesheets4\")")
  as.data.frame(googlesheets4::read_sheet(src, sheet = sheet))
}
