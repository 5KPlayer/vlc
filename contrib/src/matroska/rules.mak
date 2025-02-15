# matroska

MATROSKA_VERSION := 1.4.9
MATROSKA_URL := http://dl.matroska.org/downloads/libmatroska/libmatroska-$(MATROSKA_VERSION).tar.xz

PKGS += matroska

ifeq ($(call need_pkg,"libmatroska"),)
PKGS_FOUND += matroska
endif

DEPS_matroska = ebml $(DEPS_ebml)

$(TARBALLS)/libmatroska-$(MATROSKA_VERSION).tar.xz:
	$(call download_pkg,$(MATROSKA_URL),matroska)

.sum-matroska: libmatroska-$(MATROSKA_VERSION).tar.xz

libmatroska: libmatroska-$(MATROSKA_VERSION).tar.xz .sum-matroska
	$(UNPACK)
	$(APPLY) $(SRC)/matroska/0001-KaxBlock-don-t-reset-potentially-unallocated-memory.patch
	$(APPLY) $(SRC)/matroska/0001-KaxBlock-do-not-attempt-to-use-laced-sizes-that-are-.patch
	$(call pkg_static,"libmatroska.pc.in")
	$(MOVE)

MATROSKA_CXXFLAGS := $(CXXFLAGS) $(PIC) -fvisibility=hidden
ifdef HAVE_IOS
MATROSKA_CXXFLAGS +=  -O2
endif

.matroska: libmatroska toolchain.cmake
	cd $< && $(HOSTVARS_PIC) CXXFLAGS="$(MATROSKA_CXXFLAGS)" $(CMAKE) -DBUILD_SHARED_LIBS=OFF
	cd $< && $(MAKE) install
	touch $@
