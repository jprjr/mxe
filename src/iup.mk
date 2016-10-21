# This file is part of MXE. See LICENSE.md for licensing information.
PERCENT := %

PKG             := iup
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.20
$(PKG)_CHECKSUM := bb707edc427f44f6f7343b30aa4f90b7cd87627f5267dd5b974910ac1aaad6af
$(PKG)_SUBDIR   := iup
$(PKG)_FILE     := iup-$($(PKG)_VERSION)_Sources.tar.gz
$(PKG)_URL      := https://sourceforge.net/projects/iup/files/$($(PKG)_VERSION)/Docs$(PERCENT)20and$(PERCENT)20Sources/iup-$($(PKG)_VERSION)_Sources.tar.gz
$(PKG)_DEPS     := gcc lua im cd

define $(PKG)_UPDATE
    echo 'TODO: write update script for iup.' >&2;
    echo $(iup_VERSION)
endef

define $(PKG)_TEC_UNAME
$(if $(BUILD_STATIC),mingw4@win-suffix@,dllw4@win-suffix@)
endef

define $(PKG)_BUILD_CMD_COMMON
	IM_INC='$(PREFIX)/$(TARGET)/include/im' \
	CD_INC='$(PREFIX)/$(TARGET)/include/cd' \
	IM_LIB='$(PREFIX)/$(TARGET)/lib' \
	CD_LIB='$(PREFIX)/$(TARGET)/lib' \
	$(MAKE) -j1 \
	  TEC_SYSNAME=@tec-sysname@ \
	  TEC_UNAME=$($(PKG)_TEC_UNAME) \
	  CC=$(TARGET)-gcc \
	  CPPC=$(TARGET)-g++ \
	  RANLIB=$(TARGET)-ranlib \
	  AR=$(TARGET)-ar \
	  LD=$(TARGET)-g++ \
	  LINKER=$(TARGET)-g++ \
	  RCC=$(TARGET)-windres \
	  USE_LUA_VERSION=$(lua_DLLVER) \
	  LIBLUA_SFX='' \
	  LUA_INC='$(PREFIX)/$(TARGET)/include' \
	  DLIBEXT=dll \
	  NO_DYNAMIC=$(if $(BUILD_STATIC),Yes,No) \
	  NO_STATIC=$(if $(BUILD_STATIC),No,Yes)
endef

define $(PKG)_BUILD
	cp '$(1)/etc/iup.rc' '$(1)/srcconsole/iup.rc'
    # build and install the library
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' LIBS='-lgdi32 -lcomdlg32 -lcomctl32 -luuid -loleaut32 -lole32 -lm' iup
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' LIBS='-liup -lopengl32 -lm' iupgl
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iupcd
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iupcontrols
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iupmatrixex
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iupglcontrols
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iup_plot
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iup_mglplot
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iup_scintilla
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iupim
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iupimglib
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' ledc
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srcole' iupole
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)' iuptuio
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iuplua
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluacd
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluacontrols
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluamatrixex
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluagl
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluaglcontrols
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iuplua_plot
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iuplua_mglplot
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iuplua_scintilla
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluaim
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluaimglib
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluatuio
	$($(PKG)_BUILD_CMD_COMMON) -C '$(1)/srclua5' iupluaole

	$(INSTALL) -d '$(PREFIX)/$(TARGET)/include/iup'
	$(INSTALL) -d '$(PREFIX)/$(TARGET)/lib'
	$(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/lua/$(lua_SHORTVER)'

	$(INSTALL) -m644 '$(SOURCE_DIR)/include/'*.h '$(PREFIX)/$(TARGET)/include/iup'

	$(foreach library,iup iupgl iupcd iupcontrols iup_plot iupim iupimglib iupole,
		$(INSTALL) -m644 '$(SOURCE_DIR)/lib/$($(PKG)_TEC_UNAME)/lib$(library).$(LIB_SUFFIX)' \
			'$(PREFIX)/$(TARGET)/lib/'
	)

	$(foreach luamod,iuplua iupluacd iupluacontrols iupluamatrixex iupluagl iupluaglcontrols iuplua_plot iuplua_mglplot iuplua_scintilla iupluaim iupluaimglib iupluatuio iupluaole,
		$(INSTALL) -m644 '$(SOURCE_DIR)/lib/$($(PKG)_TEC_UNAME)/Lua/lib$(luamod)$(lua_DLLVER).$(LIB_SUFFIX)' \
			'$(PREFIX)/$(TARGET)/lib/lib$(luamod)$(lua_DLLVER).$(LIB_SUFFIX)'
		ln -sf '$(PREFIX)/$(TARGET)/lib/lib$(luamod)$(lua_DLLVER).$(LIB_SUFFIX)' \
			'$(PREFIX)/$(TARGET)/lib/lua/$(lua_SHORTVER)/$(luamod).$(LIB_SUFFIX)'
	)

    # create pkg-config files
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'prefix=$(PREFIX)/$(TARGET)'; \
     echo 'libdir=$${prefix}/lib'; \
     echo 'includedir=$${prefix}/include'; \
     echo ''; \
	 echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: Cross platform window toolkit'; \
     echo 'Libs: -L$${libdir} -liup';  \
     echo 'Cflags: -I$${includedir}/iup';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'
endef

$(PKG)_BUILD_i686-w64-mingw32 = $(subst @tec-sysname@,Win32,$(subst @win-suffix@,,$($(PKG)_BUILD)))
$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @tec-sysname@,Win64,$(subst @win-suffix@,_64,$($(PKG)_BUILD)))
