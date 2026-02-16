################################################################################
#
# python-maixtool
#
################################################################################

PYTHON_MAIXTOOL_VERSION = 1.4.4
PYTHON_MAIXTOOL_SOURCE = maixtool-$(PYTHON_MAIXTOOL_VERSION).tar.gz
PYTHON_MAIXTOOL_SITE = https://files.pythonhosted.org/packages/bc/9b/7a46b046ecf5719d9d03f84a606142c39e5747c8ea5d357c75be0582549b
PYTHON_MAIXTOOL_SETUP_TYPE = setuptools
PYTHON_MAIXTOOL_LICENSE = Apache-2.0
PYTHON_MAIXTOOL_LICENSE_FILES = LICENSE
PYTHON_MAIXTOOL_CPE_ID_VENDOR = python
PYTHON_MAIXTOOL_CPE_ID_PRODUCT = maixtool
HOST_PYTHON_MAIXTOOL_DEPENDENCIES = \
	host-python-flask \
	host-python-netifaces \
	host-python-pillow \
	host-python-pyyaml \
	host-python-progress \
	host-python-qrcode \
	host-python-requests

$(eval $(python-package))
$(eval $(host-python-package))
