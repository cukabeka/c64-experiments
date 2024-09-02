
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

## Weitere Code-Alterntaiven

Hier sind einige Stellen im Code, an denen alternative geoCom-Befehle in Betracht gezogen werden könnten, um Effizienz, Flexibilität oder Benutzerfreundlichkeit zu verbessern:

### 1. **SYSGRAPHICS**
   - **Aktueller Befehl:** `SYSGRAPHICS`
   - **Alternative:** `GRAPHICS ON`
   - **Erklärung:** Der Befehl `SYSGRAPHICS` schaltet die Grafikausgabe im System ein, was für einfache grafische Anwendungen geeignet ist. Wenn du jedoch spezifische Kontrolle über die Grafikausgabe benötigst, könnte der Befehl `GRAPHICS ON` zusammen mit spezifischen Grafikeinstellungen besser geeignet sein. Dadurch hast du mehr Kontrolle über die Grafikeinstellungen, wie z.B. Farbpaletten und Bildschirmmodi.

### 2. **SYSEVENT**
   - **Aktueller Befehl:** `SYSEVENT`
   - **Alternative:** `WAIT`
   - **Erklärung:** Der Befehl `SYSEVENT` wird verwendet, um auf Systemereignisse wie Tastendrücke oder Mausklicks zu warten. Eine Alternative könnte der Befehl `WAIT` sein, der ebenfalls auf ein Ereignis wartet, aber möglicherweise in bestimmten Situationen effizienter ist, da er weniger Systemressourcen beansprucht. `WAIT` kann auch in Kombination mit `KEY` verwendet werden, um explizit auf Tastendrücke zu warten.

### 3. **TEXT-Rendering**
   - **Aktueller Befehl:** `PRINT`
   - **Alternative:** `DISPLAY`, `PRINT AT`
   - **Erklärung:** Der Befehl `PRINT` wird verwendet, um Text an die aktuelle Cursorposition zu drucken. In einigen Fällen könnte `DISPLAY` oder `PRINT AT x, y` besser geeignet sein, um Text an einer bestimmten Position auszugeben, besonders wenn du präzise Kontrolle über die Platzierung des Textes benötigst.

### 4. **MARKIEREN UND KOPIEREN**
   - **Aktueller Befehl:** Es gibt keinen spezifischen Befehl für Textmarkierung und Kopieren, der im Code verwendet wird.
   - **Alternative:** `SELECT`, `COPYTEXT`, `PASTETEXT`
   - **Erklärung:** Wenn du Textmarkierung, Kopieren und Einfügen implementieren möchtest, könnten spezifische Befehle wie `SELECT`, `COPYTEXT` und `PASTETEXT` verwendet werden, um diese Aktionen effizienter und benutzerfreundlicher zu gestalten.

### 5. **STRING-MANIPULATION**
   - **Aktueller Befehl:** `MID`, `LEFT`, `RIGHT`
   - **Alternative:** `INSERT`, `DELETE`
   - **Erklärung:** Für das Einfügen oder Löschen von Text innerhalb einer Zeichenkette könnten `INSERT` und `DELETE` besser geeignet sein, da diese Befehle spezifische Operationen ausführen, ohne die gesamte Zeichenkette neu zu berechnen. Dies könnte die Effizienz bei komplexen String-Manipulationen verbessern.

### 6. **DIALOGAUSWAHL**
   - **Aktueller Befehl:** `SYSDIALOG`
   - **Alternative:** `OPENBOX`, `GETFILE`
   - **Erklärung:** Wie bereits besprochen, bietet `OPENBOX` mehr Flexibilität bei der Dateiauswahl, und `GETFILE` könnte verwendet werden, wenn du eine spezifische Datei vom Benutzer auswählen lassen möchtest, wobei nur eine Dateiart angezeigt wird.

### 7. **FEHLERBEHANDLUNG**
   - **Aktueller Befehl:** `IF SYSERROR <> 0 THEN`
   - **Alternative:** `ERROR`, `ONERROR`
   - **Erklärung:** Für eine robustere Fehlerbehandlung könntest du `ERROR` oder `ONERROR` verwenden, um gezielt auf verschiedene Fehlertypen zu reagieren und gegebenenfalls spezifische Fehlerbehandlungsroutinen zu definieren. Diese Befehle ermöglichen eine detailliertere und flexiblere Fehlerbehandlung, besonders in komplexeren Anwendungen.

### 8. **SPEICHER UND VARIABLEN**
   - **Aktueller Befehl:** `STRVAR 254; inputText`
   - **Alternative:** `DIM`, `ALLOCATE`
   - **Erklärung:** Bei der Verwaltung großer Datenmengen oder wenn du dynamisch Speicher für Variablen zuweisen musst, könnten `DIM` für Arrays oder `ALLOCATE` für Speicherzellen eine bessere Wahl sein. Diese Befehle ermöglichen eine präzisere Speicherverwaltung und können die Leistung bei komplexeren Datenstrukturen verbessern.

### Zusammenfassung:
Durch die Wahl besser geeigneter Befehle in geoCom kannst du die Effizienz, Flexibilität und Benutzerfreundlichkeit deines Markdown Editors erheblich verbessern. Die genannten Alternativen bieten dir mehr Kontrolle und können in spezifischen Anwendungsfällen besser funktionieren. Es lohnt sich, diese Alternativen in deinem Code zu prüfen und gegebenenfalls anzuwenden, um die bestmögliche Leistung und Benutzererfahrung zu erzielen.
