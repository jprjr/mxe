# This file is part of MXE. See LICENSE.md for licensing information.
PERCENT := %

PKG             := cd
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.11
$(PKG)_CHECKSUM := ad984b392eaa32cfaec62eac62a4b1187142d550275d80c0db27dd166367e550
$(PKG)_SUBDIR   := cd
$(PKG)_FILE     := cd-$($(PKG)_VERSION)_Sources.tar.gz
$(PKG)_URL      := https://sourceforge.net/projects/canvasdraw/files/5.11/Docs$(PERCENT)20and$(PERCENT)20Sources/cd-$($(PKG)_VERSION)_Sources.tar.gz/download
$(PKG)_DEPS     := gcc zlib lua libpng ftgl im pdflib_lite

define $(PKG)_UPDATE
    echo 'TODO: write update script for cd.' >&2;
    echo $(cd_VERSION)
endef

define $(PKG)_TEC_UNAME
$(if $(BUILD_STATIC),mingw4@win-suffix@,dllw4@win-suffix@)
endef

define $(PKG)_BUILD_CMD_COMMON
	IM_INC='$(PREFIX)/$(TARGET)/include/im' \
	$(MAKE) -C '$(1)/src' -j1 \
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
    # build and install the library
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lfreetype -lz -lm -lgdi32 -lcomdlg32 -lwinspool' cd
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lpdf -lcd -lfreetype -lz -lm' cdpdf
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lcd -lftgl -lfreetype -lz -lopengl32 -lm' cdgl
	$($(PKG)_BUILD_CMD_COMMON) cdim
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lgdiplus -lgdi32 -lwinspool -lcomdlg32 -lcd -lfreetype -lz -lm' cdcontextplus
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lcd -lfreetype -llua -lz -lm' cdlua5
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lcdpdf -lcdlua$(lua_DLLVER) -llua -lcd -lfreetype -lz -lm' cdluapdf5
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lcdgl -lcdlua$(lua_DLLVER) -llua -lcd -lfreetype -lz -lm' cdluagl5
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lcdcontextplus -lcdlua$(lua_DLLVER) -llua -lcd -lfreetype -lz -lm' cdluacontextplus5
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lcdim -limlua$(lua_DLLVER) -lcdlua$(lua_DLLVER) -llua -lcd -lim -lpng -lfreetype -lz -lm' cdluaim5

	$(INSTALL) -d '$(PREFIX)/$(TARGET)/include/cd'
	$(INSTALL) -d '$(PREFIX)/$(TARGET)/lib'
	$(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/lua/$(lua_SHORTVER)'

	$(INSTALL) -m644 '$(SOURCE_DIR)/include/'*.h '$(PREFIX)/$(TARGET)/include/cd'

	$(foreach library,cd cdpdf cdgl cdim cdcontextplus,
		$(INSTALL) -m644 '$(SOURCE_DIR)/lib/$($(PKG)_TEC_UNAME)/lib$(library).$(LIB_SUFFIX)' \
			'$(PREFIX)/$(TARGET)/lib/'
	)

	$(foreach luamod,cdlua cdluapdf cdluagl cdluacontextplus cdluaim,
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
     echo 'Description: Platform-independent graphics library'; \
     echo 'Libs: -L$${libdir} -lcd';  \
     echo 'Cflags: -I$${includedir}/cd';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'
endef

$(PKG)_BUILD_i686-w64-mingw32 = $(subst @tec-sysname@,Win32,$(subst @win-suffix@,,$($(PKG)_BUILD)))
$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @tec-sysname@,Win64,$(subst @win-suffix@,_64,$($(PKG)_BUILD)))
