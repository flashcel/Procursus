ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS       += apt-file
APT-FILE_VERSION  := 3.2.2
DEB_APT-FILE_V    ?= $(APT-FILE_VERSION)-2

apt-file-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://salsa.debian.org/apt-team/apt-file/-/archive/debian/$(APT-FILE_VERSION)/apt-file-debian-$(APT-FILE_VERSION).tar.gz)
	$(call EXTRACT_TAR,apt-file-debian-$(APT-FILE_VERSION).tar.gz,apt-file-debian-$(APT-FILE_VERSION),apt-file)
	mkdir -p $(BUILD_STAGE)/apt-file/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/apt-file/.build_complete),)
apt-file:
	@echo "Using previously built apt-file."
else
apt-file: apt-file-setup
	sed -i -e '1s|.*|#!$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/perl|g' \
	-e 's|/usr/lib/apt/apt-helper|$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/apt/apt-helper|' $(BUILD_WORK)/apt-file/apt-file
	$(MAKE) -C $(BUILD_WORK)/apt-file man
	$(INSTALL) -Dm755 $(BUILD_INFO)/apt-file.is-cache-empty         $(BUILD_STAGE)/apt-file/$(MEMO_PREFIX)/$(MEMO_SUB_PREFIX)/share/apt-file/is-cache-empty
	$(INSTALL) -Dm644 $(BUILD_WORK)/apt-file/apt-file.1             $(BUILD_STAGE)/apt-file/$(MEMO_PREFIX)/$(MEMO_SUB_PREFIX)/share/man/man1/apt-file.1
	$(INSTALL) -Dm755 $(BUILD_WORK)/apt-file/apt-file               $(BUILD_STAGE)/apt-file/$(MEMO_PREFIX)/$(MEMO_SUB_PREFIX)/bin/apt-file
	$(INSTALL) -Dm644 $(BUILD_WORK)/apt-file/50apt-file.conf        $(BUILD_STAGE)/apt-file/$(MEMO_PREFIX)/etc/apt/apt.conf.d/50apt-file.conf
	$(INSTALL) -Dm644 $(BUILD_WORK)/apt-file/debian/bash-completion $(BUILD_STAGE)/apt-file/$(MEMO_PREFIX)/etc/bash_completion.d/apt-file
	$(call AFTER_BUILD)
endif

apt-file-package: apt-file-stage
	# apt-file.mk Package Structure
	rm -rf $(BUILD_DIST)/apt-file

	# apt-file.mk Prep apt-file
	cp -a $(BUILD_STAGE)/apt-file $(BUILD_DIST)

	# apt-file.mk Make .debs
	$(call PACK,apt-file,DEB_APT-FILE_V)

	# apt-file.mk Build cleanup
	rm -rf $(BUILD_DIST)/apt-file

.PHONY: apt-file apt-file-package
