################################################################################
#
# python-mdit-py-plugins
#
################################################################################

PYTHON_MDIT_PY_PLUGINS_VERSION = 0.4.2
PYTHON_MDIT_PY_PLUGINS_SOURCE = mdit_py_plugins-$(PYTHON_MDIT_PY_PLUGINS_VERSION).tar.gz
PYTHON_MDIT_PY_PLUGINS_SITE = https://files.pythonhosted.org/packages/19/03/a2ecab526543b152300717cf232bb4bb8605b6edb946c845016fa9c9c9fd
PYTHON_MDIT_PY_PLUGINS_SETUP_TYPE = setuptools
PYTHON_MDIT_PY_PLUGINS_LICENSE = Apache-2.0
PYTHON_MDIT_PY_PLUGINS_LICENSE_FILES = LICENSE
PYTHON_MDIT_PY_PLUGINS_CPE_ID_VENDOR = python
PYTHON_MDIT_PY_PLUGINS_CPE_ID_PRODUCT = mdit-py-plugins
PYTHON_MDIT_PY_PLUGINS_DEPENDENCIES = \
	python-markdown-it-py

$(eval $(python-package))
$(eval $(host-python-package))
