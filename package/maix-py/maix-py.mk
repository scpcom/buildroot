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
	@$(eval PYVER_COMMA=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 1-2 | sed s/'\.'/', '/g))
	# todo: nn/tpu
	cd $(@D)/ ; sed -i s/'basic nn peripheral'/'basic peripheral'/g components/maix/CMakeLists.txt
	cd $(@D)/ ; sed -i s/'voice vision_extra llm'/'voice'/g components/maix/CMakeLists.txt
	cd $(@D)/ ; sed -i s/'voice vision_extra'/'voice'/g components/maix/CMakeLists.txt
	cd $(@D)/ ; sed -i s/'"basic", "nn", "peripheral"'/'"basic", "peripheral"'/g components/maix/component.py
	cd $(@D)/ ; sed -i s/'"voice", "vision_extra", "llm"'/'"voice"'/g components/maix/component.py
	cd $(@D)/ ; sed -i s/'basic nn peripheral'/'basic peripheral'/g tools/maix_module/components/maix/CMakeLists.txt
	cd $(@D)/ ; sed -i s/'3, 11'/'$(PYVER_COMMA)'/g setup.py
	cd $(@D)/ ; sed -i s/'3, 11'/'$(PYVER_COMMA)'/g tools/maix_module/setup.py
	export MAIXCDK_PATH=$(@D)/../maix-cdk-$(MAIX_CDK_VERSION) ; \
	cd $(@D)/ ; \
	PATH=$(BR_PATH) $(HOST_DIR)/bin/python3 setup.py bdist_wheel maixcam
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
	@$(eval PYVER_SHORT=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 1-2))
	unzip "${@D}/dist/MaixPy-*.whl" -d $(TARGET_DIR)/usr/lib/python$(PYVER_SHORT)/site-packages
	export MAIXCDK_PATH=$(@D)/../maix-cdk-$(MAIX_CDK_VERSION) ; \
	if [ -e $(TARGET_DIR)/usr/lib -a ! -e ${@D}/usr/lib/libmaixcam_lib.so ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $${MAIXCDK_PATH}/components/maixcam_lib/lib/libmaixcam_lib.so $(TARGET_DIR)/usr/lib/ ; \
	fi
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
