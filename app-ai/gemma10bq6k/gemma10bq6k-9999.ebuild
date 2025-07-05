EAPI=8

DESCRIPTION="Gemma-The-Writer-N-Restless-Quill-10B-Uncensored GGUF Q6_K model for KoboldCpp"
HOMEPAGE="https://huggingface.co/DavidAU/Gemma-The-Writer-N-Restless-Quill-10B-Uncensored-GGUF"
SRC_URI="https://huggingface.co/DavidAU/Gemma-The-Writer-N-Restless-Quill-10B-Uncensored-GGUF/resolve/main/Gemma-The-Writer-N-Restless-Quill-10B-max-cpu-D_AU-Q6_k.gguf -> gemma-writer-10b-q6k.gguf"

LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-ai/koboldcpp"

S="${WORKDIR}"

src_install() {
    insinto /opt/koboldcpp/models
    doins "${DISTDIR}/gemma-writer-10b-q6k.gguf"
}

