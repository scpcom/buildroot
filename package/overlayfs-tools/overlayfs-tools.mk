################################################################################
#
# overlayfs-tools
#
################################################################################

OVERLAYFS_TOOLS_VERSION = 2025.01
OVERLAYFS_TOOLS_BASE = overlayfs-tools-$(OVERLAYFS_TOOLS_VERSION)
OVERLAYFS_TOOLS_SOURCE = v$(OVERLAYFS_TOOLS_VERSION).tar.gz
OVERLAYFS_TOOLS_SITE = https://github.com/kmxz/overlayfs-tools/archive/refs/tags

OVERLAYFS_TOOLS_DEPENDENCIES += host-pkgconf

ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),)
OVERLAYFS_TOOLS_DEPENDENCIES += musl-fts
OVERLAYFS_TOOLS_LIBS += -lfts
endif

$(eval $(meson-package))
