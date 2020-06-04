MAKE?=make
DESTDIR?=
PREFIX?=/opt/circonus/agent
PLUGIN_DIR=$(PREFIX)/plugins

all:

install:
	install -d -m 0755 $(DESTDIR)$(PLUGIN_DIR)
	for plug in cassandra circonus-inside common haproxy mysql ohai postgresql ; do \
		install -d -m 0755 $(DESTDIR)$(PLUGIN_DIR)/$$plug ; \
		cp -r $$plug/* $(DESTDIR)$(PLUGIN_DIR)/$$plug/. ; \
    done

install-linux: install
	install -d -m 0755 $(DESTDIR)$(PLUGIN_DIR)/linux
	cp -r linux/* $(DESTDIR)$(PLUGIN_DIR)/linux/.
	$(MAKE) -C $(DESTDIR)$(PLUGIN_DIR)/linux
ifneq ($(wildcard /sbin/zpool),)
	cd $(DESTDIR)$(PLUGIN_DIR) ; /bin/ln -sf common/zpool.sh
endif
ifneq ($(wildcard /bin/systemctl),)
	cd $(DESTDIR)$(PLUGIN_DIR) ; /bin/ln -sf linux/systemd.sh
endif

install-rhel: install-linux

install-ubuntu: install-linux

install-illumos: install
	install -d -m 0755 $(DESTDIR)$(PLUGIN_DIR)/illumos
	cp -r illumos/* $(DESTDIR)$(PLUGIN_DIR)/illumos/.
	cd $(DESTDIR)$(PLUGIN_DIR)/illumos ; $(MAKE)
	cd $(DESTDIR)$(PLUGIN_DIR) ; for f in aggcpu.elf cpu.elf fs.elf zpoolio.elf if.sh iflink.sh sdinfo.sh smf.sh tcp.sh udp.sh vminfo.sh vnic.sh zfsinfo.sh zone_vfs.sh; do /bin/ln -sf illumos/$$f ; done
	cd $(DESTDIR)$(PLUGIN_DIR) ; /bin/ln -sf common/zpool.sh

install-freebsd: install
	install -d -m 0755 $(DESTDIR)$(PLUGIN_DIR)/freebsd
	cp -r freebsd/* $(DESTDIR)$(PLUGIN_DIR)/freebsd/.
	cd $(DESTDIR)$(PLUGIN_DIR)/freebsd ; $(MAKE)
	cd $(DESTDIR)$(PLUGIN_DIR) ; for f in cpu.sh disk.elf fs.elf if.sh vm.sh ; do /bin/ln -sf freebsd/$$f ; done
	cd $(DESTDIR)$(PLUGIN_DIR) ; for f in loadavg.elf ; do /bin/ln -sf common/$$f ; done
	A=$(shell /sbin/sysctl kstat.zfs > /dev/null 2>&1 ; echo $$?)
ifeq ($(A),0)
	cd $(DESTDIR)$(PLUGIN_DIR) ; /bin/ln -sf freebsd/zfsinfo.sh ; \
	cd $(DESTDIR)$(PLUGIN_DIR) ; /bin/ln -sf common/zpool.sh
endif

install-openbsd: install
	install -d -m 0755 $(DESTDIR)$(PLUGIN_DIR)/openbsd
	cp -r openbsd/* $(DESTDIR)$(PLUGIN_DIR)/openbsd/.
	cd $(DESTDIR)$(PLUGIN_DIR)/openbsd ; $(MAKE)
	cd $(DESTDIR)$(PLUGIN_DIR) ; for f in cpu.sh fs.elf if.sh pf/pf.pl ; do /bin/ln -sf openbsd/$$f ; done

### END
