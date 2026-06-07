################################################################################
#
# python-rich
#
################################################################################

PYTHON_RICH_VERSION = 13.9.4
PYTHON_RICH_SOURCE = rich-$(PYTHON_RICH_VERSION).tar.gz
PYTHON_RICH_SITE = https://files.pythonhosted.org/packages/ab/3a/0316b28d0761c6734d6bc14e770d85506c986c85ffb239e688eeaab2c2bc
PYTHON_RICH_SETUP_TYPE = setuptools
PYTHON_RICH_LICENSE = Apache-2.0
PYTHON_RICH_LICENSE_FILES = LICENSE
PYTHON_RICH_CPE_ID_VENDOR = python
PYTHON_RICH_CPE_ID_PRODUCT = rich
PYTHON_RICH_DEPENDENCIES = \
	host-python-poetry-core \
	python-markdown-it-py \
	python-pygments

$(eval $(python-package))
$(eval $(host-python-package))
