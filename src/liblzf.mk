# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := liblzf
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.6
$(PKG)_CHECKSUM := 41ed86a1bd3a9485612f7a7c1d3c9962d2fe771e55dc30fcf45bd419c39aab8d
$(PKG)_SUBDIR   := liblzf-$($(PKG)_VERSION)
$(PKG)_FILE     := liblzf-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://dist.schmorp.de/liblzf/liblzf-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := gcc

define $(PKG)_UPDATE
    echo 'TODO: write update script for liblzf.' >&2;
    echo $(liblzf_VERSION)
endef

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
	cp "$(SOURCE_DIR)/lzf.h" "$(BUILD_DIR)"
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install \
        bin_PROGRAMS= \
        sbin_PROGRAMS= \
        noinst_PROGRAMS=

    # create pkg-config files
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: A very small data compression library'; \
     echo 'Libs: -llzf';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'
endef
