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
