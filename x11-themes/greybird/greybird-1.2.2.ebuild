# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN=${PN/g/G}

DESCRIPTION="The default theme from Xubuntu"
HOMEPAGE="http://shimmerproject.org/project/greybird/ https://github.com/shimmerproject/Greybird"
SRC_URI="https://github.com/shimmerproject/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC-BY-NC-SA-3.0 || ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 x86"
IUSE="ayatana gnome"

RDEPEND=">=x11-themes/gtk-engines-murrine-0.90"
DEPEND=""

RESTRICT="binchecks strip"
S="${WORKDIR}/${MY_PN}-${PV}"

src_install() {
	dodoc README
	rm -f README LICENSE*

	insinto /usr/share/themes/${MY_PN}_compact/xfwm4
	doins xfwm4_compact/*
	rm -rf xfwm4_compact

	use ayatana || rm -rf unity
	use gnome || rm -rf metacity-1

	insinto /usr/share/themes/${MY_PN}
	doins -r *
}
