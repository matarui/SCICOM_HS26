## render_page.R ---------------------------------------------------------
## Rendert NUR die Barometer-Seite (nicht die ganze Website).
## Aus dem Wurzelverzeichnis der Website aufrufen:
##
##   Rscript wsb/render_page.R
##
## Mit Adresse der Antworttabelle als Argument (überschreibt params im YAML):
##
##   Rscript wsb/render_page.R "https://docs.google.com/spreadsheets/d/<ID>/edit#gid=123"
##   Rscript wsb/render_page.R "<TABELLEN-ID>" "123"
##
## Ohne Argumente läuft der Website-Generator: die Seite bekommt Navbar und
## Theme wie jede andere Seite. Mit Argumenten wird direkt gerendert
## (rmarkdown::render kennt params, der Website-Generator nicht) — dabei fehlt
## die Navbar. Für den Normalbetrieb also: sheet_csv einmal ins YAML eintragen
## und dieses Skript ohne Argumente aufrufen.
##
## Ganze Website neu bauen: rmarkdown::render_site()
## -----------------------------------------------------------------------

page <- "wissenschaftsbarometer.Rmd"

if (!file.exists(page))
  stop("'", page, "' nicht gefunden. Bitte dieses Skript aus dem ",
       "Wurzelverzeichnis der Website aufrufen: Rscript wsb/render_page.R")

args <- commandArgs(trailingOnly = TRUE)
params <- list()
if (length(args) >= 1 && nzchar(args[1])) params$sheet_csv <- args[1]
if (length(args) >= 2 && nzchar(args[2])) params$sheet_gid <- args[2]

is_site <- file.exists("_site.yml")

if (!length(params) && is_site) {
  rmarkdown::render_site(input = page)          # mit Navbar und Theme
} else {
  if (is_site)
    message("Hinweis: mit params wird ohne Website-Generator gerendert — ",
            "die Navbar fehlt auf dieser Seite.")
  out_dir <- tryCatch({
    cfg <- rmarkdown::site_config(".")
    if (is.null(cfg$output_dir)) "_site" else cfg$output_dir
  }, error = function(e) ".")
  rmarkdown::render(input = page, output_dir = out_dir,
                    params = if (length(params)) params else NULL,
                    envir = new.env())
}

message("\n-> Seite gerendert. Committen und pushen.")
