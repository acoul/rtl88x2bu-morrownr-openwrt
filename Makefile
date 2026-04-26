include $(TOPDIR)/rules.mk

PKG_NAME:=rtl88x2bu-morrownr
PKG_RELEASE=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/morrownr/88x2bu-20210702.git
#PKG_MIRROR_HASH:=d8bc277348cf97a1b645e2c1c07c9a0dcb9ce5796b7fd5bdce87d19b5f3e17bb
PKG_SOURCE_DATE:=2026-01-09
PKG_SOURCE_VERSION:=fecac340fb117eb979f4bb6d28e29730384c382b
PKG_MAINTAINER:=morrownr <https://github.com/morrownr>

PKG_BUILD_PARALLEL:=1

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl88x2bu-morrownr
  SUBMENU:=Wireless Drivers
  TITLE:=Driver for Realtek rtl88x2bu devices
  DEPENDS:=+kmod-cfg80211 +kmod-usb-core +@DRIVER_11N_SUPPORT +@DRIVER_11AC_SUPPORT
  FILES:=\
	$(PKG_BUILD_DIR)/rtl88x2bu.ko
  AUTOLOAD:=$(call AutoProbe,rtl88x2bu)
  PROVIDES:=kmod-rtl88x2bu-morrownr
endef

NOSTDINC_FLAGS := \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(PKG_BUILD_DIR) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-include backport/backport.h

NOSTDINC_FLAGS+=-DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT -DBUILD_OPENWRT

define Build/Clean
        $(call OpenWRT/Clean)
        $(call Build/Clean/Default)
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		CONFIG_RTL8822BU=m \
		modules
endef

$(eval $(call KernelPackage,rtl88x2bu-morrownr))
