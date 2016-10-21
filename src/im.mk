# This file is part of MXE. See LICENSE.md for licensing information.
PERCENT := %

PKG             := im
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.12
$(PKG)_CHECKSUM := 999ff1a6aa305c4ed5a4ba830266a7aac8737def7f7d4010c398fd4ecddfac9f
$(PKG)_SUBDIR   := im
$(PKG)_FILE     := im-$($(PKG)_VERSION)_Sources.tar.gz
$(PKG)_URL      := https://sourceforge.net/projects/imtoolkit/files/$($(PKG)_VERSION)/Docs$(PERCENT)20and$(PERCENT)20Sources/im-$($(PKG)_VERSION)_Sources.tar.gz
$(PKG)_DEPS     := gcc zlib lua libpng

define $(PKG)_UPDATE
    echo 'TODO: write update script for im.' >&2;
    echo $(im_VERSION)
endef

define $(PKG)_TEC_UNAME
$(if $(BUILD_STATIC),mingw4@win-suffix@,dllw4@win-suffix@)
endef

define $(PKG)_BUILD_CMD_COMMON
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
	  LUA_INC='$(PREFIX)/$(TARGET)/include' \
	  USE_LUA_VERSION=$(lua_DLLVER) \
	  LIBLUA_SFX='' \
	  DLIBEXT=dll \
	  NO_DYNAMIC=$(if $(BUILD_STATIC),Yes,No) \
	  NO_STATIC=$(if $(BUILD_STATIC),No,Yes)
endef

define $(PKG)_BUILD
    # build and install the library
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lz -lgdi32' im
	$($(PKG)_BUILD_CMD_COMMON) im_process
	$($(PKG)_BUILD_CMD_COMMON) im_fftw
	$($(PKG)_BUILD_CMD_COMMON) im_jp2
	$($(PKG)_BUILD_CMD_COMMON) im_lzo
	$($(PKG)_BUILD_CMD_COMMON) im_process_omp
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-llua -lim -lpng -lz -lm' imlua5
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lim_jp2 -limlua$(lua_DLLVER) -lim -llua -lpng -lz -lm' imlua_jp25
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lim_process -limlua$(lua_DLLVER) -lim -llua -lpng -lz -lm' imlua_process5
	$($(PKG)_BUILD_CMD_COMMON) LIBS='-lim_fftw -lim_process -limlua$(lua_DLLVER) -lim -llua -lpng -lz -lm' imlua_fftw5

	$(INSTALL) -d '$(PREFIX)/$(TARGET)/include/im'
	$(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/lua/$(lua_SHORTVER)'
	$(INSTALL) -d '$(PREFIX)/$(TARGET)/lib'

	$(INSTALL) -m644 '$(SOURCE_DIR)/include/'*.h '$(PREFIX)/$(TARGET)/include/im'

	$(foreach library,im im_fftw im_jp2 im_lzo im_process im_process_omp,

	$(INSTALL) -m644 '$(SOURCE_DIR)/lib/$($(PKG)_TEC_UNAME)/lib$(library).$(LIB_SUFFIX)' \
		'$(PREFIX)/$(TARGET)/lib/'
	)


	$(foreach luamod,imlua imlua_fftw imlua_jp2 imlua_process,
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
     echo 'Description: An Imaging Tool'; \
     echo 'Libs: -L$${libdir} -lim';  \
     echo 'Cflags: -I$${includedir}/im';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'
endef

$(PKG)_BUILD_i686-w64-mingw32 = $(subst @tec-sysname@,Win32,$(subst @win-suffix@,,$($(PKG)_BUILD)))
$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @tec-sysname@,Win64,$(subst @win-suffix@,_64,$($(PKG)_BUILD)))
