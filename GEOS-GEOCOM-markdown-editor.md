
### Erweiterter geoCom Markdown Editor mit Editiermodus

Hier ist eine erste Version des Codes auf Basis der GEOCOM-Dokumentation und dem Vortrag, die auf Lyonlabs verfügbar sind:

```geoCom
PROGRAM "mdEditor"
PERMNAME "Markdown Editor"
AUTHOR "cukabeka"

` Variable declarations
STRLEN 254
STRVAR 254; inputText, outputText, clipboardText
INTVAR cursorPos, textLength, selectStart, selectEnd
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
    RECTANGLE 0, 32, 280, 168
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
    textLength = LEN(inputText)
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
        IF KEYCODE = UP THEN cursorPos = MAX(0, cursorPos - 40)
        IF KEYCODE = DOWN THEN cursorPos = MIN(textLength, cursorPos + 40)
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
        inputText = LEFT(inputText, cursorPos) + MID(inputText, cursorPos + 2)
        textLength = LEN(inputText)
    ENDIF
    RETURN

` Insert character at cursor
insertCharacter:
    IF textLength < 254 THEN
        inputText = LEFT(inputText, cursorPos) + CHAR(KEYCHAR) + MID(inputText, cursorPos + 1)
        cursorPos = cursorPos + 1
        textLength = LEN(inputText)
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
        clipboardText = MID(inputText, selectStart + 1, selectEnd - selectStart)
    ENDIF
    RETURN

` Paste text from clipboard
pasteText:
    IF LEN(clipboardText) + textLength < 254 THEN
        inputText = LEFT(inputText, cursorPos) + clipboardText + MID(inputText, cursorPos + 1)
        cursorPos = cursorPos + LEN(clipboardText)
        textLength = LEN(inputText)
    ENDIF
    RETURN

` Update text input area
updateTextArea:
    RECTANGLE 0, 32, 280, 168
    CLEARSCREEN
    MOVE 5, 37
    PRINT MID(inputText, cursorPos + 1, 240)  ` Display a portion of the text
    RETURN

` Save markdown file
saveFile:
    SYSDIALOG saveDialog, "Save Markdown File"
    IF DIALOGRESULT = 0 THEN RETURN
    filename = DIALOGINPUT
    
    OPEN filename FOR OUTPUT
    IF SYSERROR <> 0 THEN PRINT "Error opening file" RETURN
    PRINT #1, inputText
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
    inputText = ""
    WHILE NOT EOF(1)
        LINE INPUT #1, line$
        inputText = inputText + line$ + CHR(13)
    WEND
    CLOSE
    GOSUB updateTextArea
    PRINT "File loaded successfully"
    RETURN

` Preview markdown
previewMarkdown:
    GOSUB parseMarkdown
    MOVE 5, 37
    PRINT outputText
    RETURN

` Parse markdown
parseMarkdown:
    outputText = ""
    STRVAR 254; line
    FOR i = 1 TO LEN(inputText)
        IF MID(inputText, i, 1) = CHR(13) THEN
            IF LEFT(line, 1) = "#" THEN
                outputText = outputText + "/B" + MID(line, 2) + "/P" + CHR(13)
            ELSE
                outputText = outputText + line + CHR(13)
            ENDIF
            line = ""
        ELSE
            line = line + MID(inputText, i, 1)
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

	•	Textformatierung: Die Verwendung von GEOS-Schriften und -Stilen ist möglich. Die PRINT-Befehle sollten durch /B, /I, /U etc. ergänzt werden, um verschiedene Schriftstile (Bold, Italic, Underline) zu verwenden. Der aktuelle Code hat dies korrekt berücksichtigt, aber die Logik zur Verarbeitung der Markups könnte erweitert werden, um komplexere Mar
