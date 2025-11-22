# Copilot Instructions für C64/C128 GEOS Development

## Projektübersicht

Dieses Projekt richtet sich an die cross-platform Entwicklung von Programmen für das Commodore 64/128 GEOS-Betriebssystem. Es unterstützt zwei Hauptentwicklungswege:

1. **CC65-basierte C-Programme**: Cross-Kompilierung von C-Code zu GEOS-Applikationen mit dem cc65-Compiler.
2. **GeoCOM-Skripte**: Direkte Entwicklung von GeoCOM-Programmen, die in GEOS ausgeführt und kompiliert werden.

Das Setup läuft unter macOS mit VS Code, GitHub Copilot, cc65, VICE-Emulator und automatischen Build- und Transfer-Workflows.

## Zielsetzungen

- **Cross-Development in C**: Ermögliche die Erstellung von GEOS-Applikationen in C mit cc65, inklusive automatischer Kompilierung und Integration in GEOS-Disk-Images.
- **GeoCOM-Entwicklung**: Unterstütze die direkte Erstellung und das Testen von GeoCOM-Skripten mit nahtloser Übertragung in GEOS-Umgebungen.
- **Moderne Tooling**: Nutze VS Code mit Copilot für intelligente Code-Vorschläge, Debugging und Task-Management.
- **Automatische Workflows**: Implementiere Build-Skripte für Kompilierung, Disk-Erstellung und Emulator-Integration.
- **macOS-Kompatibilität**: Stelle sicher, dass alle Tools und Skripte unter macOS funktionieren.
- **Erweiterbarkeit**: Bereite die Struktur für zukünftige Sub-Repositories mit separaten GEOS-Projekten vor.

## Coding-Standards und Konventionen

### CC65 (C-Programme)
- Verwende die GEOS-API-Funktionen aus `<geos.h>` und `<conio.h>`.
- Halte den Code modular und kommentiert.
- Nutze cc65-spezifische Optimierungen für 6502-Architektur.
- Beispiel-Struktur:
  ```c
  #include <geos.h>
  #include <conio.h>

  void main(void) {
      // Initialisierung
      InitMouse();
      ClearScreen();

      // Hauptlogik
      cputs("Hallo GEOS!");

      // Endlosschleife für GEOS-Apps
      for(;;);
  }
  ```

### GeoCOM-Skripte
- Struktur: `PROGRAM "Name" PERMNAME "Beschreibung" BEGIN ... END END`
- Verwende klare, lesbare Syntax.
- Integriere Fehlerbehandlung und Debugging-Ausgaben.
- Beispiel-Struktur:
  ```
  PROGRAM "MeinProgramm"
  PERMNAME "Beschreibung meines Programms"

  BEGIN
  PRINT "Programm gestartet!"
  // Logik hier
  END
  END
  ```

## Copilot-Snippets und Prompts

### Für CC65-C-Code
- **GEOS-App-Template**: "Erstelle eine neue GEOS-Applikation mit cc65, inklusive Maus- und Bildschirm-Initialisierung."
- **Event-Loop**: "Implementiere einen Event-Loop für GEOS mit Tastatur- und Maus-Eingaben."
- **Menu-Definition**: "Definiere ein GEOS-Menü mit Optionen und Callbacks."

### Für GeoCOM
- **GeoCOM-Programm-Template**: "PROGRAM \"Test\" PERMNAME \"Testprogramm\" BEGIN PRINT \"Hallo GeoCOM!\" END END"
- **Variablen und Schleifen**: "Verwende Variablen und FOR-Schleifen in GeoCOM."
- **Datei-Operationen**: "Implementiere Datei-Lesen/Schreiben in GeoCOM."

## Build- und Test-Workflows

- **CC65-Build**: Verwende `make -C cc65 all` für Kompilierung und Disk-Integration.
- **GeoCOM-Transfer**: Nutze `./geocom/build_geocom_disk.sh <file.gcom>` für Übertragung auf Disk.
- **Emulator-Test**: Starte VICE mit `open -a x64 disks/geos_work.d64`.
- **VS Code Tasks**: Nutze die definierten Tasks für automatisierte Builds und Runs.

## Erweiterte Features

- **Automatischer Reload**: Implementiere Skripte für Emulator-Neustart nach Builds.
- **Sub-Repositories**: Strukturiere zukünftige Projekte als separate Repos unterhalb dieses Setups.
- **Debugging**: Integriere VICE-Debugging für cc65-Programme.

## Ressourcen

- GEOS-Dokumentation: Offizielle GEOS-Manuals und APIs.
- cc65-Handbuch: Cross-Compiler-Dokumentation.
- GeoCOM-Referenz: Syntax und Befehle für GeoCOM-Skripte.

Diese Anweisungen sollen Copilot helfen, kontextgerechten Code für GEOS-Entwicklung zu generieren. Aktualisiere diese Datei bei Bedarf für neue Projektaspekte.