# C64/C128 GEOS Cross-Platform Development Environment

Eine moderne Entwicklungsumgebung für die Cross-Platform-Entwicklung von Programmen für das Commodore 64/128 GEOS-Betriebssystem unter macOS mit VS Code und GitHub Copilot.

## 🎯 Überblick

Dieses Projekt ermöglicht die Entwicklung von GEOS-Applikationen in zwei Umgebungen:

1. **CC65-basierte C-Programme**: Cross-Kompilierung von C-Code zu GEOS-Applikationen
2. **GeoCOM-Programme**: Entwicklung von GeoCOM-Skripten mit automatischer Übertragung ins GEOS-Disk-Image

## 🚀 Quick Start

1. Repository klonen:

   ```bash
   git clone https://github.com/cukabeka/c64-experiments.git
   cd c64-experiments
   ```

2. Setup-Skript ausführen:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. VS Code öffnen und mit der Entwicklung beginnen!

## 🛠️ Benötigte Tools

Das Setup-Skript installiert automatisch:

- **cc65**: C Cross-Compiler für 6502-basierte Systeme (inkl. GEOS)
- **VICE**: Commodore-Emulator (x64) zum Testen der Programme
- **c1541**: Kommandozeilen-Tool zur Manipulation von D64-Disk-Images

## 🔌 VS Code Extensions

Folgende Extensions wurden automatisch installiert und werden für das Projekt benötigt:

### GitHub Copilot

**Zweck**: KI-gestützter Code-Assistent, der kontextbasierte Code-Vorschläge liefert.

- Unterstützt C-Code für cc65/GEOS
- Hilft bei GeoCOM-Syntax durch Custom Instructions
- Beschleunigt die Entwicklung durch intelligente Autovervollständigung

### C/C++ (ms-vscode.cpptools)

**Zweck**: IntelliSense, Debugging und Code-Navigation für C/C++.

- Syntax-Highlighting für cc65-C-Code
- Code-Vervollständigung und Fehlerprüfung
- Integration mit GCC/Clang für lokale Entwicklung

### cc65 for 6502/65816 machines (sharpninja.cc65)

**Zweck**: Spezielle Sprachunterstützung für cc65-Assembly und C.

- Syntax-Highlighting für 6502-Assembly (ca65)
- Snippets für cc65-spezifische Konstrukte
- Unterstützung für .s, .asm, .inc Dateien

### VS64 (rosc.vs64)

**Zweck**: Umfassende C64-Entwicklungsumgebung.

- Unterstützung für ACME, KickAss Assembler
- D64-Disk-Image-Verwaltung
- VICE-Integration und Debugging
- BASIC-Syntax-Highlighting

### Task Explorer (spmeesseman.vscode-taskexplorer)

**Zweck**: Visualisiert und vereinfacht die Ausführung von VS Code Tasks.

- Zeigt alle definierten Tasks in einer Seitenleiste
- Ermöglicht schnelles Ausführen von Build- und Run-Tasks per Klick
- Gruppiert Tasks nach Typ (Build, Run, Transfer)
- Besonders nützlich für Projekte mit mehreren Build-Workflows

## 📁 Projektstruktur

```text
c64-geos-development/
├── cc65/                      # C-basierte GEOS-Entwicklung
│   ├── src/                   # C-Quelldateien
│   │   └── main.c            # Beispiel: GEOS "Hello World"
│   ├── build/                # Kompilierte Binaries (*.prg)
│   └── Makefile              # Build-Automatisierung
├── geocom/                   # GeoCOM-Entwicklung
│   ├── src/                  # GeoCOM-Skripte (*.gcom)
│   │   └── test.gcom        # Beispiel-Skript
│   └── build_geocom_disk.sh # Transfer-Skript
├── disks/                    # GEOS-Disk-Images
│   ├── geos_base.d64        # Reines GEOS-System
│   └── geos_work.d64        # Arbeits-Disk mit Programmen
├── docs/                     # Dokumentation
│   ├── GeoCom Doku 01.md    # GeoCOM-Dokumentation
│   └── ...                   # Weitere Docs aus origin/main
├── .vscode/                  # VS Code Konfiguration
│   ├── tasks.json           # Build/Run Tasks
│   └── launch.json          # Debugger-Konfiguration (optional)
├── setup.sh                  # Installations-Skript
├── copilot-instructions.md   # Copilot-Kontext für das Projekt
└── .gitignore               # Git-Ausschlüsse
```

## 🎮 Workflows

### CC65 C-Programme entwickeln

1. **Code schreiben**: Erstelle C-Dateien in `cc65/src/`
2. **Kompilieren**:
   - Task: `Build CC65 project` (⇧⌘B)
   - Oder: `make -C cc65 all`
3. **Testen**:
   - Task: `Run GEOS (with latest cc65 build)`
   - Oder: `make -C cc65 run`

Das Makefile kompiliert automatisch für `geos-cbm` Target und schreibt das Programm in `geos_work.d64`.

### GeoCOM-Programme entwickeln

1. **Script schreiben**: Erstelle `.gcom`-Dateien in `geocom/src/`
2. **Auf Disk übertragen**:
   - Task: `Transfer GeoCOM source to GEOS disk`
   - Oder: `./geocom/build_geocom_disk.sh geocom/src/test.gcom`
3. **In GEOS kompilieren**:
   - Task: `Run GEOS for GeoCOM work`
   - Im Emulator: GeoCOM starten → Datei laden → Kompilieren

## 📝 VS Code Tasks

Alle Tasks sind über die Task-Palette (⇧⌘B) oder Task Explorer verfügbar:

| Task | Beschreibung |
|------|-------------|
| **Build CC65 project** | Kompiliert C-Code mit cc65 und erstellt .prg |
| **Run GEOS (with latest cc65 build)** | Startet VICE mit dem aktuellen Build |
| **Transfer GeoCOM source to GEOS disk** | Kopiert GeoCOM-Skript ins Disk-Image |
| **Run GEOS for GeoCOM work** | Startet VICE mit dem GeoCOM-Arbeits-Disk |

## 🧠 GitHub Copilot Nutzung

Die Datei `copilot-instructions.md` enthält Kontext für Copilot:

- GEOS-API-Patterns
- cc65-spezifische Konstrukte
- GeoCOM-Syntax-Templates

**Tipp**: Verwende Kommentare wie `// GEOS: Erstelle ein Menü mit drei Optionen`, um präzise Vorschläge zu erhalten.

## 📚 Dokumentation

Im Verzeichnis `docs/` findest du:

- GeoCOM-Dokumentation und Tutorials
- GEOS-Markdown-Editor-Konzepte
- SID-Musikprogrammierung
- Python-Tools (z.B. SIDcreator.py)

## 🔧 Erweiterte Konfiguration

### GEOS-Base-Disk vorbereiten

Die initiale `geos_base.d64` ist leer. Füge GEOS-Systemdateien hinzu:

```bash
c1541 -attach disks/geos_base.d64 -write /path/to/geos64.d64 "*"
```

### VICE-Einstellungen

Für optimales Debugging empfehlen sich folgende VICE-Optionen:

- True Drive Emulation aktivieren
- GEOS-Kernal-ROM konfigurieren
- Warp Mode für schnelleres Testen

## 🤝 Beitragen

Dieses Projekt ist Teil von [cukabeka/c64-experiments](https://github.com/cukabeka/c64-experiments).

Branches:

- `master`: Aktuelle Development-Umgebung (dieses Setup)
- `main`: Dokumentations-Branch (integriert als `docs/`)

## 📄 Lizenz

Open Source - siehe Repository für Details.

---

Entwickelt mit ❤️ für die C64/GEOS-Community
