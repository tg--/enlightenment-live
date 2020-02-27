# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

[ "${PV}" = 9999 ] && inherit git-r3 meson

DESCRIPTION="System and process monitor written with EFL"
HOMEPAGE="https://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/apps/${PN}.git"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/efl"
RDEPEND="|| ( dev-libs/efl[X] dev-libs/efl[wayland] )"
BDEPEND=""

src_compile() {
	meson_src_compile
}

src_test() {
	meson_src_test
}

src_install() {
	meson_src_install
	xdg_icon_cache_update()
}
