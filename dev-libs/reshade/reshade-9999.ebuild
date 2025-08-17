# dev-libs/reshade-9999.ebuild

EAPI=8

inherit git-r3

DESCRIPTION="ReShade effect framework headers (installs all headers for system-wide use)"
HOMEPAGE="https://github.com/crosire/reshade"
EGIT_REPO_URI="https://github.com/crosire/reshade.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""


src_install() {
    cd "${S}/source" || die

    insinto /usr/include/reshade
    find . -type f \( -name '*.h' -o -name '*.hpp' \) -exec doins {} + || die

    einstalldocs
}

