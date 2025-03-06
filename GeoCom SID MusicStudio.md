Hier ist ein Beispiel für ein GeoCom-Programm, das den SID-Chip des Commodore 64 nutzt, um ein interaktives Musik-Interface zu erstellen. Dabei wird die Mausposition auf dem Bildschirm verwendet, um bis zu dreistimmige Klänge zu erzeugen. Die X- und Y-Positionen der Maus steuern Parameter wie Lautstärke, Tonhöhe, Wellenform und Filter, sodass interessante Klangvariationen durch Mausbewegungen entstehen. Ich habe die SID-Programmierung mit `PEEK` und `POKE` basierend auf typischen Ansätzen aus der Commodore-64-Dokumentation (z. B. SID-Registerzugriff ab Adresse 54272) integriert und an GeoCom angepasst.

---

### GeoCom-Programm: "MouseMusic"

```geoCom
` MouseMusic: Interaktives SID-Musik-Interface mit Maussteuerung
` Definition Section
NAME "MouseMusic"
CLASS "music       1.0"
AUTHOR "AI"

` Declaration Section
BYTEVAR mx AT $84c0 ` Maus X-Position (low byte)
BYTEVAR my AT $84c1 ` Maus Y-Position
BYTEVAR sid AT $d400 ` SID-Basisadresse (54272 dezimal)
BYTEVAR volume, pitch1, pitch2, pitch3, wave1, wave2, wave3, filter
INTVAR temp
LABEL init_sid, update_sound, draw_cursor, main_loop

` Command Section
CLS
sid = 54272 ` SID-Basisadresse setzen
MOUSE ON ` Maus aktivieren
GOSUB init_sid
MAINLOOP ` Hauptschleife starten

@main_loop
GOSUB draw_cursor
GOSUB update_sound
GOTO main_loop

@init_sid
` SID zurücksetzen und initialisieren
FOR temp = 0 TO 24
    POKE (sid + temp), 0
NEXT
POKE (sid + 24), 15 ` Maximale Lautstärke
POKE (sid + 5), 9   ` Attack/Decay Stimme 1
POKE (sid + 6), 240 ` Sustain/Release Stimme 1
POKE (sid + 12), 9  ` Attack/Decay Stimme 2
POKE (sid + 13), 240` Sustain/Release Stimme 2
POKE (sid + 19), 9  ` Attack/Decay Stimme 3
POKE (sid + 20), 240` Sustain/Release Stimme 3
RETURN

@draw_cursor
CLS
SETPOS mx, my
PRINT "+"; ` Einfacher Mauszeiger
RETURN

@update_sound
` Parameter basierend auf Mausposition berechnen
volume = (my / 16) ` Y-Pos -> Lautstärke (0-15)
pitch1 = mx        ` X-Pos -> Tonhöhe Stimme 1 (0-255)
pitch2 = (mx / 2)  ` X-Pos / 2 -> Tonhöhe Stimme 2
pitch3 = (mx / 4)  ` X-Pos / 4 -> Tonhöhe Stimme 3

` Wellenformen basierend auf X-Position
IF (mx < 80) THEN
    wave1 = 17: wave2 = 17: wave3 = 17 ` Dreieck
ELSEIF (mx < 160) THEN
    wave1 = 33: wave2 = 33: wave3 = 33 ` Sägezahn
ELSE
    wave1 = 65: wave2 = 65: wave3 = 65 ` Rechteck
ENDIF

` Filter basierend auf Y-Position
IF (my < 60) THEN
    filter = 16 ` Low-Pass
ELSEIF (my < 120) THEN
    filter = 32 ` Band-Pass
ELSE
    filter = 64 ` High-Pass
ENDIF

` SID-Register setzen
POKE (sid + 24), volume ` Gesamtlautstärke
` Stimme 1
POKE (sid + 0), pitch1  ` Frequenz low byte
POKE (sid + 1), 1       ` Frequenz high byte (konstant)
POKE (sid + 4), wave1   ` Wellenform
` Stimme 2
POKE (sid + 7), pitch2
POKE (sid + 8), 1
POKE (sid + 11), wave2
` Stimme 3
POKE (sid + 14), pitch3
POKE (sid + 15), 1
POKE (sid + 18), wave3
` Filter
POKE (sid + 23), 7      ` Alle Stimmen filtern
POKE (sid + 21), (my / 2) ` Filter Cutoff
POKE (sid + 22), filter ` Filtermodus
RETURN
```

### Version mit korrekten IO-Befehlen

```geoCom
` SID-Maus-Klang-Interface
` Definition Section
NAME "sid_mouse"
CLASS "sidmouse    1.0"
AUTHOR "Grok/xAI"

` Declaration Section
BYTEVAR mousedata AT $84c0 ` Mausstatus
BYTEVAR mousex AT $84c1    ` X-Position (low byte)
BYTEVAR mousey AT $84c3    ` Y-Position
BYTEVAR voice1_freq, voice1_vol, voice1_wave
BYTEVAR voice2_freq, voice2_vol, voice2_wave
BYTEVAR voice3_freq, filter
LABEL init_sid, update_sound, draw_interface

` SID-Adressen
BYTEVAR sid_base AT $d400  ` SID-Startadresse
BYTEVAR sid_freq1_lo AT $d400  ` Stimme 1 Frequenz (low)
BYTEVAR sid_freq1_hi AT $d401  ` Stimme 1 Frequenz (high)
BYTEVAR sid_wave1 AT $d404     ` Stimme 1 Wellenform
BYTEVAR sid_vol AT $d418       ` Master-Lautstärke/Filter
BYTEVAR sid_freq2_lo AT $d407  ` Stimme 2 Frequenz (low)
BYTEVAR sid_freq2_hi AT $d408  ` Stimme 2 Frequenz (high)
BYTEVAR sid_wave2 AT $d40b     ` Stimme 2 Wellenform
BYTEVAR sid_freq3_lo AT $d40e  ` Stimme 3 Frequenz (low)
BYTEVAR sid_freq3_hi AT $d40f  ` Stimme 3 Frequenz (high)
BYTEVAR sid_wave3 AT $d411     ` Stimme 3 Wellenform

` Command Section
CLS
MOUSE ON
GOSUB init_sid
GOSUB draw_interface
MAINLOOP
    GOSUB update_sound
    WAIT 1 ` Kurze Pause für Stabilität
END

@init_sid
` SID zurücksetzen und initialisieren
INITIO
POKE sid_vol, 15    ` Maximale Lautstärke, kein Filter
POKE sid_wave1, 0   ` Stimme 1 aus
POKE sid_wave2, 0   ` Stimme 2 aus
POKE sid_wave3, 0   ` Stimme 3 aus
DONIO
RETURN

@draw_interface
` Einfaches Interface mit Bereichen für Stimmen
FRAME 0, 0, 319, 199, 255  ` Rahmen um den Bildschirm
SETPOS 10, 10
PRINT "/BVoice 1: Tonhöhe (X), Lautstärke (Y)";
SETPOS 10, 20
PRINT "Voice 2: Tonhöhe (X), Wellenform (Y)";
SETPOS 10, 30
PRINT "Voice 3: Tonhöhe (X), Filter (Y)";
RETURN

@update_sound
` Mauspositionen lesen und SID-Parameter aktualisieren
INITIO

` Stimme 1: Tonhöhe (X), Lautstärke (Y)
voice1_freq = (mousex / 2) ` X: 0-319 -> Frequenz 0-159
voice1_vol = (mousey / 13) ` Y: 0-199 -> Lautstärke 0-15
POKE sid_freq1_lo, (voice1_freq AND $ff)
POKE sid_freq1_hi, (voice1_freq / 256)
POKE sid_wave1, (17 + voice1_vol) ` Dreieckswelle + Gate + Lautstärke

` Stimme 2: Tonhöhe (X), Wellenform (Y)
voice2_freq = (mousex / 2)
voice2_wave = (mousey / 50) ` Y: 0-199 -> Wellenform (0-3: Dreieck, Sägezahn, Rechteck, Rauschen)
IF (voice2_wave == 0) THEN voice2_wave = 17: ENDIF  ` Dreieck
IF (voice2_wave == 1) THEN voice2_wave = 33: ENDIF  ` Sägezahn
IF (voice2_wave == 2) THEN voice2_wave = 65: ENDIF  ` Rechteck
IF (voice2_wave == 3) THEN voice2_wave = 129: ENDIF ` Rauschen
POKE sid_freq2_lo, (voice2_freq AND $ff)
POKE sid_freq2_hi, (voice2_freq / 256)
POKE sid_wave2, voice2_wave

` Stimme 3: Tonhöhe (X), Filter (Y)
voice3_freq = (mousex / 2)
filter = (mousey / 13) ` Y: 0-199 -> Filter 0-15
POKE sid_freq3_lo, (voice3_freq AND $ff)
POKE sid_freq3_hi, (voice3_freq / 256)
POKE sid_wave3, 65 ` Rechteckwelle für Stimme 3
POKE sid_vol, (15 + (filter * 16)) ` Lautstärke + Low-Pass-Filter

DONIO
RETURN
```

---

### Erklärung des Programms

#### Struktur
- **Definition Section**: Setzt den Namen, die Klasse und den Autor des Programms.
- **Declaration Section**: Definiert Variablen für Mausposition (`mx`, `my`), SID-Adresse (`sid`) und Parameter wie Lautstärke, Tonhöhe, Wellenform und Filter. Labels organisieren den Code.
- **Command Section**: Initialisiert den SID, aktiviert die Maus und startet eine Schleife, die den Cursor zeichnet und den Klang aktualisiert.

#### Funktionsweise
1. **Maussteuerung**:
   - `mx` und `my` lesen die Mausposition direkt aus den GEOS-Mausregistern (`$84c0` und `$84c1`).
   - Der Cursor wird mit `SETPOS` und `PRINT "+"` an der aktuellen Position gezeichnet.

2. **SID-Parameter**:
   - **Lautstärke**: `volume = (my / 16)` skaliert die Y-Position (0-191) auf den Lautstärkebereich 0-15 und wird in Register 24 (`sid + 24`) geschrieben.
   - **Tonhöhe**: 
     - Stimme 1: `pitch1 = mx` (0-255) direkt von der X-Position.
     - Stimme 2: `pitch2 = (mx / 2)` halbierte X-Position für eine harmonische Variation.
     - Stimme 3: `pitch3 = (mx / 4)` gevierte X-Position für eine tiefere Note.
     - Frequenz wird mit `POKE` in die Register `sid + 0/1` (Stimme 1), `sid + 7/8` (Stimme 2) und `sid + 14/15` (Stimme 3) geschrieben. Der high byte bleibt konstant bei 1 für Einfachheit.
   - **Wellenform**: 
     - Abhängig von `mx`: Dreieck (17) bei `mx < 80`, Sägezahn (33) bei `mx < 160`, Rechteck (65) sonst.
     - Register: `sid + 4` (Stimme 1), `sid + 11` (Stimme 2), `sid + 18` (Stimme 3).
   - **Filter**: 
     - Abhängig von `my`: Low-Pass (16) bei `my < 60`, Band-Pass (32) bei `my < 120`, High-Pass (64) sonst.
     - Filter-Cutoff: `my / 2` (0-95) in `sid + 21`.
     - Filtermodus in `sid + 22`, alle Stimmen werden mit `sid + 23 = 7` gefiltert.

3. **SID-Initialisierung**:
   - `init_sid` setzt alle SID-Register auf 0, stellt eine maximale Lautstärke (15) ein und definiert eine einfache ADSR-Hüllkurve (Attack/Decay und Sustain/Release) für alle drei Stimmen.

#### Interaktivität
- Beim Bewegen der Maus ändern sich die Klänge kontinuierlich:
  - **X-Achse**: Beeinflusst Tonhöhe (drei harmonische Ebenen) und Wellenform (Dreieck → Sägezahn → Rechteck).
  - **Y-Achse**: Steuert Lautstärke (oben laut, unten leise) und Filter (unten Low-Pass, Mitte Band-Pass, oben High-Pass).
- Das Ergebnis sind dynamische, dreistimmige Klanglandschaften, die sich durch Mausbewegungen organisch verändern.

#### Hinweise
- Die Frequenzberechnung ist vereinfacht (nur low byte variiert); für präzisere Tonhöhen könnte man den high byte mit `PEEK` und `POKE` dynamisch anpassen.
- Die Wellenform- und Filterwechsel sind diskret (in Zonen), könnten aber mit feineren Übergängen verfeinert werden.
- Dieses Programm nutzt die Stärken von GeoCom (Mausunterstützung, einfache Grafik) und des SID-Chips (drei Stimmen, Filter, Wellenformen).

---

Mit diesem Programm kannst du die Maus über den Bildschirm bewegen und eine Vielzahl interessanter Klänge erzeugen – ein kreatives Beispiel für die Kombination von GeoCom und SID-Musikprogrammierung!
