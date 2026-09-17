## radar.R ---------------------------------------------------------------
## Minimales Spinnennetz in Base-R, gestaltet nach den Abbildungen des
## Wissenschaftsbarometers Schweiz. Keine Paketabhängigkeiten.
## Schriften werden über R/fonts.R gesetzt (options wsb.family*, optional).
## -----------------------------------------------------------------------

## Farben (Barometer-Rot + kontrastierendes Dunkelblau)
WSB_COL  <- c("#E2001A", "#153A5B", "#1E7A52")
WSB_FILL <- c("#F6B3A8", "#A9C0D6", "#A8D2BE")
WSB_GREY <- "#6B6B6B"

## Vertex-Winkel: erstes Label oben, dann im Uhrzeigersinn.
radar_angles <- function(n) pi / 2 - 2 * pi * (seq_len(n) - 1) / n

#' Spinnennetz zeichnen
#'
#' @param series benannte Liste numerischer Vektoren gleicher Länge
#'   (ein Vektor = ein Profil). Die Namen erscheinen in der Legende.
#' @param labels Achsenbeschriftungen (A-F).
#' @param rmin,rmax Bereich der Antwortskala (Zentrum und äusserer Ring).
#' @param rings Gitterlinien.
#' @param col,fill Linien- und Flächenfarben, werden über `series` recycelt.
#' @param value_labels Zahlenwert an jedem Eckpunkt anschreiben.
#' @param family,family_cn Schriftfamilien (Standard: via R/fonts.R gesetzt).
radar_plot <- function(series,
                       labels = NULL,
                       rmin = 1, rmax = 5,
                       rings = 2:5,
                       col = WSB_COL,
                       fill = WSB_FILL,
                       lwd = 2.6,
                       value_labels = TRUE,
                       label_cex = 0.88,
                       legend_pos = "bottom",
                       title = NULL,
                       family = getOption("wsb.family", ""),
                       family_cn = getOption("wsb.family_cn", "")) {

  if (is.numeric(series)) series <- list(series)
  if (is.null(labels)) labels <- names(series[[1]])
  n <- length(labels)
  stopifnot(n >= 3, all(vapply(series, length, 1L) == n))

  ang <- radar_angles(n)
  sc <- function(v) pmax(0, pmin(1, (v - rmin) / (rmax - rmin)))
  k <- length(series)
  col <- rep_len(col, k)
  fill <- rep_len(fill, k)

  op <- par(mar = c(if (is.null(legend_pos)) 1 else 3.2, 1,
                    if (is.null(title)) 1 else 3, 1),
            family = family, xpd = NA)
  on.exit(par(op), add = TRUE)

  plot(NA, xlim = c(-1.3, 1.3), ylim = c(-1.25, 1.25), asp = 1,
       axes = FALSE, xlab = "", ylab = "")
  if (!is.null(title))
    title(main = title, line = 1, cex.main = 1.15, family = family_cn)

  ## Gitter ----------------------------------------------------------------
  tt <- seq(0, 2 * pi, length.out = 240)
  for (r in rings) {
    rr <- sc(r)
    outer <- isTRUE(all.equal(r, rmax))
    lines(rr * cos(tt), rr * sin(tt),
          col = if (outer) "#8A8A8A" else "#DCDCDC",
          lty = if (outer) 1 else 3,
          lwd = if (outer) 1 else 0.9)
  }
  segments(0, 0, cos(ang), sin(ang), col = "#BFBFBF", lty = 3, lwd = 0.9)

  ## Achsenbeschriftung ----------------------------------------------------
  text(1.14 * cos(ang), 1.14 * sin(ang), labels,
       font = 2, cex = 1.15, family = family_cn)

  ## Profile ---------------------------------------------------------------
  for (i in seq_len(k)) {
    rr <- sc(series[[i]])
    polygon(rr * cos(ang), rr * sin(ang),
            col = adjustcolor(fill[i], alpha.f = 0.45),
            border = col[i], lwd = lwd)
    points(rr * cos(ang), rr * sin(ang), pch = 19, col = col[i], cex = 0.8)
  }

  ## Werte -----------------------------------------------------------------
  if (isTRUE(value_labels)) {
    off <- if (k == 1) 0 else seq(0.075, -0.075, length.out = k)
    for (i in seq_len(k)) {
      rr <- sc(series[[i]]) + 0.11
      x <- rr * cos(ang) - off[i] * sin(ang)
      y <- rr * sin(ang) + off[i] * cos(ang)
      text(x, y, sprintf("%.1f", series[[i]]),
           col = col[i], font = 2, cex = label_cex, family = family_cn)
    }
  }

  ## Legende ---------------------------------------------------------------
  if (!is.null(legend_pos) && !is.null(names(series))) {
    legend(legend_pos, legend = names(series), horiz = TRUE, bty = "n",
           inset = c(0, -0.03), lwd = lwd, col = col, pch = 19,
           cex = 0.95, seg.len = 1.2, text.font = 2, text.col = "#111111")
  }
  invisible(NULL)
}

#' Gestapelte Antwortverteilung (1-5) je Item
response_bars <- function(counts, labels, title = NULL,
                          palette = c("#B8B8B8", "#DDCDC6", "#F6B3A8",
                                      "#EE6A55", "#E2001A"),
                          family = getOption("wsb.family", ""),
                          family_cn = getOption("wsb.family_cn", "")) {
  m <- t(apply(counts, 1, function(x) 100 * x / sum(x)))
  op <- par(mar = c(4, 13, 4, 1), family = family, xpd = NA)
  on.exit(par(op), add = TRUE)
  bp <- barplot(t(m), horiz = TRUE, col = palette, border = "white",
                names.arg = labels, las = 1, xlim = c(0, 100),
                xlab = "Anteil der Antworten (%)", cex.names = 0.9,
                cex.axis = 0.85, space = 0.45)
  if (!is.null(title)) title(main = title, line = 1.6, family = family_cn)
  legend("top", legend = colnames(counts), fill = palette, border = "white",
         horiz = TRUE, bty = "n", inset = c(0, -0.14), cex = 0.85,
         text.font = 2)
  invisible(bp)
}
