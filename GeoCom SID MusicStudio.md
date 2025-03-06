Hier ist ein GeoCom-Programmbeispiel, das den SID-Chip (Sound Interface Device) des Commodore 64 nutzt, um ein interaktives Musik-Interface zu erstellen. Die Maus steuert dabei bis zu dreistimmige Klänge, indem die X- und Y-Positionen Parameter wie Lautstärke, Tonhöhe, Wellenform und Filter beeinflussen. Ich berücksiche die Passage aus der GeoCom-Dokumentation und verwende `PEEK` und `POKE`, um direkt auf den SID zuzugreifen, sowie `INITIO` und `DONIO` für den Systemzugriff.

---

### Beispielprogramm: Mausgesteuerte SID-Musik

```geoCom
` Mausgesteuerte SID-Musik
` Definition Section
NAME "MouseMusic"
CLASS "MouseMusic   1.0"
AUTHOR "AI"

` Declaration Section
BYTEVAR mousedata AT $84c0 ` Mausstatus
BYTEVAR mouse_x AT $84c1  ` X-Position (Low-Byte)
BYTEVAR mouse_y AT $84c3  ` Y-Position
BYTEVAR voice1_freq, voice1_vol, voice1_wave, voice2_freq, filter
INTVAR sid_base AT $d400   ` SID-Basisadresse
STRVAR 64; status
LABEL init_sid, update_sound, draw_interface

` Command Section
CLS
MOUSE ON
GOSUB init_sid
GOSUB draw_interface
MAINLOOP
    GOSUB update_sound
    SETPOS 20, 180
    status = ("X: " + (STR mouse_x) + " Y: " + (STR mouse_y))
    PRINT status;
END

@init_sid
` SID zurücksetzen und initialisieren
INITIO
POKE (sid_base + 24), 15  ` Master-Lautstärke auf Maximum
POKE (sid_base + 5), 0    ` Voice 1: Attack/Decay
POKE (sid_base + 6), 240  ` Voice 1: Sustain/Release
POKE (sid_base + 12), 0   ` Voice 2: Attack/Decay
POKE (sid_base + 13), 240 ` Voice 2: Sustain/Release
POKE (sid_base + 23), 0   ` Filter aus für Voice 3
DONIO
RETURN

@update_sound
` Mauspositionen lesen und SID-Parameter setzen
INITIO
` Voice 1: Tonhöhe (X-Pos), Lautstärke (Y-Pos), Dreieckwelle
voice1_freq = (mouse_x / 2) ` Tonhöhe von X (0-127)
voice1_vol = (mouse_y / 16) ` Lautstärke von Y (0-15)
POKE (sid_base + 0), voice1_freq      ` Frequenz Low
POKE (sid_base + 1), 0                ` Frequenz High
POKE (sid_base + 4), 17               ` Dreieckwelle + Gate an

` Voice 2: Tonhöhe (X-Pos + Offset), Sägezahnwelle
voice2_freq = ((mouse_x / 2) + 20)    ` Leicht versetzte Tonhöhe
POKE (sid_base + 7), voice2_freq      ` Frequenz Low
POKE (sid_base + 8), 0                ` Frequenz High
POKE (sid_base + 11), 33              ` Sägezahnwelle + Gate an

` Filter: Resonanz von Y-Pos
filter = (mouse_y / 16)               ` Filter Cutoff von Y (0-15)
POKE (sid_base + 21), filter          ` Filter Cutoff Low
POKE (sid_base + 22), 0               ` Filter Cutoff High
POKE (sid_base + 23), 15              ` Resonanz
POKE (sid_base + 24), (15 OR $70)     ` Lautstärke + Hochpassfilter
DONIO
RETURN

@draw_interface
` Einfaches Interface zeichnen
FRAME 10, 10, 310, 190, 255  ` Rahmen für Bewegungsfläche
SETPOS 20, 20
PRINT "/BX-Achse:/P Tonhöhe";
SETPOS 20, 30
PRINT "/BY-Achse:/P Lautstärke & Filter";
SETPOS 20, 40
PRINT "Bewege die Maus für Klang!";
RETURN
```

---

### Erklärung des Programms

#### Funktionalität
- **Maussteuerung**: 
  - **X-Position** (`mouse_x`, 0-255): Steuert die Tonhöhe (Frequenz) von Voice 1 und Voice 2. Voice 2 ist um 20 Einheiten versetzt, um einen harmonischen Effekt zu erzeugen.
  - **Y-Position** (`mouse_y`, 0-199): Beeinflusst die Lautstärke (Voice 1) und den Filter-Cutoff (für beide Stimmen).
- **SID-Parameter**:
  - **Voice 1**: Nutzt eine Dreieckwelle (`17` im Control Register), Tonhöhe basiert auf `mouse_x`, Lautstärke auf `mouse_y`.
  - **Voice 2**: Nutzt eine Sägezahnwelle (`33`), Tonhöhe leicht versetzt von Voice 1.
  - **Filter**: Hochpassfilter aktiviert, Cutoff-Frequenz von `mouse_y` abhängig.
- **Interface**: Ein Rahmen zeigt den Bereich, in dem die Maus bewegt werden kann, mit einer kurzen Anleitung.

#### SID-Zugriff
- **Basisadresse**: `$d400` (SID-Register beginnen hier).
- **Register**:
  - `$d400-$d401`: Frequenz Voice 1 (Low/High).
  - `$d404`: Steuerregister Voice 1 (Wellenform + Gate).
  - `$d407-$d408`: Frequenz Voice 2.
  - `$d40b`: Steuerregister Voice 2.
  - `$d415-$d416`: Filter Cutoff (Low/High).
  - `$d417`: Filtersteuerung (Resonanz, Filtermodus).
  - `$d418`: Master-Lautstärke und Filtermodus.
- **`INITIO`/`DONIO`**: Erforderlich, um den SID direkt zu manipulieren, da GeoCom-Interrupts währenddessen pausiert werden (Maus und Tastatur sind dann inaktiv).

#### Klangverhalten
- Beim Bewegen der Maus nach rechts (X erhöht) steigt die Tonhöhe.
- Beim Bewegen nach unten (Y erhöht) wird der Klang lauter und der Filter öffnet sich, was den Klang heller macht.
- Die Kombination aus Dreieck- und Sägezahnwelle erzeugt einen interessanten, vielschichtigen Klang.

#### Einschränkungen
- Während `INITIO` und `DONIO` ist die Maussteuerung unterbrochen, was zu kurzen "Rucklern" führen kann. Dies ist durch die SID-Dokumentation in GeoCom bedingt.
- Keine dritte Stimme hier, um die Übersichtlichkeit zu wahren, aber sie könnte z. B. mit einer Rechteckwelle (`65`) und einer weiteren Frequenz (`mouse_x / 3`) hinzugefügt werden.

---

### Wie man es benutzt
1. Schreibe den Code in geoWrite unter GEOS.
2. Kompiliere ihn mit dem GeoCom-Compiler.
3. Starte das Programm und bewege die Maus im Fenster, um Klänge zu erzeugen.

### Erweiterungsideen
- **Dritte Stimme**: Füge Voice 3 mit `POKE (sid_base + 14), freq` und `POKE (sid_base + 18), 65` (Rechteckwelle) hinzu.
- **Wellenformwechsel**: Nutze `IF`-Bedingungen, um die Wellenform basierend auf X/Y-Bereichen zu ändern (z. B. `IF (mouse_x > 128) THEN POKE (sid_base + 4), 65`).
- **Filtermodi**: Experimentiere mit `$10` (Tiefpass), `$20` (Bandpass) oder `$40` (Hochpass) in `$d418`.
