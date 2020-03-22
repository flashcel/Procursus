ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

BZIP2_VERSION := 1.0.8
DEB_BZIP2_V   ?= $(BZIP2_VERSION)

ifneq ($(wildcard $(BUILD_WORK)/bzip2/.build_complete),)
bzip2:
	@echo "Using previously built bzip2."
else
bzip2: setup
	$(MAKE) -C $(BUILD_WORK)/bzip2 install \
		PREFIX=$(BUILD_STAGE)/bzip2/usr \
		CC=$(CC) \
		AR=$(AR) \
		RANLIB=$(RANLIB) \
		CFLAGS="$(CFLAGS)"
	touch $(BUILD_WORK)/bzip2/.build_complete
endif

bzip2-stage: bzip2
	# bzip2.mk Package Structure
	rm -rf $(BUILD_DIST)/bzip2
	mkdir -p $(BUILD_DIST)/bzip2
	
	# bzip2.mk Prep bzip2
	cp -a $(BUILD_STAGE)/bzip2/usr $(BUILD_DIST)/bzip2
	rm -rf $(BUILD_DIST)/bzip2/usr/man
	
	# bzip2.mk Sign
	$(call SIGN,bzip2,general.xml)
	
	# bzip2.mk Make .debs
	$(call PACK,bzip2,DEB_BZIP2_V)
	
	# bzip2.mk Build cleanup
	rm -rf $(BUILD_DIST)/bzip2

.PHONY: bzip2 bzip2-stage
