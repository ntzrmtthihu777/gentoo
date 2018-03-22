# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnustep-2

MY_P=Silver.theme-${PV}
DESCRIPTION="a GNUstep silver theme"
HOMEPAGE="http://wiki.gnustep.org/index.php/Silver.theme"
SRC_URI="http://download.gna.org/gnustep-nonfsf/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

S=${WORKDIR}/${MY_P}

pkg_postinst() {
	elog "Use gnustep-apps/systempreferences to switch theme"
}
