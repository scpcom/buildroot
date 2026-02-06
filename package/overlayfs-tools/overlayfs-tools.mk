################################################################################
#
# overlayfs-tools
#
################################################################################

OVERLAYFS_TOOLS_VERSION = v2025.01
OVERLAYFS_TOOLS_SITE = https://github.com/kmxz/overlayfs-tools
OVERLAYFS_TOOLS_SITE_METHOD = git

OVERLAYFS_TOOLS_DEPENDENCIES += host-pkgconf

ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),)
OVERLAYFS_TOOLS_DEPENDENCIES += musl-fts
OVERLAYFS_TOOLS_LIBS += -lfts
endif

$(eval $(meson-package))
