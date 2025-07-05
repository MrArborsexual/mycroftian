EAPI=8

DESCRIPTION="Dirty-Muse-Writer-v01-Uncensored-Erotica"
HOMEPAGE="https://huggingface.co/mradermacher/Dirty-Muse-Writer-v01-Uncensored-Erotica-NSFW-GGUF"
SRC_URI="https://huggingface.co/mradermacher/Dirty-Muse-Writer-v01-Uncensored-Erotica-NSFW-GGUF/resolve/main/Dirty-Muse-Writer-v01-Uncensored-Erotica-NSFW.Q6_K.gguf -> dirty-muse-q6k.gguf"

LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-ai/koboldcpp"

S="${WORKDIR}"

src_install() {
    insinto /opt/koboldcpp/models
    doins "${DISTDIR}/dirty-muse-q6k.gguf"
}

