CC	= gcc
CFLAGS	?= -O2 -march=native -Wall -Werror -std=gnu99

PROG	= jslisten
DEPCONS	= src/linuxconsole-code/utils
DEPMINI	= src/minIni/dev

PREFIX := /home/$(shell logname)/.local
BINDIR := $(PREFIX)/bin
SYSDDIR := /home/$(shell logname)/.config/systemd/user

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
	install -D -m 644 $(PROG).conf /home/$(shell logname)/.$(PROG)
	sed -e 's|#BINDIR#|$(BINDIR)|' -e 's|#USER#|$(shell logname)|' \
		utils/$(PROG).service.in > $(PROG).service
	install -D -m 644 $(PROG).service $(SYSDDIR)/$(PROG).service
	$(RM) $(PROG).conf $(PROG).service
	systemctl --user daemon-reload
	systemctl --user enable $(PROG).service
	systemctl --user restart $(PROG).service
	@echo -e "\n\nif you want the shutdown functionality (see ~/.$(PROG)) then add '$(shell logname) localhost=NOPASSWD: /usr/bin/gnome-terminal' to the /etc/sudoers file"

.PHONY: uninstall
uninstall:
	systemctl --user stop $(PROG).service
	systemctl --user disable $(PROG).service
	systemctl --user daemon-reload
	$(RM) $(SYSDDIR)/$(PROG).service
	$(RM) $(BINDIR)/$(PROG)

.PHONY: clean
clean:
	$(RM) src/*.o src/*.swp src/*.orig src/*.rej map *~
	$(RM) $(PROG) $(DEPCONS)/axbtnmap.o $(DEPMINI)/minIni.o
