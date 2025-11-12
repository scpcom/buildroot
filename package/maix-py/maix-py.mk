################################################################################
#
# maix-py
#
################################################################################

MAIX_PY_VERSION = 49c149f5faadf3d6f1cd420cf2c5efd609300771
MAIX_PY_SITE = $(call github,sipeed,MaixPy,$(MAIX_PY_VERSION))

MAIX_PY_SAMPLE = vision/streaming

MAIX_PY_DEPENDENCIES =\
	host-cmake \
	host-pkgconf \
	host-python3 \
	host-python-pip \
	host-python-setuptools

MAIX_PY_DEPENDENCIES +=\
	maix-cdk

MAIX_PY_MAIXCAM_DIST = examples/$(MAIX_PY_SAMPLE)

define MAIX_PY_POST_EXTRACT_FIXUP
	true
endef
MAIX_PY_POST_EXTRACT_HOOKS += MAIX_PY_POST_EXTRACT_FIXUP

define MAIX_PY_BUILD_CMDS
	# todo: maix and maixpy site-packages
	if [ "X$(BR2_PACKAGE_MAIX_PY_ALL_PROJECTS)" = "Xy" -a -e $(@D)/distapps.sh -a -e $(@D)/projects/build_all.sh ]; then \
		chmod +x $(@D)/projects/build_all.sh ; \
		cd $(@D)/projects/ ; \
		PATH=$(BR_PATH) ./build_all.sh maixcam ; \
	fi
	if [ "X$(BR2_PACKAGE_MAIX_PY_ALL_EXAMPLES)" = "Xy" -a -e $(@D)/distapps.sh -a -e $(@D)/test/test_examples/test_cases.sh ]; then \
		chmod +x $(@D)/test/test_examples/test_cases.sh ; \
		cd $(@D)/test/test_examples/ ; \
		PATH=$(BR_PATH) ./test_cases.sh maixcam 0 ; \
	fi
	if [ -e $(@D)/distapps.sh ]; then \
		chmod +x $(@D)/distapps.sh ; \
		cd $(@D)/ ; \
		PATH=$(BR_PATH) ./distapps.sh ; \
	fi
endef

define MAIX_PY_INSTALL_TARGET_CMDS
	if [ -e ${@D}/dist/maixapp ]; then \
		mkdir -pv $(TARGET_DIR)/maixapp/ ; \
		rsync -r --verbose --links --safe-links --hard-links ${@D}/dist/maixapp/ $(TARGET_DIR)/maixapp/ ; \
		PATH=$(BR_PATH) $(HOST_DIR)/bin/python3 ${@D}/tools/gen_app_info.py $(TARGET_DIR)/maixapp/apps ; \
	elif [ -e  ${@D}/$(MAIX_PY_MAIXCAM_DIST) ]; then \
		mkdir -pv $(TARGET_DIR)/maixapp/apps/$(MAIX_PY_SAMPLE)/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/$(MAIX_PY_MAIXCAM_DIST)/ $(TARGET_DIR)/maixapp/apps/$(MAIX_PY_SAMPLE)/ ; \
	fi
endef

$(eval $(generic-package))
