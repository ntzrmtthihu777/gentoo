# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils systemd user

MY_P="c-toxcore-${PV}"
DESCRIPTION="Encrypted P2P, messaging, and audio/video calling platform"
HOMEPAGE="https://tox.chat"
SRC_URI="https://github.com/TokTok/c-toxcore/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0/0.2"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="+av daemon ipv6 log-debug +log-error log-info log-trace log-warn static-libs test"

REQUIRED_USE="?? ( log-debug log-error log-info log-trace log-warn )"

RDEPEND="
	av? ( media-libs/libvpx:=
		media-libs/opus )
	daemon? ( dev-libs/libconfig )
	>=dev-libs/libsodium-0.6.1:=[asm,urandom,-minimal]"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	cmake-utils_src_prepare
	#remove faulty tests
	for testname in bootstrap lan_discovery save_compatibility tcp_relay tox_many_tcp; do
		sed -i -e "/^auto_test(${testname})$/d" CMakeLists.txt || die
	done
}

src_configure() {
	local mycmakeargs=(
		-DAUTOTEST=$(usex test)
		-DBOOTSTRAP_DAEMON=$(usex daemon)
		-DBUILD_MISC_TESTS=$(usex test)
		-DBUILD_TOXAV=$(usex av)
		-DENABLE_SHARED=ON
		-DENABLE_STATIC=$(usex static-libs)
		-DMUST_BUILD_TOXAV=$(usex av))
	if use test; then
		mycmakeargs+=(
			-DBUILD_AV_TEST=$(usex av)
			-DTEST_TIMEOUT_SECONDS=120
			-DUSE_IPV6=$(usex ipv6))
	else
		mycmakeargs+=(
			-DBUILD_AV_TEST=OFF
			-DUSE_IPV6=OFF)
	fi

	if use log-trace; then
		mycmakeargs+=(-DMIN_LOGGER_LEVEL="TRACE")
	elif use log-debug; then
		mycmakeargs+=(-DMIN_LOGGER_LEVEL="DEBUG")
	elif use log-info; then
		mycmakeargs+=(-DMIN_LOGGER_LEVEL="INFO")
	elif use log-warn; then
		mycmakeargs+=(-DMIN_LOGGER_LEVEL="WARNING")
	elif use log-error; then
		mycmakeargs+=(-DMIN_LOGGER_LEVEL="ERROR")
	else
		mycmakeargs+=(-DMIN_LOGGER_LEVEL="")
		einfo "Logging disabled"
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use daemon; then
		newinitd "${FILESDIR}"/initd tox-dht-daemon
		newconfd "${FILESDIR}"/confd tox-dht-daemon
		insinto /etc
		doins "${FILESDIR}"/tox-bootstrapd.conf
		systemd_dounit "${FILESDIR}"/tox-bootstrapd.service
	fi
}

pkg_postinst() {
	if use daemon; then
		enewgroup tox
		enewuser tox -1 -1 -1 tox
		if [[ -f ${EROOT}/var/lib/tox-dht-bootstrap/key ]]; then
			ewarn "Backwards compatability with the bootstrap daemon might have been"
			ewarn "broken a while ago. To resolve this issue, REMOVE the following files:"
			ewarn "    ${EROOT}/var/lib/tox-dht-bootstrap/key"
			ewarn "    ${EROOT}/etc/tox-bootstrapd.conf"
			ewarn "    ${EROOT}/run/tox-dht-bootstrap/tox-dht-bootstrap.pid"
			ewarn "Then just re-emerge net-libs/tox"
		fi
	fi
}
