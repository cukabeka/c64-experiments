Hier ist eine einfache Dokumentation für die GEOS64-Programmiersprache GeoCom im Markdown-Format. Sie enthält eine Übersicht, grundlegende Syntaxregeln, eine Beschreibung der Struktur sowie kleine, sinnvolle Beispielprogramme, die den Stil moderner Programmierdokumentationen widerspiegeln. Ich habe die Informationen aus bereitgestellten Dokumenten zusammengefasst und angepasst.

---

# GeoCom Dokumentation

GeoCom ist eine BASIC-ähnliche Programmiersprache und ein Compiler für die GEOS-Umgebung auf dem Commodore 64. Sie wurde entwickelt, um Anwendungen mit grafischer Benutzeroberfläche für GEOS zu erstellen, und bietet Unterstützung für Mausinteraktionen, Prozesse und GEOS-spezifische APIs. Diese Dokumentation bietet eine Einführung in die Sprache, ihre Syntax und Struktur sowie praktische Beispiele.

## Übersicht

- **Entwickler:** Falk Rehwagen
- **Plattform:** GEOS auf Commodore 64
- **Version:** Vollversion in Englisch und Deutsch verfügbar
- **Eigenschaften:**
  - Keine Zeilennummern, stattdessen Labels und Subroutinen
  - Unterstützung für GEOS-APIs, VLIR-Dateien und Prozesse
  - Grafik- und Mausunterstützung
  - Eingabe in geoWrite, Kompilierung mit dem GeoCom-Compiler

## Programmstruktur

Jedes GeoCom-Programm besteht aus drei Hauptabschnitten, die am Anfang gruppiert werden müssen:

1. **Definition Section**: Metadaten des Programms
   - `NAME`: Programmname
   - `CLASS`: Klassenname und Version
   - `AUTHOR`: Autor des Programms
2. **Declaration Section**: Variablen, Labels und Objekte
   - Variablen: `INTVAR`, `BYTEVAR`, `STRVAR <Länge>`, `ROW <Größe> <Typ> VAR`
   - Labels: `LABEL`
   - Objekte: `OBJFILE`, `OBJECT`
3. **Command Section**: Der eigentliche Programmcode
   - Enthält Steuerbefehle, Schleifen, Grafikbefehle und Subroutinen

Kommentare beginnen mit einem Backquote (\`).

## Spracheigenschaften

- **Variablen**: Müssen deklariert werden, keine lokalen Variablen in Subroutinen.
- **Schleifen**: `REPEAT...UNTIL`, `WHILE...DO...LOOP` (kein `FOR...NEXT`).
- **Subroutinen**: Mit `GOSUB` aufgerufen, keine Parameter oder Rückgabewerte.
- **Ausdrücke**: Müssen in Klammern stehen, z. B. `x = (y + 1)`.
- **Arrays**: Mit `ROW` deklariert, z. B. `ROW 6 BYTEVAR rolls` (Indizes von 0 bis 5).
- **Strings**: Nullterminiert, mit maximaler Länge, z. B. `STRVAR 64; status`.
- **Grafik**: Befehle wie `RECT`, `FRAME`, `PATTERN`, `PRINT` mit Stil-Escapes (z. B. `/B` für fett).

## Beispielprogramme

### Beispiel 1: Einfacher Würfelwurf

Dieses Programm simuliert einen Würfelwurf (d6) und zeigt das Ergebnis an.

```geoCom
` Würfelwurf-Beispiel
` Definition Section
NAME "dice"
CLASS "dice        1.0"
AUTHOR "Cenbe"

` Declaration Section
INTVAR random AT $850a ` Zufallszahl von GEOS
INTVAR d6, roll
BYTEVAR i
STRVAR 64; result
LABEL roll_dice, show_result

` Command Section
d6 = (65520 / 6) ` Divisor für d6
CLS
GOSUB roll_dice
result = ("Du hast eine " + (STR roll) + " gewürfelt!")
GOSUB show_result
END

@roll_dice
CALL $c187 ` GEOS GetRandom
roll = (LOW(((random - 1) / d6) + 1))
RETURN

@show_result
SETPOS 100, 100
PRINT result;
RETURN
```

**Erklärung**:  
- `d6` wird als Divisor für einen sechsseitigen Würfel berechnet.
- `CALL $c187` ruft die GEOS-Zufallsfunktion auf.
- Das Ergebnis wird in `roll` gespeichert und als String ausgegeben.

### Beispiel 2: Mausbasierte Schaltfläche

Dieses Programm zeigt eine Schaltfläche, die bei einem Mausklick eine Nachricht anzeigt.

```geoCom
` Maus-Schaltfläche Beispiel
` Definition Section
NAME "button"
CLASS "button      1.0"
AUTHOR "Cenbe"

` Declaration Section
BYTEVAR mousedata AT $84c0 ` Mausstatus
BYTEVAR clicked
STRVAR 64; message
LABEL draw_button, check_click, show_message

` Command Section
CLS
clicked = 0
message = "Button wurde geklickt!"
GOSUB draw_button
MOUSE ON
MAINLOOP

@draw_button
FRAME 100, 50, 200, 80, 255 ` Rahmen der Schaltfläche
SETPOS 120, 60
PRINT "Klick mich!";
RETURN

@check_click
IF ((mousedata AND $80) <> 0): RETURN: ENDIF ` Maus losgelassen?
IF (REGION 100, 50, 200, 80) THEN
    clicked = 1
    GOSUB show_message
ENDIF
RETURN

@show_message
RECT 90, 90, 210, 110 ` Hintergrund für Nachricht
SETPOS 100, 100
PRINT message;
RETURN
```

**Erklärung**:  
- `FRAME` zeichnet eine Schaltfläche.
- `REGION` prüft, ob die Maus innerhalb des Bereichs klickt.
- Bei einem Klick wird eine Nachricht angezeigt.

### Beispiel 3: Attributsanzeige

Ein einfaches Beispiel, inspiriert von `cnc`, das Attribute anzeigt.

```geoCom
` Attributsanzeige Beispiel
` Definition Section
NAME "attributes"
CLASS "attr        1.0"
AUTHOR "Cenbe"

` Declaration Section
ROW 6 BYTEVAR attributes
BYTEVAR i
STRVAR 64; output
LABEL show_attributes

` Command Section
CLS
i = 0: REPEAT
    (attributes<i>) = (10 + i) ` Beispielwerte
    INC i
UNTIL (i == 6)
GOSUB show_attributes
END

@show_attributes
FRAME 10, 20, 150, 100, 255
SETPOS 20, 30
PRINT "/BAttribute:/P";
i = 0: REPEAT
    SETPOS 20, (40 + (i * 10))
    output = ("Attribut " + (STR i) + ": " + (STR (attributes<i>)))
    PRINT output;
    INC i
UNTIL (i == 6)
RETURN
```

**Erklärung**:  
- Ein Array `attributes` wird mit Beispielwerten gefüllt.
- `FRAME` und `PRINT` zeigen die Attribute in einem Rahmen an.
- `/B` macht den Titel fett.

## Wichtige Hinweise

- **Eingabe**: Code wird in geoWrite geschrieben.
- **Kompilierung**: Der GeoCom-Compiler erzeugt eine Fehlerliste, aber es gibt keinen Debugger.
- **Speicher**: Standardmäßig 14 KB verfügbar, konfigurierbare Adressbereiche (siehe "memory map").
- **Einschränkungen**: Keine Unterstützung für uIEC, begrenzte Assembler-Integration.

## Ressourcen

- **Lyonlab Commodore 64 Seiten**: [lyonlabs.org](http://lyonlabs.org)
- **GeoCom Vollversion**: Auch bei Lyonlabs

---

Diese Dokumentation bietet eine moderne, übersichtliche Einführung in GeoCom mit praktischen Beispielen, die sowohl Anfängern als auch erfahrenen GEOS-Entwicklern den Einstieg erleichtern. Sie spiegelt den Stil aktueller Programmierdokumentationen wider, indem sie klare Struktur, Codebeispiele und Erklärungen kombiniert.



---

# GeoCom-Referenzhandbuch

Willkommen beim GeoCom-Referenzhandbuch, einer umfassenden Dokumentation für die BASIC-ähnliche Programmiersprache GeoCom, die für die GEOS-Umgebung auf dem Commodore 64 entwickelt wurde. Diese Dokumentation bietet detaillierte Informationen zu Syntax, Befehlen, Variablen, Strukturen und Beispielen.


## Inhaltsverzeichnis

1. [Einführung](#einführung)
2. [Programmstruktur](#programmstruktur)
3. [Variablen und Datentypen](#variablen-und-datentypen)
4. [Steuerstrukturen](#steuerstrukturen)
5. [Grafik- und Eingabebefehle](#grafik-und-eingabebefehle)
6. [GEOS-spezifische Funktionen](#geos-spezifische-funktionen)
7. [Befehlsreferenz](#befehlsreferenz)
8. [Beispiele](#beispiele)
9. [Anmerkungen und Einschränkungen](#anmerkungen-und-einschränkungen)

---

## Einführung

GeoCom ist eine Programmiersprache, die speziell für die Erstellung von GEOS-Anwendungen auf dem Commodore 64 entwickelt wurde. Sie kombiniert BASIC-ähnliche Syntax mit GEOS-spezifischen Funktionen für grafische Benutzeroberflächen, Mausunterstützung und Prozessverwaltung. Programme werden in geoWrite geschrieben und mit dem GeoCom-Compiler in ausführbare GEOS-Anwendungen übersetzt.

---

## Programmstruktur

Jedes GeoCom-Programm besteht aus drei Abschnitten, die in dieser Reihenfolge am Anfang des Quellcodes stehen müssen:

### Definition Section
Definiert Metadaten des Programms.

- **`NAME <string>`**  
  Der Name des Programms (max. 16 Zeichen).  
  Beispiel: `NAME "MyApp"`

- **`CLASS <string>`**  
  Der Klassenname (max. 10 Zeichen) gefolgt von einem Versionsstring (max. 5 Zeichen).  
  Beispiel: `CLASS "MyApp     1.0"`

- **`AUTHOR <string>`**  
  Der Autor des Programms (max. 16 Zeichen).  
  Beispiel: `AUTHOR "Cenbe"`

### Declaration Section
Deklariert Variablen, Labels und Objekte.

- **Variablen**: Siehe [Variablen und Datentypen](#variablen-und-datentypen).
- **Labels**: `LABEL <name>` – Markiert Sprungziele für `GOSUB` oder `GOTO`.  
  Beispiel: `LABEL myRoutine`
- **Objekte**: `OBJFILE <filename>` oder `OBJECT <type> <name>` – Für VLIR-Dateien oder GEOS-Objekte.

### Command Section
Enthält den ausführbaren Code mit Befehlen, Schleifen und Subroutinen.

- Kommentare beginnen mit einem Backquote (\`):  
  Beispiel: `` ` Dies ist ein Kommentar ``

---

## Variablen und Datentypen

Alle Variablen müssen in der Declaration Section deklariert werden. Lokale Variablen in Subroutinen werden nicht unterstützt.

### Datentypen

- **`INTVAR <name> [AT <address>]`**  
  16-Bit-Ganzzahl (0 bis 65535). Optional mit fester Speicheradresse.  
  Beispiel: `INTVAR counter` oder `INTVAR random AT $850a`

- **`BYTEVAR <name> [AT <address>]`**  
  8-Bit-Ganzzahl (0 bis 255).  
  Beispiel: `BYTEVAR flag`

- **`STRVAR <length>; <name>`**  
  Nullterminierter String mit maximaler Länge (1 bis 255 Bytes).  
  Beispiel: `STRVAR 64; message`

- **`ROW <size> <type> VAR <name>`**  
  Eindimensionales Array mit `<size>` Elementen (Indizes 0 bis size-1).  
  Beispiel: `ROW 6 BYTEVAR scores`

### Operationen

- **Zuweisung**: `variable = (expression)`  
  Beispiel: `x = (y + 5)`
- **Verketten von Strings**: Mit `+`  
  Beispiel: `message = ("Hallo " + name)`
- **Typkonvertierung**: `STR <number>` (zahl zu string)  
  Beispiel: `text = (STR 42)`

---

## Steuerstrukturen

GeoCom bietet mehrere Möglichkeiten zur Programmsteuerung.

### Bedingungen

- **`IF <condition> THEN`**  
  Führt einen Block aus, wenn die Bedingung wahr ist. Mit `ENDIF` beendet.  
  Syntax:  
  ```
  IF (x > 5) THEN
      PRINT "x ist groß";
  ENDIF
  ```
- **Inline-IF**:  
  `IF <condition>: <statement>: ENDIF`  
  Beispiel: `IF (flag = 1): PRINT "Flag gesetzt";: ENDIF`

### Schleifen

- **`REPEAT ... UNTIL <condition>`**  
  Wiederholt einen Block, bis die Bedingung erfüllt ist.  
  Beispiel:  
  ```
  i = 0
  REPEAT
      INC i
  UNTIL (i = 10)
  ```

- **`WHILE <condition> DO ... LOOP`**  
  Führt einen Block aus, solange die Bedingung wahr ist.  
  Beispiel:  
  ```
  WHILE (x < 100) DO
      INC x
  LOOP
  ```

### Sprungbefehle

- **`GOTO <label>`**  
  Springt zu einem Label.  
  Beispiel: `GOTO end`

- **`GOSUB <label>` / `RETURN`**  
  Ruft eine Subroutine auf und kehrt zurück.  
  Beispiel:  
  ```
  GOSUB drawScreen
  END

  @drawScreen
  CLS
  RETURN
  ```

---

## Grafik- und Eingabebefehle

GeoCom unterstützt GEOS-Grafikfunktionen und Mausinteraktionen.

### Grafikbefehle

- **`CLS`**  
  Löscht den Bildschirm.

- **`SETPOS <x>, <y>`**  
  Setzt die Cursorposition (x: 0-319, y: 0-199).  
  Beispiel: `SETPOS 100, 50`

- **`PRINT <expression> [;]`**  
  Gibt Text oder Variablen aus. Mit `;` bleibt der Cursor in der Zeile.  
  Stil-Escapes: `/B` (fett), `/P` (normal), `/I` (kursiv), `/U` (unterstrichen).  
  Beispiel: `PRINT "/BHello/P World";`

- **`RECT <x1>, <y1>, <x2>, <y2>`**  
  Zeichnet ein gefülltes Rechteck.  
  Beispiel: `RECT 50, 50, 150, 100`

- **`FRAME <x1>, <y1>, <x2>, <y2>, <pattern>`**  
  Zeichnet einen Rahmen mit Muster (0-255).  
  Beispiel: `FRAME 10, 10, 200, 50, 255`

- **`PATTERN <value>`**  
  Setzt das Füllmuster (0-255).  
  Beispiel: `PATTERN 170`

### Eingabebefehle

- **`MOUSE ON`**  
  Aktiviert die Mausunterstützung.

- **`REGION <x1>, <y1>, <x2>, <y2>`**  
  Prüft, ob der Mauszeiger im Bereich ist (Rückgabewert: 1 = ja, 0 = nein).  
  Beispiel: `IF (REGION 100, 50, 200, 80) THEN`

- **`INPUT <string_var>`**  
  Liest Benutzereingabe in einen String.  
  Beispiel: `INPUT name`

---

## GEOS-spezifische Funktionen

- **`CALL <address>`**  
  Ruft eine GEOS-Routine an einer Speicheradresse auf.  
  Beispiel: `CALL $c187` (GetRandom)

- **`VLIR <command>`**  
  Arbeitet mit VLIR-Dateien (Variable Length Index Record).  
  Beispiel: `VLIR LOAD "datafile"`

- **`MAINLOOP`**  
  Startet die Hauptereignisschleife für GEOS-Events.

- **`LOW(<expression>)`**  
  Gibt das untere Byte eines 16-Bit-Werts zurück.  
  Beispiel: `byte = (LOW(word))`

---

## Befehlsreferenz

Hier eine alphabetische Liste der wichtigsten Befehle:

| Befehl            | Beschreibung                                      | Beispiel                             |
|-------------------|--------------------------------------------------|--------------------------------------|
| `CALL <addr>`     | Ruft GEOS-Routine auf                           | `CALL $c187`                        |
| `CLS`             | Löscht den Bildschirm                           | `CLS`                               |
| `END`             | Beendet das Programm                            | `END`                               |
| `FRAME`           | Zeichnet einen Rahmen                           | `FRAME 10, 10, 100, 50, 255`        |
| `GOSUB <label>`   | Ruft eine Subroutine auf                        | `GOSUB draw`                        |
| `GOTO <label>`    | Springt zu einem Label                          | `GOTO start`                        |
| `IF ... THEN`     | Bedingte Ausführung                            | `IF (x > 0) THEN`                   |
| `INC <var>`       | Erhöht eine Variable um 1                      | `INC counter`                       |
| `INPUT <var>`     | Liest Benutzereingabe                           | `INPUT name`                        |
| `MOUSE ON`        | Aktiviert Mausunterstützung                    | `MOUSE ON`                          |
| `PRINT <expr>`    | Gibt Text oder Werte aus                       | `PRINT "Hallo";`                    |
| `RECT`            | Zeichnet ein Rechteck                          | `RECT 50, 50, 150, 100`             |
| `REGION`          | Prüft Mausposition                             | `IF (REGION 10, 10, 50, 50) THEN`   |
| `REPEAT ... UNTIL`| Schleife bis Bedingung erfüllt                 | `REPEAT ... UNTIL (x = 5)`          |
| `RETURN`          | Rückkehr aus Subroutine                        | `RETURN`                            |
| `SETPOS <x>, <y>` | Setzt Cursorposition                           | `SETPOS 100, 100`                   |
| `WHILE ... LOOP`  | Schleife solange Bedingung wahr                | `WHILE (x < 10) DO ... LOOP`        |

---

## Beispiele

### Beispiel 1: Zufallsgenerator

```geoCom
` Definition Section
NAME "randomGen"
CLASS "rand       1.0"
AUTHOR "Cenbe"

` Declaration Section
INTVAR random AT $850a
BYTEVAR result
STRVAR 64; output
LABEL roll, display

` Command Section
CLS
GOSUB roll
output = ("Ergebnis: " + (STR result))
GOSUB display
END

@roll
CALL $c187 ` GEOS GetRandom
result = (LOW(((random - 1) / 43) + 1)) ` 1-6
RETURN

@display
SETPOS 100, 100
PRINT output;
RETURN
```

### Beispiel 2: Interaktives Menü

```geoCom
` Definition Section
NAME "menu"
CLASS "menu       1.0"
AUTHOR "Cenbe"

` Declaration Section
BYTEVAR mousedata AT $84c0
BYTEVAR choice
LABEL draw_menu, check_input

` Command Section
CLS
choice = 0
MOUSE ON
GOSUB draw_menu
MAINLOOP

@draw_menu
FRAME 50, 50, 150, 80, 255
SETPOS 60, 60
PRINT "Option 1";
FRAME 50, 90, 150, 120, 255
SETPOS 60, 100
PRINT "Option 2";
RETURN

@check_input
IF ((mousedata AND $80) <> 0): RETURN: ENDIF
IF (REGION 50, 50, 150, 80) THEN
    choice = 1
    CLS
    SETPOS 100, 100
    PRINT "Option 1 gewählt";
ENDIF
IF (REGION 50, 90, 150, 120) THEN
    choice = 2
    CLS
    SETPOS 100, 100
    PRINT "Option 2 gewählt";
ENDIF
RETURN
```

---

## Anmerkungen und Einschränkungen

- **Speicher**: Standardmäßig 14 KB verfügbar (siehe "memory map" im Handbuch).
- **Fehlerbehandlung**: Der Compiler generiert eine Fehlerliste, aber es gibt keinen interaktiven Debugger.
- **Hardware**: Keine Unterstützung für uIEC-Laufwerke.
- **Subroutinen**: Keine Parameter oder Rückgabewerte möglich.
