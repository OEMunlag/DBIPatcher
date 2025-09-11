CC = gcc

CFLAGS =-std=gnu11 \
	-g \
	-I$(SRCDIR)/inc \
	-Ilibs/zstd/include \
	-Wall \
	-Wextra \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-Wno-sign-compare \
	-Wno-unused-function

LDLIBS = libs/zstd/static/libzstd_static.lib

SRCDIR = src
BUILDDIR = build
BINDIR = bin
TEMPDIR = temp

SOURCES = $(shell find $(SRCDIR) -name '*.c')

OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)

TARGET = $(BINDIR)/dbipatcher

all: $(TARGET)

$(TARGET): $(OBJECTS) | $(BUILDDIR) $(BINDIR)
	$(CC) $(OBJECTS) -o $@ $(LDLIBS)

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
	@for lang in $(TRANSLATE_LANGS); do \
		if [ "$$lang" != "ru" ]; then \
			echo "Processing language: $$lang"; \
			$(MAKE) translate-810 LANG=$$lang || exit 1; \
		fi; \
	done
	@echo "All translations completed successfully!"

clean-translate:
	@rm -rf $(TEMPDIR)/DBI_810
	@echo "Cleaned translation temporary files"

list-languages:
	@echo "Available translation languages:"
	@for lang in $(TRANSLATE_LANGS); do \
		echo "  $$lang"; \
	done

translate-%: $(TARGET)
	@lang=$*; \
	if [ ! -f "translate/rec6.810.$$lang.txt" ]; then \
		echo "Error: Translation file for language '$$lang' not found"; \
		echo "Available languages: $(TRANSLATE_LANGS)"; \
		exit 1; \
	fi; \
	$(MAKE) translate-810 LANG=$$lang

quiet:
	@$(MAKE) --no-print-directory all

.PHONY: all clean