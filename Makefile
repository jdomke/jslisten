CC	= gcc
CFLAGS	?= -O2 -march=native -Wall -Werror -std=gnu99

PROG	= jslisten
DEPCONS	= src/linuxconsole-code/utils
DEPMINI	= src/minIni/dev

PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
SYSDDIR := /etc/systemd/system

.PHONY: all
all: $(PROG)

.PHONY: compile
compile: $(PROG)

jslisten.o: src/jslisten.c $(DEPCONS)/axbtnmap.h $(DEPMINI)/minIni.h

jslisten: src/jslisten.o $(DEPCONS)/axbtnmap.o $(DEPMINI)/minIni.o
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -ludev -o $@

.PHONY: install
install: $(PROG) etc/$(PROG).conf utils/$(PROG).service.in
	install -D -m 755 $(PROG) $(DESTDIR)$(BINDIR)/$(PROG)
	install -D -m 644 etc/$(PROG).conf /home/$(shell logname)/.$(PROG)
	sed -e 's|#BINDIR#|$(BINDIR)|' -e 's|#USER#|$(shell logname)|' \
		utils/$(PROG).service.in > $(PROG).service
	install -D -m 644 $(PROG).service $(DESTDIR)$(SYSDDIR)/$(PROG).service
	$(RM) $(PROG).service

.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)$(BINDIR)/$(PROG)
	$(RM) $(DESTDIR)$(SYSDDIR)/$(PROG).service

.PHONY: clean
clean:
	$(RM) src/*.o src/*.swp src/*.orig src/*.rej map *~
	$(RM) $(PROG) $(DEPCONS)/axbtnmap.o $(DEPMINI)/minIni.o
