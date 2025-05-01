################################################################################
#
# mavproxy
#
################################################################################

MAVPROXY_VERSION = master
MAVPROXY_SITE = $(call github,ArduPilot,MAVProxy,$(MAVPROXY_VERSION))
MAVPROXY_SETUP_TYPE = setuptools
MAVPROXY_LICENSE = GPL-2.0
MAVPROXY_LICENSE_FILES = COPYING
MAVPROXY_DEPENDENCIES= python3 pymavlink python-numpy python-serial

$(eval $(python-package))

