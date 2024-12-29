################################################################################
#
# sg2002-codec-firmware
#
################################################################################

SG2002_CODEC_FIRMWARE_VERSION = 1.0.0
SG2002_CODEC_FIRMWARE_SITE = $(BR2_ROOTFS_OVERLAY)/usr/share/fw_vcodec
SG2002_CODEC_FIRMWARE_SITE_METHOD = local

define SG2002_CODEC_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -pv $(TARGET_DIR)/usr/share/fw_vcodec/
	rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/* $(TARGET_DIR)/usr/share/fw_vcodec/
endef

$(eval $(generic-package))
