################################################################################
#
# python-progress
#
################################################################################

PYTHON_PROGRESS_VERSION = 1.6.1
PYTHON_PROGRESS_SOURCE = progress-$(PYTHON_PROGRESS_VERSION).tar.gz
PYTHON_PROGRESS_SITE = https://files.pythonhosted.org/packages/ac/26/3b086f0c5d6c1c18c2430d6fac3a99d79553884ca6cdf759cf256dd43b7d
PYTHON_PROGRESS_SETUP_TYPE = setuptools
PYTHON_PROGRESS_LICENSE = Apache-2.0
PYTHON_PROGRESS_LICENSE_FILES = LICENSE
PYTHON_PROGRESS_CPE_ID_VENDOR = python
PYTHON_PROGRESS_CPE_ID_PRODUCT = progress

$(eval $(python-package))
$(eval $(host-python-package))
