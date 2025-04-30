################################################################################
#
# mavlink
#
################################################################################

MAVLINK_VERSION = master
#MAVLINK_SITE = $(call github,ArduPilot,mavlink,$(MAVLINK_VERSION))
MAVLINK_SITE = git@github.com:ArduPilot/mavlink.git
MAVLINK_SITE_METHOD = git
#MAVLINK_INSTALL_STAGING = YES
MAVLINK_LICENSE = MIT
MAVLINK_LICENSE_FILES = LICENSE

MAVLINK_GIT_SUBMODULES = YES

MAVLINK_DEPENDENCIES += host-pkgconf python3 libxml2 python-future python-lxml host-python-lxml host-python-future
MAVLINK_SUPPORTS_IN_SOURCE_BUILD=NO
MAVLINK_INSTALL_STAGING = YES

MAVLINK_CONF_OPTS += -DPython3_EXECUTABLE=$(HOST_DIR)/bin/python3 \
 	-DPython3_INCLUDE_DIRS=$(STAGING_DIR)/usr/include/python$(PYTHON3_VERSION_MAJOR) \
	-DPython3_LIBRARIES=$(STAGING_DIR)/usr/lib/libpython$(PYTHON3_VERSION_MAJOR).so \
	-DPython3_SITELIB=$(STAGING_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages

MAVLINK_CONF_ENV += $(PKG_PYTHON_SETUPTOOLS_ENV)


define MAVLINK_INSTALL_STAGING_CMDS
	@mkdir -p $(STAGING_DIR)/usr/include/mavlink
	cp -r $(@D)/buildroot-build/include/* $(STAGING_DIR)/usr/include
endef

define MAVLINK_INSTALL_TARGET_CMDS
	@echo "skipping"
endef

$(eval $(cmake-package))
