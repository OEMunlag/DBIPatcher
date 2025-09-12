CC = gcc

CFLAGS =-std=gnu11 -g -Isrc/inc -Ilibs/zstd/include -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-sign-compare -Wno-unused-function

UNAME_S := $(shell uname -s)
BREW_PREFIX := $(shell if [ "$(UNAME_S)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then brew --prefix; else echo ""; fi)

ifeq ($(UNAME_S),Linux)
    LDLIBS = -lzstd
    EXE_EXT =
endif
ifeq ($(UNAME_S),Darwin)
    ifneq ($(BREW_PREFIX),)
        CFLAGS += -I$(BREW_PREFIX)/opt/zstd/include
        LDFLAGS += -L$(BREW_PREFIX)/opt/zstd/lib
    endif
    LDLIBS = -lzstd
    EXE_EXT =
endif
ifeq ($(OS),Windows_NT)
    LDFLAGS += -Llibs/zstd/dll
    LDLIBS = -lzstd
    EXE_EXT = .exe
endif

ifndef LDLIBS
    LDLIBS = -lzstd
endif

SRCDIR = src
BUILDDIR = build
BINDIR = bin
TEMPDIR = temp

# 修复文件查找 - 使用Windows兼容的方法
ifeq ($(OS),Windows_NT)
    SOURCES = $(wildcard $(SRCDIR)/*.c) $(wildcard $(SRCDIR)/*/*.c)
else
    SOURCES = $(shell find $(SRCDIR) -name '*.c')
endif

OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)

TARGET = $(BINDIR)/dbipatcher$(EXE_EXT)

all: $(TARGET)

$(TARGET): $(OBJECTS) | $(BUILDDIR) $(BINDIR)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS) $(LDLIBS)
	@if [ "$(OS)" = "Windows_NT" ]; then if [ -f "libs/zstd/dll/libzstd.dll" ]; then cp libs/zstd/dll/libzstd.dll $(BINDIR)/; fi; fi

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

$(BINDIR):
	@mkdir -p $(BINDIR)

$(TEMPDIR):
	@mkdir -p $(TEMPDIR)

clean:
	@rm -rf $(BUILDDIR) $(TEMPDIR)
	@rm -f $(BINDIR)/dbipatcher $(BINDIR)/dbipatcher.exe
	@rm -f $(BINDIR)/libzstd.dll

run: $(TARGET)
	@$(TARGET)

translate-810: $(TARGET) | $(TEMPDIR)
	@$(TARGET) --extract dbi/DBI.810.ru.nro --output $(TEMPDIR)/DBI_810
	@$(TARGET) --convert $(TEMPDIR)/DBI_810/rec6.bin --output translate/rec6.810.ru.txt --keys $(TEMPDIR)/DBI_810/keys_ru.txt
	@$(TARGET) --extract-keys dbi/DBI.810.ru.nro --output $(TEMPDIR)/DBI_810/keys_$(LANG).txt --lang $(LANG)
	@$(TARGET) --convert translate/rec6.810.$(LANG).txt --output $(TEMPDIR)/DBI_810/rec6.$(LANG).bin --keys $(TEMPDIR)/DBI_810/keys_$(LANG).txt
	@$(TARGET) --patch $(TEMPDIR)/DBI_810/rec6.$(LANG).bin --binary dbi/DBI.810.ru.nro --output $(TEMPDIR)/DBI_810/bin/DBI.810.$(LANG).nro --slot 6

debug: $(TARGET)
	@valgrind $(TARGET)

TRANSLATE_FILES = $(wildcard translate/rec6.810.*.txt)
TRANSLATE_LANGS = $(sort $(patsubst translate/rec6.810.%.txt,%,$(TRANSLATE_FILES)))

.PHONY: translate-all clean-translate list-languages translate-%

translate-all: $(TARGET)
	@echo "Available translation languages: $(TRANSLATE_LANGS)"
	@for lang in $(TRANSLATE_LANGS); do if [ "$$lang" != "ru" ]; then echo "Processing language: $$lang"; $(MAKE) translate-810 LANG=$$lang || exit 1; fi; done
	@echo "All translations completed successfully!"

clean-translate:
	@rm -rf $(TEMPDIR)/DBI_810
	@echo "Cleaned translation temporary files"

list-languages:
	@echo "Available translation languages:"
	@for lang in $(TRANSLATE_LANGS); do echo "  $$lang"; done

translate-%: $(TARGET)
	@lang=$*; if [ ! -f "translate/rec6.810.$$lang.txt" ]; then echo "Error: Translation file for language '$$lang' not found"; echo "Available languages: $(TRANSLATE_LANGS)"; exit 1; fi; $(MAKE) translate-810 LANG=$$lang

quiet:
	@$(MAKE) --no-print-directory all

.PHONY: all clean run debug
