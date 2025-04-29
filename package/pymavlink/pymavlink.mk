################################################################################
#
# pymavlink
#
################################################################################

PYMAVLINK_VERSION = master
PYMAVLINK_SITE = $(call github,ArduPilot,pymavlink,$(PYMAVLINK_VERSION))
PYMAVLINK_SETUP_TYPE = setuptools
PYMAVLINK_LICENSE = GPL-2.0
PYMAVLINK_LICENSE_FILES = COPYING
PYMAVLINK_DEPENDENCIES= host-pkgconf python3 libxml2 python-future python-lxml host-python-lxml host-python-future

PYMAVLINK_BUILD_OPTS = --skip-dependency-check
PYMAVLINK_ENV = MDEF=$(@D)/../mavlink-master/message_definitions


$(eval $(python-package))

