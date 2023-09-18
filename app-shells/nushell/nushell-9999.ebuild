# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3 flag-o-matic

DESCRIPTION="Nushell"
HOMEPAGE="https://www.nushell.sh/"
EGIT_REPO_URI="https://github.com/nushell/nushell.git"

LICENSE="MIT"
SLOT="0"


DEPEND="
	>=dev-libs/libgit2-0.99:=
	dev-libs/oniguruma:=
	dev-libs/openssl:0=
	net-libs/libssh2:=
	net-libs/nghttp2:=
	net-misc/curl
"

RDEPEND="${DEPEND}"

BDEPEND="
	>=virtual/rust-1.60
	virtual/pkgconfig
"
RESTRICT+=" test"

QA_FLAGS_IGNORED="usr/bin/nu.*"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	cargo_src_configure --frozen
}

src_compile() {
	filter-lto # does not play well with C code in crates

	cargo_src_compile --bins # note: configure --bins would skip tests
}

src_install() {
	cargo_src_install
}
