################################################################################
#
# python-markdown-it-py
#
################################################################################

PYTHON_MARKDOWN_IT_PY_VERSION = 3.0.0
PYTHON_MARKDOWN_IT_PY_SOURCE = markdown-it-py-$(PYTHON_MARKDOWN_IT_PY_VERSION).tar.gz
PYTHON_MARKDOWN_IT_PY_SITE = https://files.pythonhosted.org/packages/38/71/3b932df36c1a044d397a1f92d1cf91ee0a503d91e470cbd670aa66b07ed0
PYTHON_MARKDOWN_IT_PY_SETUP_TYPE = setuptools
PYTHON_MARKDOWN_IT_PY_LICENSE = Apache-2.0
PYTHON_MARKDOWN_IT_PY_LICENSE_FILES = LICENSE
PYTHON_MARKDOWN_IT_PY_CPE_ID_VENDOR = python
PYTHON_MARKDOWN_IT_PY_CPE_ID_PRODUCT = markdown-it-py
PYTHON_MARKDOWN_IT_PY_DEPENDENCIES = \
	python-mdurl

$(eval $(python-package))
$(eval $(host-python-package))
