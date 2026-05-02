################################################################################
#
# maix-cdk
#
################################################################################

MAIX_CDK_VERSION = b29c951647df74e4efa55fd4454efb37e4554be0
MAIX_CDK_SITE = https://github.com/sipeed/MaixCDK
MAIX_CDK_SITE_METHOD = git

MAIX_CDK_DL_PKGS_REF = c378843eec5f1f0892b1e194d43fc8470d167306
MAIX_CDK_DL_PKGS_URL = https://github.com/scpcom/maixcdk-dl-pkgs

MAIX_CDK_PLATFORM = maixcam

MAIX_CDK_SAMPLE = rtsp_demo

MAIX_CDK_DEPENDENCIES =\
	host-cmake \
	host-pkgconf \
	host-python3 \
	host-python-pip \
	host-python-maixtool \
	host-python-setuptools

ifeq ($(BR2_PACKAGE_MAIX_CDK_ALL_DEPENDENCIES),y)
MAIX_CDK_DEPENDENCIES +=\
	alsa-lib \
	ffmpeg \
	harfbuzz \
	libxml2 \
	opencv4 \
	python3 \
	xz
endif

ifeq ($(BR2_PACKAGE_MAIX_CDK_NN_TPU),y)
MAIX_CDK_DEPENDENCIES += sophgo-library
endif

ifeq ($(BR2_TOOLCHAIN_BUILDROOT),y)
#MAIX_CDK_TOOLCHAIN_BIN := $(HOST_DIR)/bin
MAIX_CDK_TOOLCHAIN_PREFIX := $(ARCH)-buildroot-linux-gnu-
else
MAIX_CDK_TOOLCHAIN_BIN := $(TOOLCHAIN_EXTERNAL_BIN)
MAIX_CDK_TOOLCHAIN_PREFIX := $(TOOLCHAIN_EXTERNAL_PREFIX)-
endif

# maixcam pre-built binaries are only for riscv64
# MaixCDK searches for "musl" or "glibc" in toolchain path
MAIX_CDK_TOOLCHAIN_ARCH := $(BR2_ARCH)
MAIX_CDK_TOOLCHAIN_LIBC := $(findstring musl,$(realpath $(MAIX_CDK_TOOLCHAIN_BIN)))

ifeq ($(findstring CV180X,$(TARGET_DIR)),CV180X)
MAIX_CDK_TOOLCHAIN_CHIP := CV180X
else
MAIX_CDK_TOOLCHAIN_CHIP := CV181X
endif

MAIX_CDK_HARFBUZZ_VER = 8.2.1
MAIX_CDK_OPENCV_VER = 4.9.0

MAIX_CDK_EXT_MIDDLEWARE = $(realpath $(TOPDIR)/../middleware)
MAIX_CDK_EXT_MAIXCAM_LIB = sample/test_mmf/maixcam_lib/release.linux/libmaixcam_lib.so
MAIX_CDK_EXT_OSDRV = $(realpath $(TOPDIR)/../osdrv)

MAIX_CDK_MIDDLEWARE = components/3rd_party/sophgo-middleware/sophgo-middleware
MAIX_CDK_MIDDLEWARE_SRC=$(shell [ -e $(MAIX_CDK_EXT_MIDDLEWARE)/Makefile -a ! -e $(MAIX_CDK_EXT_MIDDLEWARE)/v2/Makefile ] && echo "$(MAIX_CDK_EXT_MIDDLEWARE)" || echo "$(MAIX_CDK_EXT_MIDDLEWARE)/v2")
MAIX_CDK_MIDDLEWARE_SUBDIRS = 3rdparty/inih component include lib modules/ive/include pkgconfig sample/common sample/test_mmf/maixcam_lib/release.linux

MAIX_CDK_MAIXCAM_DIST = examples/$(MAIX_CDK_SAMPLE)/dist/$(MAIX_CDK_SAMPLE)_release

define MAIX_CDK_POST_EXTRACT_FIXUP
	mkdir -pv $(@D)/dl
	cd $(@D)/dl && git clone --depth 1 $(MAIX_CDK_DL_PKGS_URL) pkgs
	cd $(@D)/dl/pkgs && git checkout $(MAIX_CDK_DL_PKGS_REF)
	mv $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2 $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2-cdk
	mkdir $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2
	for d in $(MAIX_CDK_MIDDLEWARE_SUBDIRS) ; do \
		mkdir -p $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/$$d ; \
		rsync -r --verbose --exclude=mod_tmp --copy-dirlinks --copy-links --hard-links $(MAIX_CDK_MIDDLEWARE_SRC)/$$d/ $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/$$d/ ; \
	done
	mkdir $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/uapi
	if [ -e $(MAIX_CDK_EXT_OSDRV)/interdrv/include -a ! -e $(MAIX_CDK_EXT_OSDRV)/interdrv/v2/include ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(MAIX_CDK_EXT_OSDRV)/interdrv/include/common/uapi/ $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/uapi/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(MAIX_CDK_EXT_OSDRV)/interdrv/include/chip/mars/uapi/ $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/uapi/ ; \
	else \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(MAIX_CDK_EXT_OSDRV)/interdrv/v2/include/common/uapi/ $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/uapi/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(MAIX_CDK_EXT_OSDRV)/interdrv/v2/include/chip/mars/uapi/ $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/uapi/ ; \
	fi
	rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2-cdk/sample/vio/ $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/sample/vio/
	if grep -q stSnsGc02m1_Obj $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/sample/common/sample_common_sensor.c ; then \
		if ! grep -q stSnsGc02m1_Obj $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/include/cvi_sns_ctrl.h ; then \
			sed -i s/stSnsGc02m1b_Obj/stSnsGc02m1_Obj/g $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/include/cvi_sns_ctrl.h ; \
		fi ; \
	fi
	if [ ! -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/3rd/libcli.so ]; then \
		sed -i /'$${mmf_lib_dir}.3rd.libcli.so'/d $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i /'$${mmf_lib_dir}.3rd.libcli.so'/d $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ ! -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libjson-c.so.5 ]; then \
		sed -i /'$${mmf_lib_dir}.libjson-c.so.5'/d $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i /'$${mmf_lib_dir}.libjson-c.so.5'/d $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libcvi_dnvqe.so -a ! -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libdnvqe.so ]; then \
		sed -i s/'libdnvqe.so'/'libcvi_dnvqe.so'/g $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i s/'libdnvqe.so'/'libcvi_dnvqe.so'/g $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libcvi_ssp2.so ]; then \
		sed -i 's|$${mmf_lib_dir}/libcvi_dnvqe.so|\$${mmf_lib_dir}/libcvi_dnvqe.so $${mmf_lib_dir}/libcvi_ssp2.so|g' $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i 's|$${mmf_lib_dir}/libcvi_dnvqe.so|\$${mmf_lib_dir}/libcvi_dnvqe.so $${mmf_lib_dir}/libcvi_ssp2.so|g' $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libgdc.so -a ! -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libosdc.so ]; then \
		sed -i s/'libosdc.so'/'libgdc.so'/g $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i s/'libosdc.so'/'libgdc.so'/g $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libvi.so -a ! -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libvpu.so ]; then \
		sed -i s/'libvpu.so'/'libvi.so'/g $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i s/'libvpu.so'/'libvi.so'/g $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libvo.so -a \
	     -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/libvpss.so -a \
	     -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/lib/librgn.so ]; then \
		sed -i 's|$${mmf_lib_dir}/libvi.so|\$${mmf_lib_dir}/libvi.so $${mmf_lib_dir}/libvo.so $${mmf_lib_dir}/libvpss.so $${mmf_lib_dir}/librgn.so|g' $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i 's|$${mmf_lib_dir}/libvi.so|\$${mmf_lib_dir}/libvi.so $${mmf_lib_dir}/libvo.so $${mmf_lib_dir}/libvpss.so $${mmf_lib_dir}/librgn.so|g' $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/uapi/linux/cvi_cv181x_defines.h ]; then \
		sed -i 's|^list.APPEND ADD_INCLUDE $${middleware_include_dir}.|list(APPEND ADD_INCLUDE $${middleware_include_dir})\n\nlist(APPEND ADD_DEFINITIONS -D__$(MAIX_CDK_TOOLCHAIN_CHIP)__)|g' $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i 's|^list.APPEND ADD_INCLUDE "include".|list(APPEND ADD_INCLUDE "include")\n\nlist(APPEND ADD_DEFINITIONS -D__$(MAIX_CDK_TOOLCHAIN_CHIP)__)|g' $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/component/isp/common/sensor_list.h ]; then \
		sed -i 's|^    $${middleware_src_path}/v2/component/panel/sg200x|    $${middleware_src_path}/v2/component/isp/common\n    $${middleware_src_path}/v2/component/panel/sg200x|g' $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i 's|^append_srcs_dir(middleware_src_dir  $${middleware_src_path}/v2/sample/common|append_srcs_dir(middleware_src_dir  $${middleware_src_path}/v2/sample/common\n                                    $${middleware_src_path}/v2/component/isp/common|g' $(@D)/components/3rd_party/sophgo-middleware/CMakeLists.txt ; \
		sed -i 's|^        $${middleware_src_path}/v2/component/panel/sg200x|        $${middleware_src_path}/v2/component/isp/common\n        $${middleware_src_path}/v2/component/panel/sg200x|g' $(@D)/components/maixcam_lib/CMakeLists.txt ; \
		sed -i 's|^    append_srcs_dir(middleware_src_dir  $${middleware_src_path}/v2/sample/common|    append_srcs_dir(middleware_src_dir  $${middleware_src_path}/v2/component/isp/common\n                                        $${middleware_src_path}/v2/sample/common|g' $(@D)/components/maixcam_lib/CMakeLists.txt ; \
	fi
	if [ -e ${@D}/components/maixcam_lib/lib_$(MAIX_CDK_PLATFORM) -a ! -e ${@D}/components/maixcam_lib/lib ]; then \
		ln -s lib_$(MAIX_CDK_PLATFORM) ${@D}/components/maixcam_lib/lib ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/$(MAIX_CDK_EXT_MAIXCAM_LIB) -a "X$(BR2_PACKAGE_MAIX_CDK_KEEP_MAIXCAM_LIB)" != "Xy" -a "$(MAIX_CDK_PLATFORM)" = "maixcam" ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/$(MAIX_CDK_EXT_MAIXCAM_LIB) ${@D}/components/maixcam_lib/lib/ ; \
	fi
	if [ -e $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/$(MAIX_CDK_EXT_MAIXCAM_LIB) -a "X$(BR2_PACKAGE_MAIX_CDK_KEEP_MAIXCAM_LIB)" != "Xy" -a -e ${@D}/components/maixcam_lib/lib_maixcam ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(@D)/$(MAIX_CDK_MIDDLEWARE)/v2/$(MAIX_CDK_EXT_MAIXCAM_LIB) ${@D}/components/maixcam_lib/lib_maixcam/ ; \
	fi
	if [ "X$(BR2_ARM_EABIHF)" = "Xy" -a -e $(@D)/components/3rd_party/omv/omv/ports/common/arm_math_types.h ]; then \
	  sed -i s/'#define ARM_MATH_DSP'/'#define BROKEN_ARM_MATH_DSP'/g $(@D)/components/3rd_party/omv/omv/ports/common/arm_math_types.h ; \
	fi
	@$(eval OPENCV4_SUFFIX=$(shell echo "$(OPENCV4_VERSION)" | cut -d '.' -f 1-2 | tr -d '.'))
	@$(eval PYVER_MAJOR=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 1))
	@$(eval PYVER_MINOR=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 2))
	@$(eval PYVER_PATCH=$(shell echo $(PYTHON3_VERSION) | cut -d '.' -f 3))
	if [ "X$(BR2_PACKAGE_MAIX_CDK_ALL_DEPENDENCIES)" = "Xy" -a "$(MAIX_CDK_OPENCV_VER)-$(MAIX_CDK_TOOLCHAIN_ARCH)-$(MAIX_CDK_TOOLCHAIN_LIBC)" != "$(OPENCV4_VERSION)-riscv64-musl" ]; then \
		sed -i 's|set(alsa_lib_dir "lib")|set(alsa_lib_dir "$(TARGET_DIR)/usr/lib")|g' $(@D)/components/3rd_party/alsa_lib/CMakeLists.txt ; \
		sed -i 's|set(alsa_lib_include_dir "include")|set(alsa_lib_include_dir "$(TARGET_DIR)/usr/include")|g' $(@D)/components/3rd_party/alsa_lib/CMakeLists.txt ; \
		sed -i 's|set(src_path "$${ffmpeg_unzip_path}/ffmpeg")|set(src_path "$(TARGET_DIR)/usr")|g' $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		[ -e $(TARGET_DIR)/usr/lib/libavresample.so ] || sed -i /libavresample.so/d $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		sed -i 's|#.*                            $${src_path}/lib/libswscale.so|#                            $${non_path}/lib/libswscale.so|g' $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		sed -i 's|                            $${src_path}/lib/libswscale.so|                            $${src_path}/lib/libswscale.so\n                            $${src_path}/lib/liblzma.so\n                            $${src_path}/lib/libxml2.so\n                            $${src_path}/lib/libz.so\n                            $${src_path}/lib/libbz2.so\n                            $${src_path}/lib/libssl.so\n                            $${src_path}/lib/libcrypto.so|g' $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		sed -i s/'# list.APPEND ADD_REQUIREMENTS.$$'/'list(APPEND ADD_REQUIREMENTS alsa_lib)'/g $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		rm -f $(@D)/components/3rd_party/FFmpeg/component.py ; \
		sed -i s/'CONFIG_COMPONENTS_COMPILE_FROM_SOURCE'/'1'/g $(@D)/components/3rd_party/harfbuzz/CMakeLists.txt ; \
		rm -f $(@D)/components/3rd_party/harfbuzz/component.py ; \
		sed -i 's|EXISTS "$${CMAKE_CURRENT_LIST_DIR}/opencv4_lib_maixcam"|EXISTS "$(TARGET_DIR)/usr"|g'  $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i 's|opencv_lib_dir "$${CMAKE_CURRENT_LIST_DIR}/opencv4_lib_maixcam"|opencv_lib_dir "$(TARGET_DIR)/usr"|g'  $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i 's|opencv_lib_dir "$${DL_EXTRACTED_PATH}/opencv/opencv4/opencv4_lib_maixcam_musl_$${version_str}"|opencv_lib_dir "$(TARGET_DIR)/usr"|g'  $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i 's|opencv_lib_dir "$${DL_EXTRACTED_PATH}/opencv/opencv4/opencv4_lib_maixcam2_glibc_$${version_str}"|opencv_lib_dir "$(TARGET_DIR)/usr"|g'  $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i 's|$${opencv_lib_dir}/dl_lib|$${opencv_lib_dir}/lib|g'  $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i s/'list.APPEND ADD_REQUIREMENTS pthread dl.$$'/'list(APPEND ADD_REQUIREMENTS pthread dl atomic)'/g $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i s/'# list.APPEND ADD_REQUIREMENTS pthread dl atomic.$$'/'list(APPEND ADD_REQUIREMENTS pthread dl atomic)'/g $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i s/'version_str "$(MAIX_CDK_OPENCV_VER)"'/'version_str "$(OPENCV4_VERSION)"'/g $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		sed -i s/'so_suffix_number "4.."'/'so_suffix_number "$(OPENCV4_SUFFIX)"'/g $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		rm -f $(@D)/components/3rd_party/opencv/component.py ; \
		mkdir -pv $(@D)/dl/extracted/harfbuzz_srcs/harfbuzz-$(MAIX_CDK_HARFBUZZ_VER)/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links --exclude=build --exclude=test $(@D)/../harfbuzz-$(HARFBUZZ_VERSION)/ $(@D)/dl/extracted/harfbuzz_srcs/harfbuzz-$(MAIX_CDK_HARFBUZZ_VER)/ ; \
		sed -i 's|if(CONFIG_TOOLCHAIN_PATH MATCHES "musl")|if(EXISTS "$(TARGET_DIR)/usr/lib/python$${py_ver_short}")|g' $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		sed -i 's|$${DL_EXTRACTED_PATH}/python3/python3_lib_maixcam_musl_3.11.6|$(TARGET_DIR)/usr|g' $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		sed -i 's|$${DL_EXTRACTED_PATH}/python3/python3.13_maixcam2|$(TARGET_DIR)/usr|g' $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		sed -i s/'CONFIG_PYTHON_VERSION_MAJOR "3"'/'CONFIG_PYTHON_VERSION_MAJOR "$(PYVER_MAJOR)"'/g $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		sed -i s/'CONFIG_PYTHON_VERSION_MINOR "11"'/'CONFIG_PYTHON_VERSION_MINOR "$(PYVER_MINOR)"'/g $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		sed -i s/'CONFIG_PYTHON_VERSION_PATCH "6"'/'CONFIG_PYTHON_VERSION_PATCH "$(PYVER_PATCH)"'/g $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		sed -i s/'3.11.6'/'$(PYTHON3_VERSION)'/g $(@D)/components/3rd_party/python3/CMakeLists.txt ; \
		rm -f $(@D)/components/3rd_party/python3/component.py ; \
	fi
	if [ "X$(BR2_PACKAGE_MAIX_CDK_NN_TPU)" != "Xy" ]; then \
		sed -i /'list.APPEND ADD_REQUIREMENTS cvi_tpu.'/d $(@D)/components/maixcam_lib/CMakeLists.txt ; \
		sed -i /'"cvi_tpu",'/d $(@D)/components/maixcam_lib/component.py ; \
	fi
endef
MAIX_CDK_POST_EXTRACT_HOOKS += MAIX_CDK_POST_EXTRACT_FIXUP

define MAIX_CDK_BUILD_CMDS
	sed -i s/'^    url: .*'/'    url:'/g $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	sed -i s/'^    sha256sum: .*'/'    sha256sum:'/g $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	sed -i s/'^    filename: .*'/'    filename:'/g $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	sed -i s/'^    path: .*'/'    path:'/g $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	if [ "X$(MAIX_CDK_TOOLCHAIN_BIN)" = "X"  -o ! -e "$(MAIX_CDK_TOOLCHAIN_BIN)" ]; then \
		sed -i 's|^    bin_path: .*|    bin_path: '$(HOST_DIR)/bin'|g' $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml ; \
	else \
		sed -i 's|^    bin_path: .*|    bin_path: '$(realpath $(MAIX_CDK_TOOLCHAIN_BIN))'|g' $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml ; \
	fi
	sed -i 's|^    prefix: .*|    prefix: '$(MAIX_CDK_TOOLCHAIN_PREFIX)'|g' $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	sed -i "s|^    c_flags: .*|    c_flags: $(TARGET_LDFLAGS)|g" $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	sed -i "s|^    cxx_flags: .*|    cxx_flags: $(TARGET_LDFLAGS)|g" $(@D)/platforms/$(MAIX_CDK_PLATFORM).yaml
	sed -i 's|COMMAND python |COMMAND '$(HOST_DIR)/bin/python3' |g' $(@D)/tools/cmake/*.cmake
	sed -i 's|COMMAND python3 |COMMAND '$(HOST_DIR)/bin/python3' |g' $(@D)/tools/cmake/*.cmake
	sed -i 's|set.$${python} python3 |set($${python} '$(HOST_DIR)/bin/python3' |g' $(@D)/tools/cmake/*.cmake
	[ "X$(BR2_TOOLCHAIN_BUILDROOT)" != "Xy" ] || sed -i /'^    $${strip_cmd}'/d $(@D)/tools/cmake/gen_binary.cmake
	if [ "X$(BR2_PACKAGE_MAIX_CDK_ALL_DEPENDENCIES)" = "Xy" -a "$(MAIX_CDK_OPENCV_VER)-$(MAIX_CDK_TOOLCHAIN_ARCH)-$(MAIX_CDK_TOOLCHAIN_LIBC)" != "$(OPENCV4_VERSION)-riscv64-musl" ]; then \
		sed -i 's|#.*                            $${src_path}/lib/libswscale.so|#                            $${non_path}/lib/libswscale.so|g' $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		for j in libbrotlicommon libbrotlidec libdrm libexpat libfontconfig libfreetype libicudata libicuuc libicui18n ; do \
		for k in $(TARGET_DIR)/usr/lib/$${j}.so ; do \
			l=`basename $$k` ; \
			[ -e $$k ] || continue ; \
			sed -i 's|                            $${src_path}/lib/libswscale.so|                            $${src_path}/lib/libswscale.so\n                            $${src_path}/lib/'$${l}'|g' $(@D)/components/3rd_party/FFmpeg/CMakeLists.txt ; \
		done ; \
		done ; \
		for j in libtbb libjpeg libsharpyuv libwebp libpng16 libtiff libz ; do \
		for k in $(TARGET_DIR)/usr/lib/$${j}.so.* ; do \
			l=`basename $$k` ; \
			[ -e $$k ] || continue ; \
			echo $$l | cut -d '.' -f 3- | grep -q '\.' && continue ; \
			sed -i 's|                                            "$${opencv_lib_dir}/lib/libopencv_video.so.$${so_suffix_number}"|                                            "$${opencv_lib_dir}/lib/libopencv_video.so.$${so_suffix_number}"\n                                            "$${opencv_lib_dir}/lib/'$$l'"|g' $(@D)/components/3rd_party/opencv/CMakeLists.txt ; \
		done ; \
		done ; \
	fi
	rm -rf $(@D)/components/3rd_party/ax620e_msp/
	if [ "X$(BR2_PACKAGE_MAIX_CDK_NN_TPU)" != "Xy" ]; then \
		rm -rf $(@D)/components/3rd_party/cvi_tpu/ ; \
		rm -rf $(@D)/components/llm/ ; \
		rm -rf $(@D)/components/nn/ ; \
		rm -rf $(@D)/components/vision_extra/ ; \
	elif [ -e $(TARGET_DIR)/mnt/system/opt/cvitek_tpu_sdk ]; then \
		mkdir -p $(@D)/components/3rd_party/cvi_tpu/cvi_tpu_lib ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links $(TARGET_DIR)/mnt/system/opt/cvitek_tpu_sdk/ $(@D)/components/3rd_party/cvi_tpu/cvi_tpu_lib/ ; \
		sed -i s/lib_musl/lib/g $(@D)/components/3rd_party/cvi_tpu/CMakeLists.txt ; \
		sed -i s/lib_glibc/lib/g $(@D)/components/3rd_party/cvi_tpu/CMakeLists.txt ; \
		rm -f $(@D)/components/3rd_party/cvi_tpu/component.py ; \
	fi
	cd $(@D)/ ; \
	#$(HOST_DIR)/bin/python3 -m pip install -r requirements.txt
	if [ "X$(BR2_PACKAGE_MAIX_CDK_ALL_DEPENDENCIES)" = "Xy" ]; then \
		cd $(@D)/examples/$(MAIX_CDK_SAMPLE)/ ; \
		PATH=$(BR_PATH) $(HOST_DIR)/bin/maixcdk build -p $(MAIX_CDK_PLATFORM) ; \
	fi
	if [ ! -e $(@D)/components/nn ]; then \
		rm -rf $(@D)/projects/app_classifier/ ; \
		rm -rf $(@D)/projects/app_detector/ ; \
		rm -rf $(@D)/projects/app_self_learn_tracker/ ; \
		rm -rf $(@D)/projects/app_speech/ ; \
	fi
	if [ -e $(@D)/projects/app_uvc_camera/main/CMakeLists.txt -a ! -e $(@D)/components/nn ]; then \
		sed -i s/'basic nn vision'/'basic vision'/g $(@D)/projects/app_uvc_camera/main/CMakeLists.txt ; \
		sed -i s/'comm nn vision'/'comm vision'/g $(@D)/projects/app_uvc_camera/main/CMakeLists.txt ; \
	fi
	if [ "X$(BR2_PACKAGE_MAIX_CDK_ALL_PROJECTS)" = "Xy" -a -e $(@D)/distapps.sh -a -e $(@D)/projects/build_all.sh ]; then \
		chmod +x $(@D)/projects/build_all.sh ; \
		cd $(@D)/projects/ ; \
		PATH=$(BR_PATH) ./build_all.sh ; \
	fi
	if [ ! -e $(@D)/components/nn ]; then \
		rm -rf $(@D)/examples/bytetrack_demo/ ; \
		rm -rf $(@D)/examples/nn_*/ ; \
		rm -rf $(@D)/examples/rtsp_yolo_demo/ ; \
	fi
	# maixcam2 only
	rm -rf $(@D)/examples/nn_melotts/
	rm -rf $(@D)/examples/nn_whisper/
	if [ -e $(@D)/examples/demo_focus_stack/main/CMakeLists.txt ]; then \
		if grep -q '^"focus-stack/src"' $(@D)/examples/demo_focus_stack/main/CMakeLists.txt ; then \
			if [ ! -e $(@D)/examples/demo_focus_stack/main/focus-stack/src ]; then \
				rm -rf $(@D)/examples/demo_focus_stack/ ; \
			fi ; \
		fi ; \
	fi
	if [ -e $(@D)/examples/image_method/main/CMakeLists.txt ]; then \
		if grep -q '"ed_lib/ED_Lib' $(@D)/examples/image_method/main/CMakeLists.txt ; then \
			if [ ! -e $(@D)/examples/image_method/main/ed_lib/ED_Lib ]; then \
				rm -rf $(@D)/examples/image_method/ ; \
			fi ; \
		fi ; \
	fi
	if [ -e $(@D)/examples/maix_ntp/main/src/main.cpp ]; then \
		if grep -q '^#include "maix_ntp.hpp"' $(@D)/examples/maix_ntp/main/src/main.cpp ; then \
			rm -rf $(@D)/examples/maix_ntp/ ; \
		fi ; \
	fi
	if [ ! -e $(@D)/examples/maixcdk-example/main/CMakeLists.txt ]; then \
		rm -rf $(@D)/examples/maixcdk-example/ ; \
	fi
	if [ -e $(@D)/examples/video_record_mp4/main/src/main.cpp ]; then \
		if grep -q 'v\.record_start' $(@D)/examples/video_record_mp4/main/src/main.cpp ; then \
			rm -rf $(@D)/examples/video_record_mp4/ ; \
		fi ; \
	fi
	if [ -e $(@D)/examples/maix_bm8563/app.yaml ]; then \
		sed -i s/bm8653/bm8563/g $(@D)/examples/maix_bm8563/app.yaml ; \
	fi
	if [ -e $(@D)/examples/mlx90640/app.yaml ]; then \
		sed -i s/mlx90640_$$/mlx90640/g $(@D)/examples/mlx90640/app.yaml ; \
	fi
	if [ -e $(@D)/examples/mlx90640/main/CMakeLists.txt -a -e $(@D)/components/ext_devs/ext_dev_mlx90640 ]; then \
		if ! grep -q ext_dev_mlx90640 $(@D)/examples/mlx90640/main/CMakeLists.txt ; then \
			sed -i s/'APPEND ADD_REQUIREMENTS basic ext_dev)'/'APPEND ADD_REQUIREMENTS basic ext_dev ext_dev_mlx90640)'/g $(@D)/examples/mlx90640/main/CMakeLists.txt ; \
		fi ; \
	fi
	if [ -e $(@D)/examples/i18n/app.yaml ]; then \
		if grep -q 'id: i18n_demo' $(@D)/examples/i18n/app.yaml ; then \
			mv $(@D)/examples/i18n $(@D)/examples/i18n_demo ; \
		fi ; \
	fi
	if [ -e $(@D)/examples/peripheral_gpio/app.yaml ]; then \
		if grep -q 'id: switch_led' $(@D)/examples/peripheral_gpio/app.yaml ; then \
			mv $(@D)/examples/peripheral_gpio $(@D)/examples/switch_led ; \
		fi ; \
	fi
	if [ "X$(BR2_PACKAGE_MAIX_CDK_ALL_EXAMPLES)" = "Xy" -a -e $(@D)/distapps.sh -a -e $(@D)/test/test_examples/test_cases.sh ]; then \
		chmod +x $(@D)/test/test_examples/test_cases.sh ; \
		cd $(@D)/test/test_examples/ ; \
		PATH=$(BR_PATH) ./test_cases.sh $(MAIX_CDK_PLATFORM) 0 ; \
	fi
	if [ "X$(BR2_PACKAGE_MAIX_CDK_ALL_DEPENDENCIES)" != "Xy" ]; then \
		rm -rf $(@D)/components/3rd_party/alsa_lib/ ; \
		rm -rf $(@D)/components/3rd_party/cvi_tpu/ ; \
		rm -rf $(@D)/components/3rd_party/FFmpeg/ ; \
		rm -rf $(@D)/components/3rd_party/harfbuzz/ ; \
		rm -rf $(@D)/components/3rd_party/opencv/ ; \
		rm -rf $(@D)/components/3rd_party/opencv_freetype/ ; \
		rm -rf $(@D)/components/nn/ ; \
		rm -rf $(@D)/components/vision_extra/ ; \
		rm -rf $(@D)/examples/*/ ; \
		rm -rf $(@D)/projects/*/ ; \
	elif [ -e $(@D)/distapps.sh ]; then \
		chmod +x $(@D)/distapps.sh ; \
		cd $(@D)/ ; \
		PATH=$(BR_PATH) ./distapps.sh ; \
	fi
endef

define MAIX_CDK_INSTALL_TARGET_CMDS
	if [ -e  ${@D}/$(MAIX_CDK_MAIXCAM_DIST) -a ! -e ${@D}/$(MAIX_CDK_MAIXCAM_DIST)/dl_lib/libmaixcam_lib.so ] ; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/components/maixcam_lib/lib/libmaixcam_lib.so ${@D}/$(MAIX_CDK_MAIXCAM_DIST)/dl_lib/ ; \
	fi
	if [ -e ${@D}/dist/maixapp/lib -a ! -e ${@D}/dist/maixapp/lib/libmaixcam_lib.so ]; then \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/components/maixcam_lib/lib/libmaixcam_lib.so ${@D}/dist/maixapp/lib/ ; \
	fi
	if [ -e ${@D}/dist/maixapp ]; then \
		mkdir -pv $(TARGET_DIR)/maixapp/ ; \
		rsync -r --verbose --links --safe-links --hard-links ${@D}/dist/maixapp/ $(TARGET_DIR)/maixapp/ ; \
	elif [ -e  ${@D}/$(MAIX_CDK_MAIXCAM_DIST) ]; then \
		mkdir -pv $(TARGET_DIR)/maixapp/lib/ ; \
		mkdir -pv $(TARGET_DIR)/maixapp/apps/$(MAIX_CDK_SAMPLE)/ ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/$(MAIX_CDK_MAIXCAM_DIST)/ $(TARGET_DIR)/maixapp/apps/$(MAIX_CDK_SAMPLE)/ ; \
		rm -rf $(TARGET_DIR)/maixapp/apps/$(MAIX_CDK_SAMPLE)/dl_lib ; \
		ln -s ../../lib $(TARGET_DIR)/maixapp/apps/$(MAIX_CDK_SAMPLE)/dl_lib ; \
		rsync -r --verbose --copy-dirlinks --copy-links --hard-links ${@D}/$(MAIX_CDK_MAIXCAM_DIST)/dl_lib/ $(TARGET_DIR)/maixapp/lib/ ; \
	fi
	if [ -e $(TARGET_DIR)/maixapp ]; then \
		mkdir -pv $(TARGET_DIR)/maixapp/share/font/ ; \
		mkdir -pv $(TARGET_DIR)/maixapp/share/icon/ ; \
		mkdir -pv $(TARGET_DIR)/maixapp/share/picture/ ; \
		mkdir -pv $(TARGET_DIR)/maixapp/share/video/ ; \
		mkdir -pv $(TARGET_DIR)/maixapp/tmp/ ; \
	fi
	if [ -e $(TARGET_DIR)/maixapp -a ! -e $(TARGET_DIR)/maixapp/sys_conf.ini ]; then \
		echo "[language]" > $(TARGET_DIR)/maixapp/sys_conf.ini ; \
		echo "locale=en" >> $(TARGET_DIR)/maixapp/sys_conf.ini ; \
		echo "[comm]" >> $(TARGET_DIR)/maixapp/sys_conf.ini ; \
		echo "method=uart" >> $(TARGET_DIR)/maixapp/sys_conf.ini ; \
	fi
endef

$(eval $(generic-package))
