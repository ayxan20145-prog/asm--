ASM = nasm
LD = ld

BUILD = build
SRC = src
INC = include

OBJS = $(BUILD)/main.o $(BUILD)/lexer.o
EXE = $(BUILD)/asm--

ARGS ?=

.PHONY: all clean run

all: $(EXE)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/main.o: $(SRC)/main.asm $(INC)/lexer.inc $(INC)/token.inc | $(BUILD)
	$(ASM) -f elf64 -I$(INC)/ $< -o $@

$(BUILD)/lexer.o: $(SRC)/lexer.asm $(INC)/lexer.inc $(INC)/token.inc | $(BUILD)
	$(ASM) -f elf64 -I$(INC)/ $< -o $@

$(EXE): $(OBJS)
	$(LD) $(OBJS) -o $@

clean:
	rm -rf $(BUILD)

run: all
	./$(EXE) $(ARGS)
