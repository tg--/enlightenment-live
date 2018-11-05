# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P=${P/_/-}

if [[ "${PV}" == "9999" ]] ; then
	EGIT_SUB_PROJECT="core"
	EGIT_URI_APPEND="${PN}"
elif [[ *"${PV}" == *"_pre"* ]] ; then
	MY_P=${P%%_*}
	SRC_URI="https://download.enlightenment.org/pre-releases/${MY_P}.tar.xz"
	EKEY_STATE="snap"
else
	SRC_URI="https://download.enlightenment.org/rel/libs/${PN}/${MY_P}.tar.xz"
	EKEY_STATE="release"
fi

inherit gnome2-utils pax-utils xdg-utils

HOMEPAGE="https://www.enlightenment.org/"
DESCRIPTION="Enlightenment Foundation Libraries all-in-one package"
SLOT="0"
LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB"
IUSE="avahi +bmp dds connman debug doc drm +eet egl examples fbcon +fontconfig fribidi gif gles glib gnutls gstreamer +harfbuzz hyphen +ico ibus ivi jpeg2k libressl libuv luajit neon nls opengl ssl pdf physics pixman postscript +ppm +psd pulseaudio raw scim sdl sound +svg systemd tga tiff tslib v4l valgrind vlc vnc wayland +webp X xcf xim xine xpresent xpm"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc64 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"

REQUIRED_USE="
	pulseaudio?	( sound )
	opengl?		( || ( X sdl wayland ) )
	gles?		( || ( X wayland ) )
	gles?		( !sdl )
	gles?		( egl )
	sdl?		( opengl )
	vnc?        ( X fbcon )
	wayland?	( egl !opengl gles )
	xim?		( X )
"

RDEPEND="
	drm? (
		>=dev-libs/libinput-0.8
		media-libs/mesa[gbm]
		>=x11-libs/libdrm-2.4
		>=x11-libs/libxkbcommon-0.3.0
	)
	fontconfig? ( media-libs/fontconfig )
	fribidi? ( dev-libs/fribidi )
	gif? ( media-libs/giflib )
	glib? ( dev-libs/glib:2 )
	gnutls? ( net-libs/gnutls )
	!gnutls? (
		ssl? (
			!libressl? ( dev-libs/openssl:0= )
			libressl? ( dev-libs/libressl )
		)
	)
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	harfbuzz? ( media-libs/harfbuzz )
	ibus? ( app-i18n/ibus )
	jpeg2k? ( media-libs/openjpeg:0 )
	luajit? ( dev-lang/luajit:= )
	!luajit? ( dev-lang/lua:* )
	physics? ( >=sci-physics/bullet-2.80 )
	pixman? ( x11-libs/pixman )
	postscript? ( app-text/libspectre:* )
	pulseaudio? ( media-sound/pulseaudio )
	raw? ( media-libs/libraw:* )
	scim? ( app-i18n/scim )
	sdl? (
		media-libs/libsdl2
		virtual/opengl
	)
	sound? ( media-libs/libsndfile )
	systemd? ( sys-apps/systemd )
	tiff? ( media-libs/tiff:0= )
	tslib? ( x11-libs/tslib )
	valgrind? ( dev-util/valgrind )
	vlc? ( media-video/vlc )
	vnc? ( net-libs/libvncserver )
	wayland? (
		>=dev-libs/wayland-1.8.0
		>=x11-libs/libxkbcommon-0.3.1
		media-libs/mesa[gles2,wayland]
	)
	webp? ( media-libs/libwebp )
	X? (
		x11-libs/libXcursor
		x11-libs/libX11
		x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXtst
		x11-libs/libXScrnSaver

		opengl? (
			x11-libs/libXrender
			virtual/opengl
		)

		gles? (
			x11-libs/libXrender
			virtual/opengl
		)
	)
	xine? ( >=media-libs/xine-lib-1.1.1 )
	xpm? ( x11-libs/libXpm )

	svg? ( gnome-base/librsvg )
	sys-apps/dbus
	>=sys-apps/util-linux-2.20.0
	sys-libs/zlib
	app-arch/lz4:0=
	virtual/jpeg:0=

	!dev-libs/ecore
	!dev-libs/edbus
	!dev-libs/eet
	!dev-libs/eeze
	!dev-libs/efreet
	!dev-libs/eina
	!dev-libs/eio
	!dev-libs/embryo
	!dev-libs/eobj
	!dev-libs/ephysics
	!media-libs/edje
	!media-libs/emotion
	!media-libs/ethumb
	!media-libs/evas
"
#external lz4 support currently broken because of unstable ABI/API
#	app-arch/lz4

#soft blockers added above for binpkg users
#hard blocks are needed for building
CORE_EFL_CONFLICTS="
	!!dev-libs/ecore
	!!dev-libs/edbus
	!!dev-libs/eet
	!!dev-libs/eeze
	!!dev-libs/efreet
	!!dev-libs/eina
	!!dev-libs/eio
	!!dev-libs/embryo
	!!dev-libs/eobj
	!!dev-libs/ephysics
	!!media-libs/edje
	!!media-libs/emotion
	!!media-libs/ethumb
	!!media-libs/evas
"

DEPEND="
	${CORE_EFL_CONFLICTS}

	${RDEPEND}
	doc? ( app-doc/doxygen )
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	default

	# Remove sleep command that forces user to read warnings about their configuration.
	# Back out gnu make hack that causes regen of Makefiles.
	# Delete var setting that causes the build to abort.
	sed -i \
	        -e '/sleep 10/d' \
	        -e '/^#### Work around bug in automake check macro$/,/^#### Info$/d' \
	        -e '/BARF_OK=/s:=.*:=:' \
	        configure || die "Sedding configure file failed in src_prepare."

	# Upstream still doesnt offer a configure flag. #611108
	if ! use unwind ; then
	        sed -i -e 's:libunwind libunwind-generic:xxxxxxxxxxxxxxxx:' \
	        configure || die "Sedding configure file with unwind fix failed."
	fi

	xdg_environment_reset
}

src_configure() {
	if use ssl && use gnutls ; then
		einfo "You enabled both USE=ssl and USE=gnutls, but only one can be used;"
		einfo "gnutls has been selected for you."
	fi
	if use opengl && use gles ; then
		einfo "You enabled both USE=opengl and USE=gles, but only one can be used;"
		einfo "opengl has been selected for you."
	fi

	local myconf=(
		--with-profile=$(usex debug debug release)
		--with-crypto=$(usex gnutls gnutls $(usex ssl openssl none))
		--with-x11=$(usex X xlib none)
		$(use_with X x)
		--with-opengl=$(usex opengl full $(usex gles es none))
		--with-glib=$(usex glib)
		--enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-abb

		$(use_enable bmp image-loader-bmp)
		$(use_enable bmp image-loader-wbmp)
		$(use_enable drm)
		$(use_enable doc)
		$(use_enable eet image-loader-eet)
		$(use_enable egl)
		$(use_enable fbcon fb)
		$(use_enable fontconfig)
		$(use_enable fribidi)
		$(use_enable gif image-loader-gif)
		$(use_enable gstreamer gstreamer1)
		$(use_enable harfbuzz)
		$(use_enable ico image-loader-ico)
		$(use_enable ibus)
		$(use_enable jpeg2k image-loader-jp2k)
		$(use_enable neon)
		$(use_enable nls)
		$(use_enable luajit lua-old)
		$(use_enable physics)
		$(use_enable pixman)
		$(use_enable pixman pixman-font)
		$(use_enable pixman pixman-rect)
		$(use_enable pixman pixman-line)
		$(use_enable pixman pixman-poly)
		$(use_enable pixman pixman-image)
		$(use_enable pixman pixman-image-scale-sample)
		$(use_enable png image-loader-png)
		$(use_enable ppm image-loader-pmaps)
		$(use_enable postscript spectre)
		$(use_enable psd image-loader-psd)
		$(use_enable pulseaudio)
		$(use_enable raw libraw)
		$(use_enable scim)
		$(use_enable sdl)
		$(use_enable sound audio)
		$(use_enable systemd)
		$(use_enable tiff image-loader-tiff)
		$(use_enable !fbcon tslib)
		#$(use_enable udisk udisk-mount)
		$(use_enable v4l v4l2)
		$(use_enable valgrind)
		$(use_enable wayland)
		$(use_enable webp image-loader-webp)
		$(use_enable xim)
		$(use_enable xine)
		$(use_enable xpm image-loader-xpm)
		--enable-cserve
		--enable-image-loader-generic
		--enable-image-loader-jpeg
		$(use_enable svg librsvg)

		#--disable-eeze-mount
		--disable-tizen
		--enable-gesture
		--disable-gstreamer
		--enable-xinput2
		--enable-xinput22
		--enable-elput
		--enable-multisense
		--enable-libmount
		--enable-liblz4
	)

	# Checking for with version of vlc is enabled and therefore use the right configure option
	if use vlc ; then
		einfo "You enabled USE=vlc. Checking vlc version..."
		if has_version ">media-video/vlc-3.0" ; then
			einfo "> 3.0 found. Enabling libvlc."
			myconf+=($(use_enable vlc libvlc))
		else
			einfo "< 3.0 found. Enabling generic-vlc."
			myconf+=($(use_with vlc generic-vlc))
		fi
	fi

	econf "${myconf[@]}"
}

src_compile() {
	if host-is-pax && use luajit ; then
		# We need to build the lua code first so we can pax-mark it. #547076
		local target='_e_built_sources_target_gogogo_'
		printf '%s: $(BUILT_SOURCES)\n' "${target}" >> src/Makefile || die
		emake -C src "${target}"
		emake -C src bin/elua/elua
		pax-mark m src/bin/elua/.libs/elua
	fi

	V=1 emake || die "Compiling EFL failed."

	if use doc ; then
	        V=1 emake -j1 doc || die "Compiling docs for EFL failed."
	fi
}

src_install() {
	MAKEOPTS+=" -j1"

	if use doc ; then
	        local HTML_DOCS=( doc/. )
	fi

	einstalldocs

	V=1 emake install DESTDIR="${D}" || die "Installing EFL files failed."

	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	    gnome2_icon_cache_update
	    xdg_mimeinfo_database_update
}

pkg_postrm() {
	    gnome2_icon_cache_update
	    xdg_mimeinfo_database_update
}