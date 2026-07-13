################################################################################
#
# nanokvm-server
#
################################################################################

NANOKVM_SERVER_VERSION = 3b2ba7c0c1214f44da9d328f90bbdd025fac0413
NANOKVM_SERVER_SITE = https://github.com/sipeed/NanoKVM
NANOKVM_SERVER_SITE_METHOD = git
NANOKVM_SERVER_UPDATE_URL = https://scpcom.github.io/nanokvm

NANOKVM_SERVER_GO_VENDOR_REF = fd68bdc39cf813361c6d69e76c80f45b4df16c77
NANOKVM_SERVER_GO_VENDOR_URL = https://github.com/scpcom/nanokvm-server-vendor

NANOKVM_SERVER_NODE_MODULES_REF = c50a1e50c2b4ee3a88124d28b839879916d30595
NANOKVM_SERVER_NODE_MODULES_URL = https://github.com/scpcom/nanokvm-web-modules

NANOKVM_SERVER_DEPENDENCIES = host-go host-nodejs host-python3

ifeq ($(BR2_PACKAGE_MAIX_CDK),y)
# Use MaixCDK to build kvm_system.
NANOKVM_SERVER_DEPENDENCIES += maix-cdk
endif

NANOKVM_SERVER_TOOLCHAIN_ARCH := $(BR2_ARCH)
NANOKVM_SERVER_TOOLCHAIN_LIBC := $(findstring musl,$(realpath $(TOOLCHAIN_EXTERNAL_BIN)))

GO_BIN = $(HOST_DIR)/bin/go

ifeq ($(BR2_PACKAGE_HOST_GO_SRC),y)
HOST_GO_CROSS_ENV ?= $(HOST_GO_SRC_CROSS_ENV)
endif

NANOKVM_SERVER_GO_ENV = $(HOST_GO_CROSS_ENV)

NANOKVM_SERVER_XDG_HOME_DIR = $(@D)
NANOKVM_SERVER_XDG_CACHE_DIR = $(NANOKVM_SERVER_XDG_HOME_DIR)/.cache
NANOKVM_SERVER_XDG_DATA_DIR = $(NANOKVM_SERVER_XDG_HOME_DIR)/.local/share

HOST_NODEJS_BIN_ENV = $(HOST_CONFIGURE_OPTS) \
	LDFLAGS="$(NODEJS_LDFLAGS)" \
	LD="$(HOST_CXX)" \
	PATH=$(BR_PATH) \
	XDG_CACHE_HOME=$(NANOKVM_SERVER_XDG_CACHE_DIR) \
	XDG_DATA_HOME=$(NANOKVM_SERVER_XDG_DATA_DIR) \
	COREPACK_HOME=$(NANOKVM_SERVER_XDG_CACHE_DIR)/node/corepack \
	PNPM_HOME=$(NANOKVM_SERVER_XDG_DATA_DIR)/pnpm \
	npm_config_build_from_source=true \
	npm_config_nodedir=$(HOST_DIR)/usr \
	npm_config_prefix=$(HOST_DIR)/usr \
	npm_config_cache=$(BUILD_DIR)/.npm-cache

HOST_COREPACK = $(HOST_NODEJS_BIN_ENV) $(HOST_DIR)/bin/corepack

NANOKVM_SERVER_PNPM_VERSION = 10.29.3
# wget -q -O- https://registry.npmjs.org/pnpm | jq -C '.versions."10.29.3".dist.shasum
NANOKVM_SERVER_PNPM_SHA_SUM = f7315fb659932216d489e3ed4c14f47bc58ec6c6

NANOKVM_SERVER_NODE_CACHE_DIR = $(NANOKVM_SERVER_XDG_CACHE_DIR)/node
NANOKVM_SERVER_PNPM_CACHE_DIR = $(NANOKVM_SERVER_XDG_CACHE_DIR)/pnpm
NANOKVM_SERVER_PNPM_SHARE_DIR = $(NANOKVM_SERVER_XDG_DATA_DIR)/pnpm

NANOKVM_SERVER_GOMOD = server

NANOKVM_SERVER_EXT_MIDDLEWARE = $(realpath $(TOPDIR)/../middleware)
NANOKVM_SERVER_EXT_KVM_MMF = sample/test_mmf/kvm_mmf/release.linux/libkvm_mmf.so
NANOKVM_SERVER_EXT_KVM_VISION = sample/test_mmf/kvm_vision/release.linux/libkvm.so
NANOKVM_SERVER_EXT_MAIXCAM_LIB = sample/test_mmf/maixcam_lib/release.linux/libmaixcam_lib.so

NANOKVM_SERVER_REQUIRED_LIBS = \
	libae.so \
	libaf.so \
	libawb.so \
	libcvi_bin_isp.so \
	libcvi_bin.so \
	libcvi_ive.so \
	libini.so \
	libisp_algo.so \
	libisp.so \
	libmipi_tx.so \
	libmisc.so \
	libraw_dump.so \
	libsys.so \
	libvdec.so \
	libvenc.so

NANOKVM_SERVER_VPU_LIBS = \
	libosdc.so \
	libvpu.so \
	libgdc.so \
	librgn.so \
	libvi.so \
	libvo.so \
	libvpss.so

NANOKVM_SERVER_UNUSED_LIBS = \
	libcli.so \
	libjson-c.so.5 \
	libcvi_ispd2.so \
	libaaccomm2.so \
	libaacdec2.so \
	libaacenc2.so \
	libaacsbrdec2.so \
	libaacsbrenc2.so \
	libcvi_RES1.so \
	libcvi_VoiceEngine.so \
	libcvi_audio.so \
	libcvi_ssp.so \
	libcvi_vqe.so \
	libdnvqe.so \
	libtinyalsa.so

NANOKVM_SERVER_DUMMY_LIBS = \
	libae.so \
	libaf.so \
	libawb.so

define NANOKVM_SERVER_BUILD_CMDS
	if [ -e $(@D)/kvmapp ]; then \
		rm -f $(@D)/kvmapp/jpg_stream/jpg_stream ; \
		rm -rf $(@D)/kvmapp/kvm_system/ ; \
		rm -rf $(@D)/kvmapp/system/ko/ ; \
	fi
	if [ "X$(NANOKVM_SERVER_TOOLCHAIN_LIBC)" != "Xmusl" ]; then \
		sed -i 's|https://cdn.sipeed.com/nanokvm|$(NANOKVM_SERVER_UPDATE_URL)/glibc_'$(NANOKVM_SERVER_TOOLCHAIN_ARCH)'|g' $(@D)/$(NANOKVM_SERVER_GOMOD)/service/application/service.go ; \
	else \
		sed -i 's|https://cdn.sipeed.com/nanokvm|$(NANOKVM_SERVER_UPDATE_URL)/musl_'$(NANOKVM_SERVER_TOOLCHAIN_ARCH)'|g' $(@D)/$(NANOKVM_SERVER_GOMOD)/service/application/service.go ; \
	fi
	mkdir -pv $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/
	rm -f $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/libopencv_*.so*
	if [ -e $(NANOKVM_SERVER_EXT_MIDDLEWARE)/$(NANOKVM_SERVER_EXT_KVM_MMF) ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/$(NANOKVM_SERVER_EXT_KVM_MMF) $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
	elif [ -e $(NANOKVM_SERVER_EXT_MIDDLEWARE)/$(NANOKVM_SERVER_EXT_MAIXCAM_LIB) ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/$(NANOKVM_SERVER_EXT_MAIXCAM_LIB) $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
	fi
	rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/3rd/libini.so $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/
	for l in $(NANOKVM_SERVER_REQUIRED_LIBS) ; do \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/$$l $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
	done
	for l in $(NANOKVM_SERVER_VPU_LIBS) ; do \
		if [ -e $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/$$l ]; then \
			rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/$$l $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
		fi ; \
	done
	for l in $(NANOKVM_SERVER_UNUSED_LIBS) ; do \
		rm -f $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
	done
	if [ -e $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/libcvi_dummy.so ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/libcvi_dummy.so $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
		for l in $(NANOKVM_SERVER_DUMMY_LIBS) ; do \
			rm -f $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
			ln -s libcvi_dummy.so $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
		done ; \
	fi
	if [ -e $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/libisp_light.so ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/lib/libisp_light.so $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
		for l in libisp.so ; do \
			rm -f $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
			ln -s libisp_light.so $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
		done ; \
		for l in libisp_algo.so ; do \
			rm -f $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
			ln -s libmisc.so $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/$$l ; \
		done ; \
	fi
	if [ -e $(NANOKVM_SERVER_EXT_MIDDLEWARE)/$(NANOKVM_SERVER_EXT_KVM_VISION) -a \
	     -e $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/libkvm.so ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(NANOKVM_SERVER_EXT_MIDDLEWARE)/$(NANOKVM_SERVER_EXT_KVM_VISION) $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/ ; \
		chmod ugo+rx $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/libkvm.so ; \
	fi
	if [ -e $(@D)/support/sg2002/additional -a -e $(HOST_DIR)/bin/maixcdk ]; then \
		if [ ! -e $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/_off/vision ]; then \
			mkdir $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/_off ; \
			mv $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/components/vision $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/_off/ ; \
		else \
			rm -rf $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/components/vision ; \
		fi ; \
		rsync -avpPxH $(@D)/support/sg2002/additional/ $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/components/ ; \
		rm -rf $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/kvm_vision_test ; \
		rsync -avpPxH $(@D)/support/sg2002/kvm_vision_test $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/ ; \
		cd $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/kvm_vision_test/ ; \
		PATH=$(BR_PATH) $(HOST_DIR)/bin/maixcdk build -p maixcam ; \
		rm -rf $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/components/vision ; \
		mv $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/_off/vision  $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/components/ ; \
		rmdir $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/_off ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/kvm_vision_test/dist/kvm_vision_test_release/dl_lib/libkvm*.so ${@D}/server/dl_lib/ ; \
	fi
	if [ -e $(@D)/support/sg2002/kvm_system -a -e $(HOST_DIR)/bin/maixcdk ]; then \
		rm -rf $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/kvm_system ; \
		rsync -avpPxH $(@D)/support/sg2002/kvm_system $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/ ; \
		cd $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/kvm_system/ ; \
		PATH=$(BR_PATH) $(HOST_DIR)/bin/maixcdk build -p maixcam ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(@D)/../maix-cdk-$(MAIX_CDK_VERSION)/examples/kvm_system/dist/kvm_system_release/kvm_system $(@D)/support/sg2002/kvm_system/ ; \
	fi
	if [ -e $(@D)/tools/nanokvm_update_edid ]; then \
		cd $(@D)/tools/nanokvm_update_edid ; \
		rm -f nanokvm_update_edid ; \
		sed -i s/'^CROSS_COMPILE ='/'#CROSS_COMPILE ='/g Makefile ; \
		sed -i s/'^CC ='/'#CC ='/g Makefile ; \
		$(TARGET_MAKE_ENV) make CC=$(TARGET_CC) CFLAGS="$(TARGET_CFLAGS) $(TARGET_LDFLAGS)" ; \
	fi
	cd $(@D)/$(NANOKVM_SERVER_GOMOD) && git clone --depth 1 $(NANOKVM_SERVER_GO_VENDOR_URL) vendor
	cd $(@D)/$(NANOKVM_SERVER_GOMOD)/vendor && git checkout $(NANOKVM_SERVER_GO_VENDOR_REF)
	cd $(@D)/web && git clone --depth 1 $(NANOKVM_SERVER_NODE_MODULES_URL) node_modules
	cd $(@D)/web/node_modules && git checkout $(NANOKVM_SERVER_NODE_MODULES_REF)
	cd $(@D)/web && sed -i 's|"storeDir": ".*"|"storeDir": "'$(NANOKVM_SERVER_PNPM_SHARE_DIR)'/store/v10"|g' node_modules/.modules.yaml
	cd $(@D)/web && sed -i 's|^storeDir: .*|storeDir: '$(NANOKVM_SERVER_PNPM_SHARE_DIR)'/store/v10|g' node_modules/.modules.yaml
	mkdir -p $(NANOKVM_SERVER_NODE_CACHE_DIR)
	[ -e $(NANOKVM_SERVER_NODE_CACHE_DIR)/corepack ] || mv $(@D)/web/node_modules/.cache/node/corepack $(NANOKVM_SERVER_NODE_CACHE_DIR)/
	[ -e $(NANOKVM_SERVER_NODE_CACHE_DIR)/corepack/v1 ] || ln -s . $(NANOKVM_SERVER_NODE_CACHE_DIR)/corepack/v1
	rm -rf $(@D)/web/node_modules/.cache/node/corepack
	mkdir -p $(NANOKVM_SERVER_PNPM_CACHE_DIR)
	[ -e $(NANOKVM_SERVER_PNPM_CACHE_DIR)/metadata-v1.3 ] || mv $(@D)/web/node_modules/.cache/pnpm/metadata-v1.3 $(NANOKVM_SERVER_PNPM_CACHE_DIR)/
	rm -rf $(@D)/web/node_modules/.cache/
	mkdir -p $(NANOKVM_SERVER_PNPM_SHARE_DIR)
	[ -e $(NANOKVM_SERVER_PNPM_SHARE_DIR)/store ] || mv $(@D)/web/node_modules/.local/share/pnpm/store $(NANOKVM_SERVER_PNPM_SHARE_DIR)/
	rm -rf $(@D)/web/node_modules/.local/
	#cd $(@D)/$(NANOKVM_SERVER_GOMOD) && GOPROXY=direct GOSUMDB="sum.golang.org" $(GO_BIN) mod vendor
	#cd $(@D)/web && $(HOST_COREPACK) pnpm fetch
	cd $(@D)/$(NANOKVM_SERVER_GOMOD) ; \
	[ -e $(@D)/$(NANOKVM_SERVER_GOMOD)/vendor ] || GOPROXY=direct GOSUMDB="sum.golang.org" $(GO_BIN) mod tidy
	cd $(@D)/$(NANOKVM_SERVER_GOMOD) ; \
	sed -i 's|-L../dl_lib -lkvm|-L../dl_lib -L$(TARGET_DIR)/usr/lib -lkvm|g' common/kvm_vision.go ; \
	sed -i s/' -lkvm$$'/' -lkvm -lmaixcam_lib -latomic -lae -laf -lawb -lcvi_bin -lcvi_bin_isp -lini -lisp -lisp_algo -lgdc -lrgn -lsys -lvdec -lvenc -lvi -lvo -lvpss'/g common/kvm_vision.go
	if [ -e $(@D)/$(NANOKVM_SERVER_GOMOD)/dl_lib/libkvm_mmf.so ]; then \
		cd $(@D)/$(NANOKVM_SERVER_GOMOD) ; \
		sed -i s/'maixcam_lib'/'kvm_mmf'/g common/kvm_vision.go ; \
	fi
	cd $(@D)/$(NANOKVM_SERVER_GOMOD) ; \
	CGO_ENABLED=1 $(NANOKVM_SERVER_GO_ENV) $(GO_BIN) build -mod vendor -x -ldflags="-extldflags '-Wl,-rpath,\$$ORIGIN/dl_lib'"
	#cd $(@D)/web && \
	#$(HOST_COREPACK) install -g pnpm@$(NANOKVM_SERVER_PNPM_VERSION)+sha1.$(NANOKVM_SERVER_PNPM_SHA_SUM) && \#
	cd $(@D)/web && $(HOST_COREPACK) use pnpm@$(NANOKVM_SERVER_PNPM_VERSION)+sha1.$(NANOKVM_SERVER_PNPM_SHA_SUM)
	#cd $(@D)/web && $(HOST_COREPACK) pnpm fetch --store-dir $(NANOKVM_SERVER_PNPM_SHARE_DIR)/store/v10
	cd $(@D)/web && $(HOST_COREPACK) pnpm install --store-dir $(NANOKVM_SERVER_PNPM_SHARE_DIR)/store/v10 -r --offline
	cd $(@D)/web && $(HOST_COREPACK) pnpm build
endef

define NANOKVM_SERVER_INSTALL_TARGET_CMDS
	if [ "X$(BR2_PACKAGE_TAILSCALE_RISCV64)" = "Xy" ]; then \
		rm -f $(TARGET_DIR)/etc/tailscale_disabled ; \
	else \
		mkdir -pv $(TARGET_DIR)/etc/ ; \
		touch $(TARGET_DIR)/etc/tailscale_disabled ; \
	fi
	mkdir -pv $(TARGET_DIR)/kvmapp/
	#touch $(TARGET_DIR)/kvmapp/force_dl_lib
	mkdir -pv $(TARGET_DIR)/kvmapp/server/
	rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/server/NanoKVM-Server $(TARGET_DIR)/kvmapp/server/
	if [ -e ${@D}/support/sg2002/kvm_system/kvm_system ]; then \
		mkdir -pv $(TARGET_DIR)/kvmapp/kvm_system/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/support/sg2002/kvm_system/kvm_system $(TARGET_DIR)/kvmapp/kvm_system/ ; \
	else \
		rm -f $(TARGET_DIR)/kvmapp/kvm_system/kvm_system ; \
	fi
	if [ -e $(@D)/tools/logo_generator ]; then \
		mkdir -pv $(TARGET_DIR)/kvmapp/tools/logo_generator/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/tools/logo_generator/logo_generator.py $(TARGET_DIR)/kvmapp/tools/logo_generator/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/tools/logo_generator/readme.md $(TARGET_DIR)/kvmapp/tools/logo_generator/ ; \
		chmod ugo+rx $(TARGET_DIR)/kvmapp/tools/logo_generator/logo_generator.py ; \
	fi
	if [ -e $(@D)/tools/nanokvm_update_edid ]; then \
		mkdir -pv $(TARGET_DIR)/kvmapp/tools/nanokvm_update_edid/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/tools/nanokvm_update_edid/nanokvm_update_edid $(TARGET_DIR)/kvmapp/tools/nanokvm_update_edid/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/tools/nanokvm_update_edid/E21_NanoKVM.bin $(TARGET_DIR)/kvmapp/tools/nanokvm_update_edid/ ; \
	fi
	mkdir -pv $(TARGET_DIR)/kvmapp/server/dl_lib/
	rsync -r --verbose --links --safe-links --hard-links ${@D}/server/dl_lib/ $(TARGET_DIR)/kvmapp/server/dl_lib/
	mkdir -pv $(TARGET_DIR)/kvmapp/server/web/
	rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/web/dist/ $(TARGET_DIR)/kvmapp/server/web/
endef

$(eval $(generic-package))
