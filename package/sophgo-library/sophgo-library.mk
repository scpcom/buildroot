SOPHGO_LIBRARY_VERSION = 1.0.0
SOPHGO_LIBRARY_SITE = $(BR2_ROOTFS_OVERLAY)/mnt/system
SOPHGO_LIBRARY_SITE_METHOD = local
SOPHGO_LIBRARY_INSTALL_STAGING = YES

define SOPHGO_LIBRARY_BUILD_CMDS
	rm -f $(@D)/lib/lib*json*.so*
	rm -f $(@D)/lib/libopencv_*.so
	rm -f $(@D)/lib/libz.so*
endef

define SOPHGO_LIBRARY_INSTALL_STAGING_CMDS
	cp -a $(@D)/lib/* $(STAGING_DIR)/usr/lib/
endef

define SOPHGO_LIBRARY_INSTALL_TARGET_CMDS
	$(Q)mkdir -p $(TARGET_DIR)/mnt/system/lib
	cp -a $(@D)/lib/* $(TARGET_DIR)/mnt/system/lib/
endef

$(eval $(generic-package))
