################################################################################
#
# MAVLINK_ROUTER
#
################################################################################

MAVLINK_ROUTER_VERSION = 51983a46cd1f632a5934a29da2dbe5fd7d5c38d4
MAVLINK_ROUTER_SITE = git@github.com:mavlink-router/mavlink-router.git
MAVLINK_ROUTER_LICENSE = APACHE-2.0
MAVLINK_ROUTER_LICENSE_FILES = LICENSE

MAVLINK_ROUTER_SITE_METHOD = git
MAVLINK_ROUTER_GIT_SUBMODULES = YES
MAVLINK_ROUTER_CONF_OPTS += -Dsystemdsystemunitdir=no

$(eval $(meson-package))
