# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3 flag-o-matic

DESCRIPTION="Starship"
HOMEPAGE="https://www.starship.rs"
EGIT_REPO_URI="https://github.com/starship/starship.git"

LICENSE="ISC"
SLOT="0"


BDEPEND=">=dev-lang/rust-1.64"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure () {
	cargo_src_configure --frozen
}

src_compile() {
	filter-lto # does not play well with C code in crates

	cargo_src_compile --bins # note: configure --bins would skip tests
}

src_install() {
	cargo_src_install
}
