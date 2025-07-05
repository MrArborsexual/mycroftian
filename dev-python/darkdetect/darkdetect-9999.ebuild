EAPI=8

PYTHON_COMPAT=( python3_12 )
DISTUTILS_USE_PEP517=setuptools

inherit git-r3 distutils-r1

DESCRIPTION="Detect your OS dark mode setting with Python"
HOMEPAGE="https://github.com/albertosottile/darkdetect"
EGIT_REPO_URI="https://github.com/albertosottile/darkdetect.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="|| ( python_targets_python3_12 )"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
    dev-lang/python
"

BDEPEND="dev-vcs/git"

src_install() {
    distutils-r1_src_install
    [[ -f README.md ]] && dodoc README.md
}
