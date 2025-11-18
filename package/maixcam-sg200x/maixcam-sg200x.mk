################################################################################
#
# maixcam-sg200x
#
################################################################################

MAIXCAM_SG200X_VERSION = 4.10.3
MAIXCAM_SG200X_SUBLEVEL =
MAIXCAM_SG200X_BASE = maixcam-skeleton-$(MAIXCAM_SG200X_VERSION)$(MAIXCAM_SG200X_SUBLEVEL)
MAIXCAM_SG200X_SOURCE = v$(MAIXCAM_SG200X_VERSION)$(MAIXCAM_SG200X_SUBLEVEL).zip
MAIXCAM_SG200X_SITE = https://github.com/scpcom/maixcam-skeleton/archive/refs/tags

MAIXCAM_SG200X_DEPENDENCIES += maix-cdk

ifeq ($(BR2_PACKAGE_MAIX_PY),y)
MAIXCAM_SG200X_DEPENDENCIES += maix-py
endif

define MAIXCAM_SG200X_EXTRACT_CMDS
	$(UNZIP) -d $(@D) \
		$(MAIXCAM_SG200X_DL_DIR)/$(MAIXCAM_SG200X_SOURCE)
	mv $(@D)/$(MAIXCAM_SG200X_BASE) $(@D)/maixapp
endef

define MAIXCAM_SG200X_INSTALL_TARGET_CMDS
	mkdir -pv $(TARGET_DIR)/maixapp/
	rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/maixapp/ $(TARGET_DIR)/maixapp/
endef

$(eval $(generic-package))
