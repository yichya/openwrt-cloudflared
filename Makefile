include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-cloudflared
PKG_VERSION:=2022.5.0
PKG_RELEASE:=1

PKG_LICENSE:=MPLv2
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=yichya <mail@yichya.dev>

PKG_SOURCE:=cloudflared-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/cloudflare/cloudflared/tar.gz/${PKG_VERSION}?
PKG_HASH:=65ad3379f21736fbbda6bd95f23860af9491274fd25b75780ccd9693b332a3f0
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/cloudflare/cloudflared

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/../feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=Custom
	CATEGORY:=Extra packages
	TITLE:=cloudflared
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
	Argo tunnel client
endef

MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS+=$(GO_PKG_VARS)

define Build/Patch
	$(CP) $(PKG_BUILD_DIR)/../cloudflared-$(PKG_VERSION)/* $(PKG_BUILD_DIR)
endef

DATE:=$(shell date -u '+%Y-%m-%d-%H%M UTC')
VERSION_FLAGS:=-X "main.Version=$(PKG_VERSION)" -X "main.BuildTime=$(DATE)"

define Build/Compile
	cd $(PKG_BUILD_DIR); $(GO_PKG_VARS) CGO_ENABLED=0 go build -trimpath -ldflags '-s -w $(VERSION_FLAGS)' -o $(PKG_INSTALL_DIR)/bin/cloudflared ./cmd/cloudflared; 
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./cloudflared.init $(1)/etc/init.d/cloudflared
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/cloudflared $(1)/usr/bin/cloudflared
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./cloudflared.upgrade $(1)/lib/upgrade/keep.d/cloudflared
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
