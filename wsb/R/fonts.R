## fonts.R ---------------------------------------------------------------
## Registriert die mitgelieferten Schriften (www/fonts/) für R-Grafiken.
##
## Braucht das Paket 'showtext' (install.packages("showtext")). Fehlt es, oder
## fehlen die Schriftdateien, greift die Standardschrift des Grafikgeräts —
## der Bericht läuft in jedem Fall durch.
## -----------------------------------------------------------------------

wsb_setup_fonts <- function(dir = "www/fonts", dpi = 150, quiet = FALSE) {

  say <- function(...) if (!isTRUE(quiet)) message("[fonts] ", ...)
  fallback <- function(why) {
    say(why, " Grafiken nutzen die Standardschrift.")
    options(wsb.family = "", wsb.family_cn = "")
    invisible(FALSE)
  }

  files <- c(
    sans_r = "texgyreheros-regular.otf",
    sans_b = "texgyreheros-bold.otf",
    cond_r = "texgyreheroscn-regular.otf",
    cond_b = "texgyreheroscn-bold.otf"
  )
  paths <- file.path(dir, files)

  if (!all(file.exists(paths)))
    return(fallback(paste0("Schriftdateien fehlen in ", dir, "/.")))

  if (!requireNamespace("showtext", quietly = TRUE) ||
      !requireNamespace("sysfonts", quietly = TRUE))
    return(fallback("Paket 'showtext' nicht installiert — install.packages(\"showtext\")."))

  ok <- tryCatch({
    sysfonts::font_add("WSB Sans",    regular = paths[1], bold = paths[2])
    sysfonts::font_add("WSB Sans Cn", regular = paths[3], bold = paths[4])
    showtext::showtext_auto()
    showtext::showtext_opts(dpi = dpi)   # muss zur dpi-Chunkoption passen
    TRUE
  }, error = function(e) {
    say("Registrierung fehlgeschlagen: ", conditionMessage(e))
    FALSE
  })

  if (!ok) return(fallback(""))

  options(wsb.family = "WSB Sans", wsb.family_cn = "WSB Sans Cn")
  say("TeX Gyre Heros aktiv (dpi = ", dpi, ").")
  invisible(TRUE)
}
