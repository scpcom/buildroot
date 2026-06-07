################################################################################
#
# python-zipp
#
################################################################################

PYTHON_ZIPP_VERSION = 3.21.0
PYTHON_ZIPP_SOURCE = zipp-$(PYTHON_ZIPP_VERSION).tar.gz
PYTHON_ZIPP_SITE = https://files.pythonhosted.org/packages/3f/50/bad581df71744867e9468ebd0bcd6505de3b275e06f202c2cb016e3ff56f
PYTHON_ZIPP_SETUP_TYPE = setuptools
PYTHON_ZIPP_LICENSE = Apache-2.0
PYTHON_ZIPP_LICENSE_FILES = LICENSE
PYTHON_ZIPP_CPE_ID_VENDOR = python
PYTHON_ZIPP_CPE_ID_PRODUCT = zipp
PYTHON_ZIPP_DEPENDENCIES = \
	host-python-setuptools-scm

$(eval $(python-package))
$(eval $(host-python-package))
