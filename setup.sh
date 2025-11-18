#!/bin/bash

set -e

echo "Installing tools..."

brew install cc65 vice c1541

echo "Creating project structure..."

mkdir -p cc65/src
mkdir -p geocom/src
mkdir -p geocom/build
mkdir -p disks
mkdir -p .vscode

echo "Creating disks..."

c1541 -format "GEOS Base,01" d64 disks/geos_base.d64
c1541 -format "GEOS Work,01" d64 disks/geos_work.d64

echo "Creating files..."

# Makefile
cat > cc65/Makefile << 'EOF'
CC = cl65
TARGET = geos-cbm
SRC = src/main.c
OUT = build/app.prg
D64 = ../disks/geos_work.d64

all: $(OUT)

$(OUT): 
	mkdir -p build
	$(CC) -t $(TARGET) $(SRC) -o $(OUT)
	c1541 -attach $(D64) -write $(OUT) app

run: open -a x64 $(D64)
EOF

# main.c
cat > cc65/src/main.c << 'EOF'
#include <geos.h>
#include <conio.h>

void main(void) {
    InitMouse();
    RestoreOldMouse();
    ClearScreen();
    cputs("Hello from GEOS + cc65!");
    for(;;);
}
EOF

# build_geocom_disk.sh
cat > geocom/build_geocom_disk.sh << 'EOF'
#!/bin/bash
set -e

SRC="$1"
D64="../disks/geos_work.d64"

if [ ! -f "$SRC" ]; then
    echo "File not found: $SRC"
    exit 1
fi

echo "Writing $SRC to GEOS disk..."
c1541 -attach $D64 -write $SRC $(basename $SRC)
echo "Done."
EOF

chmod +x geocom/build_geocom_disk.sh

# test.gcom
cat > geocom/src/test.gcom << 'EOF'
PROGRAM "Hello"
PERMNAME "Hello from GeoCOM"
BEGIN
PRINT "GeoCom running!"
END
END
EOF

# tasks.json
cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build CC65 project",
            "type": "shell",
            "command": "make -C cc65 all"
        },
        {
            "label": "Run GEOS (with latest cc65 build)",
            "type": "shell",
            "command": "make -C cc65 run"
        },
        {
            "label": "Transfer GeoCOM source to GEOS disk",
            "type": "shell",
            "command": "./geocom/build_geocom_disk.sh geocom/src/test.gcom"
        },
        {
            "label": "Run GEOS for GeoCOM work",
            "type": "shell",
            "command": "open -a x64 disks/geos_work.d64"
        }
    ]
}
EOF

echo "Setup complete. Now install VS Code extensions manually or via script."