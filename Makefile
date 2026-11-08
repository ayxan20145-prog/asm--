ASM = nasm
LD = ld

BUILD = build
SRC = src/main.asm
OBJ = $(BUILD)/main.o
EXE = $(BUILD)/main

.PHONY: all clean run

all: $(EXE)

$(BUILD):
	mkdir -p $(BUILD)

$(OBJ): $(SRC) | $(BUILD)
	$(ASM) -f elf64 $< -o $@

$(EXE): $(OBJ)
	$(LD) $< -o $@

clean:
	rm -rf $(BUILD)

run: all
	./$(EXE)
