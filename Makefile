PREFIX ?= /usr
DRACUT_MODULE_DIR ?= $(PREFIX)/lib/dracut/modules.d/90bcachefs
SYSTEMD_DIR ?= $(PREFIX)/lib/systemd/system
OPENRC_DIR ?= /etc/init.d
TAB_DIR ?= /etc

all:
	@echo "Usage: make install"

install: install-dracut install-systemd install-openrc install-tab

install-dracut:
	@echo "Installing dracut module..."
	install -d $(DRACUT_MODULE_DIR)
	install -m 755 90bcachefs/* $(DRACUT_MODULE_DIR)/

install-systemd:
	@echo "Installing systemd unit..."
	install -d $(SYSTEMD_DIR)
	install -m 644 units/systemd-bcachefs-unlock@.service.in $(SYSTEMD_DIR)/systemd-bcachefs-unlock@.service

install-openrc:
	@echo "Installing OpenRC init script..."
	install -d $(OPENRC_DIR)
	install -m 755 units/bcachefs-unlock.openrc $(OPENRC_DIR)/bcachefs-unlock

install-tab:
	@echo "Installing bcachefs-tab template..."
	install -d $(TAB_DIR)
	install -m 644 bcachefs-tab.new $(TAB_DIR)/bcachefs-tab.new
	@echo "NOTE: Copy and edit template: cp $(TAB_DIR)/bcachefs-tab.new $(TAB_DIR)/bcachefs-tab"
