/**
 * Erstellt das Wissenschaftsbarometer-Formular inkl. Antworttabelle.
 * script.google.com -> Neues Projekt -> einfügen -> createBarometerForm ausführen.
 */
function createBarometerForm() {
  var items = [
    'Forschende sollten die Öffentlichkeit über ihre Arbeit informieren.',
    'Wissenschaftliche Forschung sollte staatlich unterstützt werden.',
    'Politische Entscheidungen sollten auf wissenschaftlichen Erkenntnissen beruhen.',
    'Leute wie ich sollten mitentscheiden, zu welchen Themen geforscht wird.',
    'Forschende wissen am besten, was gut für die Zukunft der Schweiz ist.',
    'Forschende stecken mit Politik und Wirtschaft unter einer Decke.'
  ];

  var form = FormApp.create('Wissenschaft, Politik und Öffentlichkeit');
  form.setDescription(
    'Wie sollte das Verhältnis von Wissenschaft, Politik und Öffentlichkeit ' +
    'aussehen? Sechs Aussagen aus dem Wissenschaftsbarometer Schweiz. ' +
    'Die Teilnahme ist anonym und freiwillig; die aggregierten Ergebnisse ' +
    'werden in der Vorlesung und auf der Kurswebseite gezeigt.');
  form.setCollectEmail(false);
  form.setLimitOneResponsePerUser(false);
  form.setShuffleQuestions(false);
  form.setProgressBar(true);

  items.forEach(function (text) {
    form.addScaleItem()
      .setTitle(text)
      .setBounds(1, 5)
      .setLabels('stimme überhaupt nicht zu', 'stimme voll und ganz zu')
      .setRequired(true);
  });

  var ss = SpreadsheetApp.create('Wissenschaftsbarometer Vorlesung – Antworten');
  var emptyName = ss.getSheets()[0].getName();   // leeres Standardblatt merken

  form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());
  SpreadsheetApp.flush();

  // Die Antworten landen in einem NEUEN Blatt; das leere Standardblatt (gid=0)
  // bliebe sonst stehen und R würde beim Lesen darauf zeigen.
  var book = SpreadsheetApp.openById(ss.getId());
  if (book.getSheets().length > 1) {
    var leftover = book.getSheetByName(emptyName);
    if (leftover && leftover.getLastRow() === 0) book.deleteSheet(leftover);
  }
  var responses = book.getSheets()[0];

  Logger.log('Formular (teilen):  %s', form.getPublishedUrl());
  Logger.log('Bearbeiten:         %s', form.getEditUrl());
  Logger.log('Antworttabelle:     %s#gid=%s', book.getUrl(), responses.getSheetId());
  Logger.log('--> Diese Adresse (mit #gid=) kommt in params$sheet_csv.');
  Logger.log('--> Vorher in der Tabelle: Freigeben > Jede Person mit dem Link > Betrachter');
}
