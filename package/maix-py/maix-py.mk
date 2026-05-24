################################################################################
#
# maix-py
#
################################################################################

MAIX_PY_VERSION = 0e2d00aba63ff847c3dd4e5e42e87a0ff911d305
MAIX_PY_SITE = https://github.com/sipeed/MaixPy
MAIX_PY_SITE_METHOD = git

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
	@$(eval MAIX_PY_EXT_MAIXCDK=$(@D)/../maix-cdk-$(MAIX_CDK_VERSION))
	@$(eval PYVER_COMMA=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 1-2 | sed s/'\.'/', '/g))
	if [ ! -e $(MAIX_PY_EXT_MAIXCDK)/components/nn ]; then \
		cd $(@D)/ ; \
		sed -i s/'basic nn peripheral'/'basic peripheral'/g components/maix/CMakeLists.txt ; \
		sed -i s/'voice vision_extra llm'/'voice'/g components/maix/CMakeLists.txt ; \
		sed -i s/'voice vision_extra'/'voice'/g components/maix/CMakeLists.txt ; \
		sed -i s/'"basic", "nn", "peripheral"'/'"basic", "peripheral"'/g components/maix/component.py ; \
		sed -i s/'"voice", "vision_extra", "llm"'/'"voice"'/g components/maix/component.py ; \
		sed -i s/'basic nn peripheral'/'basic peripheral'/g tools/maix_module/components/maix/CMakeLists.txt ; \
		rm -rf projects/app_chat/ ; \
		rm -rf projects/app_face_*/ ; \
		rm -rf projects/app_hand_*/ ; \
		rm -rf projects/app_human_pose*/ ; \
		rm -rf projects/app_mono_depth_estimation/ ; \
		rm -rf projects/app_ocr/ ; \
		rm -rf projects/app_self_learn_*/ ; \
		rm -rf projects/app_speech/ ; \
		rm -rf projects/app_tracker_counter/ ; \
		rm -rf projects/app_usb_hand_touch/ ; \
		rm -rf projects/app_usb_pose_mario/ ; \
		rm -rf projects/app_vlm/ ; \
		rm -rf projects/app_yolo*/ ; \
		rm -rf projects/demo_diansai_*_circle_track/ ; \
	fi
	cd $(@D)/ ; sed -i s/'3, 11'/'$(PYVER_COMMA)'/g setup.py
	cd $(@D)/ ; sed -i s/'3, 11'/'$(PYVER_COMMA)'/g tools/maix_module/setup.py
	export MAIXCDK_PATH=$(MAIX_PY_EXT_MAIXCDK) ; \
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
	@$(eval MAIX_PY_EXT_MAIXCDK=$(@D)/../maix-cdk-$(MAIX_CDK_VERSION))
	@$(eval PYVER_SHORT=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 1-2))
	unzip "${@D}/dist/MaixPy-*.whl" -d $(TARGET_DIR)/usr/lib/python$(PYVER_SHORT)/site-packages
	if [ -e $(TARGET_DIR)/usr/lib -a ! -e ${@D}/usr/lib/libmaixcam_lib.so ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(MAIX_PY_EXT_MAIXCDK)/components/maixcam_lib/lib/libmaixcam_lib.so $(TARGET_DIR)/usr/lib/ ; \
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
