################################################################################
#
# python-platformdirs
#
################################################################################

PYTHON_PLATFORMDIRS_VERSION = 4.3.7
PYTHON_PLATFORMDIRS_SOURCE = platformdirs-$(PYTHON_PLATFORMDIRS_VERSION).tar.gz
PYTHON_PLATFORMDIRS_SITE = https://files.pythonhosted.org/packages/b6/2d/7d512a3913d60623e7eb945c6d1b4f0bddf1d0b7ada5225274c87e5b53d1
PYTHON_PLATFORMDIRS_SETUP_TYPE = setuptools
PYTHON_PLATFORMDIRS_LICENSE = Apache-2.0
PYTHON_PLATFORMDIRS_LICENSE_FILES = LICENSE
PYTHON_PLATFORMDIRS_CPE_ID_VENDOR = python
PYTHON_PLATFORMDIRS_CPE_ID_PRODUCT = platformdirs
PYTHON_PLATFORMDIRS_DEPENDENCIES = \
	host-python-hatch-vcs \
	host-python-hatchling

$(eval $(python-package))
$(eval $(host-python-package))
