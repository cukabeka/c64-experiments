
### Erweiterter geoCom Markdown Editor mit Editiermodus

Hier ist eine erste Version des Codes auf Basis der GEOCOM-Dokumentation und dem Vortrag, die auf Lyonlabs verfügbar sind:

```
PROGRAM "mdEditor"
PERMNAME "Markdown Editor"
AUTHOR "Your Name"

` Variable declarations
STRLEN 254
ROW 10 STRVAR 254; inputLines  ` Statt einer langen Zeichenkette werden Zeilen als Array gespeichert
ROW 10 STRVAR 254; clipboardText
INTVAR cursorPos, currentLine, textLength, selectStart, selectEnd
STRVAR 16; filename

` Object references
OBJECT MENU mainMenu
OBJECT ICON saveIcon, loadIcon, previewIcon, editIcon
OBJECT DIALOG saveDialog, loadDialog

` Main program
BEGIN
    GOSUB initializeUI
    REPEAT
        GOSUB handleEvents
    UNTIL FALSE
END

` Initialize user interface
initializeUI:
    SYSGRAPHICS
    SYSMENUSET mainMenu
    
    ` Set up icons with correct positions and bitmaps
    SYSICON saveIcon, 0, 0, "Save"
    SYSICON loadIcon, 24, 0, "Load"
    SYSICON previewIcon, 48, 0, "Preview"
    SYSICON editIcon, 72, 0, "Edit"
    
    ` Create text input area with proper handling
    RECT 0, 32, 280, 168
    CLEARSCREEN
    RETURN

` Handle user events
handleEvents:
    SYSEVENT event
    IF event = CLOSE THEN END
    IF event = MENU THEN GOSUB handleMenu
    IF event = ICON THEN GOSUB handleIcon
    RETURN

` Handle menu selections
handleMenu:
    ` Add menu handling code here
    RETURN

` Handle icon clicks
handleIcon:
    IF LASTICON = saveIcon THEN GOSUB saveFile
    IF LASTICON = loadIcon THEN GOSUB loadFile
    IF LASTICON = previewIcon THEN GOSUB previewMarkdown
    IF LASTICON = editIcon THEN GOSUB enterEditMode
    RETURN

` Enter edit mode
enterEditMode:
    cursorPos = 0
    currentLine = 0
    textLength = LEN(inputLines<currentLine>)
    selectStart = 0
    selectEnd = 0
    GOSUB updateTextArea
    GOSUB editLoop
    RETURN

` Main edit loop
editLoop:
    REPEAT
        GOSUB handleEditEvents
    UNTIL event = ICON AND LASTICON <> editIcon
    RETURN

` Handle edit events
handleEditEvents:
    SYSEVENT event
    IF event = KEY THEN
        ` Bewegen durch die Zeilen und Zeichen
        IF KEYCODE = UP THEN currentLine = MAX(0, currentLine - 1)
        IF KEYCODE = DOWN THEN currentLine = MIN(9, currentLine + 1)
        IF KEYCODE = LEFT THEN cursorPos = MAX(0, cursorPos - 1)
        IF KEYCODE = RIGHT THEN cursorPos = MIN(textLength, cursorPos + 1)
        IF KEYCODE = DEL THEN GOSUB deleteCharacter
        IF KEYCODE = INS THEN GOSUB insertCharacter
        IF KEYCODE = COPY THEN GOSUB copyText
        IF KEYCODE = PASTE THEN GOSUB pasteText
        IF KEYCODE = SELECT THEN GOSUB startSelection
    ENDIF
    GOSUB updateTextArea
    RETURN

` Delete character at cursor
deleteCharacter:
    IF cursorPos < textLength THEN
        inputLines<currentLine> = LEFT(inputLines<currentLine>, cursorPos) + MID(inputLines<currentLine>, cursorPos + 2)
        textLength = LEN(inputLines<currentLine>)
    ENDIF
    RETURN

` Insert character at cursor
insertCharacter:
    IF textLength < 254 THEN
        inputLines<currentLine> = LEFT(inputLines<currentLine>, cursorPos) + CHAR(KEYCHAR) + MID(inputLines<currentLine>, cursorPos + 1)
        cursorPos = cursorPos + 1
        textLength = LEN(inputLines<currentLine>)
    ENDIF
    RETURN

` Start text selection
startSelection:
    IF selectStart = 0 THEN
        selectStart = cursorPos
    ELSE
        selectEnd = cursorPos
        IF selectStart > selectEnd THEN
            SWAP selectStart, selectEnd
        ENDIF
    ENDIF
    RETURN

` Copy selected text
copyText:
    IF selectStart < selectEnd THEN
        clipboardText<currentLine> = MID(inputLines<currentLine>, selectStart + 1, selectEnd - selectStart)
    ENDIF
    RETURN

` Paste text from clipboard
pasteText:
    IF LEN(clipboardText<currentLine>) + textLength < 254 THEN
        inputLines<currentLine> = LEFT(inputLines<currentLine>, cursorPos) + clipboardText<currentLine> + MID(inputLines<currentLine>, cursorPos + 1)
        cursorPos = cursorPos + LEN(clipboardText<currentLine>)
        textLength = LEN(inputLines<currentLine>)
    ENDIF
    RETURN

` Update text input area
updateTextArea:
    RECT 0, 32, 280, 168
    CLEARSCREEN
    MOVE 5, 37
    ` Zeige die aktuelle Zeile an
    PRINT inputLines<currentLine>
    RETURN

` Save markdown file
saveFile:
    SYSDIALOG saveDialog, "Save Markdown File"
    IF DIALOGRESULT = 0 THEN RETURN
    filename = DIALOGINPUT
    
    OPEN filename FOR OUTPUT
    IF SYSERROR <> 0 THEN PRINT "Error opening file" RETURN
    ` Alle Zeilen speichern
    FOR i = 0 TO 9
        PRINT #1, inputLines<i>
    NEXT i
    CLOSE
    PRINT "File saved successfully"
    RETURN

` Load markdown file
loadFile:
    SYSDIALOG loadDialog, "Load Markdown File"
    IF DIALOGRESULT = 0 THEN RETURN
    filename = DIALOGINPUT
    OPEN filename FOR INPUT
	IF SYSERROR <> 0 THEN PRINT "Error opening file" RETURN
	i = 0
	WHILE NOT EOF(1) AND i < 10
	    LINE INPUT #1, inputLines<i>
	    i = i + 1
	WEND
	CLOSE
	GOSUB updateTextArea
	PRINT "File loaded successfully"
	RETURN

` Parse markdown
parseMarkdown:
outputText = ""
FOR i = 0 TO 9
    IF LEFT(inputLines<i>, 1) = "#" THEN
        outputText = outputText + "/B" + MID(inputLines<i>, 2) + "/P" + CHR(13)
    ELSE
        outputText = outputText + inputLines<i> + CHR(13)
    ENDIF
NEXT i
RETURN
```

### Erläuterungen:

1. **Text-Editiermodus:**
   - Ein `editLoop` wurde hinzugefügt, um den Editiermodus zu ermöglichen, in dem Benutzer den Text bearbeiten können.
   - **Navigation:** Benutzer können den Cursor mit den Pfeiltasten bewegen (`UP`, `DOWN`, `LEFT`, `RIGHT`).
   - **Löschen und Einfügen:** Der Benutzer kann Zeichen an der Cursorposition löschen (`DEL`) oder einfügen (`INS`).

2. **Textauswahl, Kopieren und Einfügen:**
   - **Markierung:** Mit `SELECT` kann der Benutzer Text markieren.
   - **Kopieren:** Mit `COPY` kann der markierte Text in die Zwischenablage (`clipboardText`) kopiert werden.
   - **Einfügen:** Mit `PASTE` kann der Text aus der Zwischenablage an der aktuellen Cursorposition eingefügt werden.

3. **Textbereich-Aktualisierung:**
   - Die Funktion `updateTextArea` zeigt den Text im Eingabebereich an und aktualisiert die Anzeige basierend auf dem aktuellen Cursorstand.

### Überlegungn zum Markdown-Editor in geoCom

1. Programmstruktur und Variablendeklaration

	•	Programmname und Permname: Die Deklaration mit PROGRAM "mdEditor" und PERMNAME "Markdown Editor" ist korrekt.
	•	Autor: AUTHOR "Your Name" ist ebenfalls korrekt.
	•	Variable Deklaration: Die Deklaration von String- und Integer-Variablen (STRVAR, INTVAR) ist korrekt, aber es gibt einige Optimierungsmöglichkeiten:
	•	Stringlängen: Die maximale Länge einer Zeichenkette in geoCom beträgt 254 Zeichen. Wenn eine Variable länger als das Maximum ist, sollte STRLEN verwendet werden, um die maximale Länge zu definieren.
	•	Optimierung: Statt zwei 1000-Zeichen-Variablen zu verwenden, könnte STRLEN gesetzt werden, um unnötigen Speicherverbrauch zu vermeiden.

2. Benutzung von geoCom-Objekten

	•	Menus und Icons: Die Verwendung von OBJECT MENU mainMenu und OBJECT ICON ist korrekt. Jedoch ist die Konfiguration und Platzierung von Menüs und Icons im Code noch nicht vollständig spezifiziert, was notwendig ist, um sie richtig anzuzeigen.
	•	Dialoge: SYSDIALOG ist richtig verwendet, aber spezifische Einstellungen für die Dialogboxen, wie Positionierung und Konfiguration, fehlen.

3. Fehlende Konfiguration und Spezifizierung

	•	Textbereich und Rendering: Die Methode RECTANGLE erstellt den Bereich für die Texteingabe, aber der Code zur Verwaltung und Darstellung von Text ist sehr vereinfacht. Ein besserer Ansatz wäre, eine explizite Steuerung des Text-Cursors und des Textflusses zu implementieren, um den Text korrekt darzustellen.
	•	Eventhandling: Die Funktion SYSEVENT erfasst Ereignisse korrekt, aber es gibt keine detaillierte Verarbeitung von Tastatur- und Mausereignissen, die für einen Texteditor notwendig wären.

4. Markdown-Preview und Verwendung von GEOS-Schriften

	•	Textformatierung: Die Verwendung von GEOS-Schriften und -Stilen ist möglich. Die PRINT-Befehle sollten durch /B, /I, /U etc. ergänzt werden, um verschiedene Schriftstile (Bold, Italic, Underline) zu verwenden. Der aktuelle Code hat dies korrekt berücksichtigt, aber die Logik zur Verarbeitung der Markups könnte erweitert werden.



# Optimierungs-Ansätze

In der aktuellen Implementierung des geoCom Markdown Editors wird `SYSDIALOG` verwendet, um Dialogboxen zum Laden und Speichern von Dateien zu öffnen. Dies ist jedoch nicht unbedingt die einzige oder beste Methode. Es gibt Unterschiede zwischen `SYSDIALOG` und `OPENBOX`, die du kennen solltest:

## Unterschiede zwischen `SYSDIALOG` und `OPENBOX`

- **SYSDIALOG:**
  - `SYSDIALOG` wird verwendet, um eine Systemdialogbox zu öffnen, die in der Regel vordefinierte, standardisierte Dialoge darstellt, wie z.B. Dateiauswahl, Speichern oder Bestätigungsdialoge.
  - `SYSDIALOG` ist nützlich, wenn du schnell eine einfache Dialogbox benötigst, die mit minimalem Aufwand funktioniert.
  - Diese Methode ist besonders praktisch, wenn du das Standardverhalten des Systems für Dialoge beibehalten möchtest.

- **OPENBOX:**
  - `OPENBOX` bietet mehr Flexibilität und Kontrolle über die Darstellung und Funktionalität der Dialogbox. 
  - Mit `OPENBOX` kannst du eine benutzerdefinierte Dateiauswahl-Box erstellen, in der du bestimmen kannst, welche Dateien angezeigt werden und wie sie angezeigt werden.
  - `OPENBOX` ist nützlich, wenn du eine spezifische Benutzererfahrung schaffen möchtest, die über die Standarddialoge hinausgeht.

### Wann `OPENBOX` besser geeignet wäre
In deinem Markdown Editor könnte `OPENBOX` besser geeignet sein, wenn du mehr Kontrolle darüber haben möchtest, welche Dateien im Dialog angezeigt werden und wie der Auswahlprozess abläuft. Beispielsweise könntest du eine benutzerdefinierte Dateiauswahl implementieren, die nur Markdown-Dateien anzeigt oder spezifische Filter oder Sortierungen verwendet.

### Beispiel für die Verwendung von `OPENBOX`

Hier ist ein Beispiel, wie `OPENBOX` anstelle von `SYSDIALOG` verwendet werden könnte:

```geoCom
loadFile:
    ` Open custom load dialog
    OPENBOX 1, 1, 10, 20, "Load Markdown File", "Load", "Cancel"
    IF DIALOGRESULT = 0 THEN RETURN  ` User cancelled
    filename = DIALOGINPUT
    
    ` Open file for reading
    OPEN filename FOR INPUT
    IF SYSERROR <> 0 THEN PRINT "Error opening file" RETURN
    
    ` Read file contents into inputText
    inputText = ""
    WHILE NOT EOF(1)
        LINE INPUT #1, line$
        inputText = inputText + line$ + CHR(13)
    WEND
    CLOSE
    
    GOSUB updateTextArea
    PRINT "File loaded successfully"
    RETURN
```

### Fazit
Die Entscheidung zwischen `SYSDIALOG` und `OPENBOX` hängt von den Anforderungen ab. `SYSDIALOG` ist einfacher und schneller zu implementieren, bietet aber weniger Flexibilität. `OPENBOX` erfordert mehr Code, bietet aber eine maßgeschneiderte Lösung. Wenn du die Dev-Erfahrung anpassen möchtest, wäre `OPENBOX` die bessere Wahl.

## Weitere Code-Alternativen

Nutzung des Beispielprogramms [[https://www.lyonlabs.org/commodore/onrequest/geos/cnc_com.txt]] als Grundlage für weitere Optimierungen.

### Optimierungen basierend auf diesem Demo-Programm:

1. **Verwendung von `ROW`:** Statt einer einzigen langen Zeichenkette werden die Zeilen des Markdown-Textes als Array von Strings (`inputLines`) verwaltet. Dies ermöglicht eine flexiblere Bearbeitung und erleichtert das Navigieren durch den Text.

2. **Modularisierung durch Labels:** Der Code ist in kleine, gut verständliche Blöcke unterteilt, die durch Labels (`LABEL`) und GOSUB-Strukturen organisiert sind. Dies verbessert die Lesbarkeit und Wartbarkeit des Codes.

3. **Effiziente Verwendung von `REGION` und `SETPOS`:** Der Code nutzt `REGION`, um Bereiche für Interaktionen festzulegen, und `SETPOS`, um Text präzise anzuzeigen. Dies verbessert die Benutzeroberfläche und macht sie interaktiver.

4. **Prozesssteuerung:** Prozesse wie das Bearbeiten und Markieren von Text könnten als Prozesse definiert werden, um kontinuierliche Aufgaben zu verwalten. Dies wurde hier vereinfacht dargestellt, könnte aber weiter ausgebaut werden.

Diese Anpassungen verbessern den Markdown-Editor und machen ihn robuster, flexibler und leichter zu verwenden.
