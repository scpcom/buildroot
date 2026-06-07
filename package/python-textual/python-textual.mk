################################################################################
#
# python-textual
#
################################################################################

PYTHON_TEXTUAL_VERSION = 2.1.2
PYTHON_TEXTUAL_SOURCE = textual-$(PYTHON_TEXTUAL_VERSION).tar.gz
PYTHON_TEXTUAL_SITE = https://files.pythonhosted.org/packages/41/62/4af4689dd971ed4fb3215467624016d53550bff1df9ca02e7625eec07f8b
PYTHON_TEXTUAL_SETUP_TYPE = setuptools
PYTHON_TEXTUAL_LICENSE = Apache-2.0
PYTHON_TEXTUAL_LICENSE_FILES = LICENSE
PYTHON_TEXTUAL_CPE_ID_VENDOR = python
PYTHON_TEXTUAL_CPE_ID_PRODUCT = textual
PYTHON_TEXTUAL_DEPENDENCIES = \
	python-markdown-it-py \
	python-mdit-py-plugins \
	python-platformdirs \
	python-pygments \
	python-rich \
	python-typing-extensions \
	python-zipp

$(eval $(python-package))
$(eval $(host-python-package))
