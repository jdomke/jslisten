CC	= gcc
CFLAGS	?= -O2 -march=native -Wall -Werror -std=gnu99

PROG	= jslisten
DEPCONS	= src/linuxconsole-code/utils
DEPMINI	= src/minIni/dev

PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
ETCDIR := $(PREFIX)/etc
SYSDDIR := /etc/systemd/system

CFLAGS += -DJSLPREFIXDIR=$(PREFIX)

.PHONY: all
all: $(PROG)

.PHONY: compile
compile: $(PROG)

jslisten.o: src/jslisten.c $(DEPCONS)/axbtnmap.h $(DEPMINI)/minIni.h

jslisten: src/jslisten.o $(DEPCONS)/axbtnmap.o $(DEPMINI)/minIni.o
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -ludev -o $@

.PHONY: install
install: $(PROG) etc/$(PROG).conf.in utils/$(PROG).service.in
	install -D -m 755 $(PROG) $(BINDIR)/$(PROG)
	sed -e 's|#USER#|$(shell logname)|' etc/$(PROG).conf.in > $(PROG).conf
	install -D -m 644 $(PROG).conf $(ETCDIR)/$(PROG).conf
	sed -e 's|#BINDIR#|$(BINDIR)|' -e 's|#USER#|$(shell logname)|' \
		utils/$(PROG).service.in > $(PROG).service
	install -D -m 644 $(PROG).service $(SYSDDIR)/$(PROG).service
	$(RM) $(PROG).conf $(PROG).service
	systemctl daemon-reload
	systemctl enable $(PROG).service
	systemctl restart $(PROG).service

.PHONY: uninstall
uninstall:
	systemctl stop $(PROG).service
	systemctl disable $(PROG).service
	systemctl daemon-reload
	$(RM) $(SYSDDIR)/$(PROG).service
	$(RM) $(BINDIR)/$(PROG)

.PHONY: clean
clean:
	$(RM) src/*.o src/*.swp src/*.orig src/*.rej map *~
	$(RM) $(PROG) $(DEPCONS)/axbtnmap.o $(DEPMINI)/minIni.o
