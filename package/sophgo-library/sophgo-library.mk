SOPHGO_LIBRARY_VERSION = 1.0.0
SOPHGO_LIBRARY_SITE = $(BR2_ROOTFS_OVERLAY)/mnt/system
SOPHGO_LIBRARY_SITE_METHOD = local
SOPHGO_LIBRARY_INSTALL_STAGING = YES

define SOPHGO_LIBRARY_BUILD_CMDS
	rm -f $(@D)/lib/lib*json*.so*
	rm -f $(@D)/lib/libopencv_*.so
	rm -f $(@D)/lib/libcrypto.so
	rm -f $(@D)/lib/libssl.so
	rm -f $(@D)/lib/libwebsockets.so
	rm -f $(@D)/lib/libz.so*
	rm -f $(@D)/opt/cvitek_tpu_sdk/lib/*.so*
endef

define SOPHGO_LIBRARY_INSTALL_STAGING_CMDS
	cp -a $(@D)/lib/* $(STAGING_DIR)/usr/lib/
endef

define SOPHGO_LIBRARY_INSTALL_TARGET_CMDS
	$(Q)mkdir -p $(TARGET_DIR)/mnt/system/lib
	cp -a $(@D)/lib/* $(TARGET_DIR)/mnt/system/lib/
	if [ -e $(@D)/opt ]; then \
		$(Q)mkdir -p $(TARGET_DIR)/mnt/system/opt ; \
		rsync -r --verbose --links --safe-links --hard-links $(@D)/opt/ $(TARGET_DIR)/mnt/system/opt/ ; \
	fi
endef

$(eval $(generic-package))
