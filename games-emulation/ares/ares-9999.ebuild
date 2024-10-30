EAPI=8

DESCRIPTION="Dependancy for labwc"
HOMEPAGE="https://github.com/ares-emulator/ares"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ares-emulator/ares"
else
	SRC_URI="https://github.com/ares-emulator/ares/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"

RDEPEND="
	"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"
