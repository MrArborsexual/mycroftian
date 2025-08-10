# games-emulation/duckstation/duckstation-9999.ebuild

# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake git-r3 flag-o-matic

# Option 1: force the build type via cmake.eclass
CMAKE_BUILD_TYPE="Release"

export CXXFLAGS="${CXXFLAGS} -fexceptions -include duckstation_shaderc_wrapper.h -include duckstation_unordered_map.h -std=c++20 -include utility -include u8_typedef.h -include duckstartion_fix_string_view.h -include duckstation_optional.h -include duckstation_status_str.h -include duckstation_extentions.h"

DESCRIPTION="Fast PlayStation 1 emulator"
HOMEPAGE="https://github.com/stenzek/duckstation"
EGIT_REPO_URI="https://github.com/stenzek/duckstation.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="nogui qt5 retroachievements discord gbm egl evdev fbdev gamepad wayland X"

DEPEND="
	dev-libs/libbacktrace
	dev-util/spirv-cross
	media-libs/shaderc
	media-libs/libsoundtouch
	dev-libs/discord-rpc
    media-libs/libsdl3
    media-libs/plutosvg
    qt5? ( dev-qt/qtwidgets:5 )
    gamepad? ( media-libs/libsdl2 )
"
RDEPEND="
    media-libs/libsdl3
    media-libs/plutosvg
    qt5? ( dev-qt/qtwidgets:5 )
    gamepad? ( media-libs/libsdl2 )
"

src_prepare() {
  default
  append-cxxflags -fexceptions
  cmake_src_prepare

  # Create once
  mkdir -p "${S}/CMakeModules" || die

  # 1) Inject our module path once, at top-level, before any subdir CMakeLists use find_package()
  #    (insert right after project(...) to be early but post-project())
  sed -i -E '/^[[:space:]]*project\s*\(/a list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")' \
    "${S}/CMakeLists.txt" || die

  # 2) Ensure vendored plutosvg is not pulled in
  #    Guard sed calls so we don't die if files don't exist in this tree
  if [[ -f "${S}/CMakeLists.txt" ]]; then
    sed -i -E 's|^[[:space:]]*add_subdirectory\s*\([^)]*plutosvg[^)]*\)||' "${S}/CMakeLists.txt" || die
  fi
  if [[ -f "${S}/dep/imgui/CMakeLists.txt" ]]; then
    sed -i -E 's|^[[:space:]]*add_subdirectory\s*\([^)]*plutosvg[^)]*\)||' "${S}/dep/imgui/CMakeLists.txt" || die
  fi

  # 4) Provide Find modules (robust: INTERFACE IMPORTED + shims)
  # plutosvg
  cat > "${S}/CMakeModules/Findplutosvg.cmake" << 'EOF' || die
find_package(PkgConfig QUIET)
pkg_check_modules(PLUTOSVG QUIET plutosvg>=0.0.6)

if(PLUTOSVG_FOUND)
  add_library(plutosvg::plutosvg INTERFACE IMPORTED)
  set_target_properties(plutosvg::plutosvg PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PLUTOSVG_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES      "${PLUTOSVG_LIBRARIES}"
  )
  # Optional shim so un-namespaced "plutosvg" references still work without sed
  if(NOT TARGET plutosvg)
    add_library(plutosvg INTERFACE)
    target_link_libraries(plutosvg INTERFACE plutosvg::plutosvg)
  endif()
  set(plutosvg_FOUND TRUE)
else()
  set(plutosvg_FOUND FALSE)
endif()
EOF

  # WebP (DuckStation expects WebP::libwebp)
  cat > "${S}/CMakeModules/FindWebP.cmake" << 'EOF' || die
find_package(PkgConfig QUIET)
pkg_check_modules(WEBP QUIET libwebp)
if(WEBP_FOUND)
  add_library(WebP::libwebp INTERFACE IMPORTED)
  set_target_properties(WebP::libwebp PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${WEBP_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES      "${WEBP_LIBRARIES}"
  )
  # Also provide the canonical CMake module name in case something asks for WebP::WebP
  if(NOT TARGET WebP::WebP)
    add_library(WebP::WebP INTERFACE IMPORTED)
    set_target_properties(WebP::WebP PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${WEBP_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES      "${WEBP_LIBRARIES}"
    )
  endif()
  set(WebP_FOUND TRUE)
else()
  set(WebP_FOUND FALSE)
endif()
EOF

  # Freetype (CMake usually provides FindFreetype with Freetype::Freetype; this is a fallback)
  cat > "${S}/CMakeModules/FindFreetype.cmake" << 'EOF' || die
find_package(PkgConfig QUIET)
pkg_check_modules(FREETYPE QUIET freetype2)
if(FREETYPE_FOUND)
  add_library(Freetype::Freetype INTERFACE IMPORTED)
  set_target_properties(Freetype::Freetype PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FREETYPE_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES      "${FREETYPE_LIBRARIES}"
  )
  set(Freetype_FOUND TRUE)
else()
  set(Freetype_FOUND FALSE)
endif()
EOF

  # SoundTouch (DuckStation often wants SoundTouch::SoundTouchDLL)
  cat > "${S}/CMakeModules/FindSoundTouch.cmake" << 'EOF' || die
find_package(PkgConfig QUIET)
pkg_check_modules(SOUNDTOUCH QUIET soundtouch>=2.3.3)

if(SOUNDTOUCH_FOUND)
  add_library(SoundTouch::SoundTouchDLL INTERFACE IMPORTED)
  set_target_properties(SoundTouch::SoundTouchDLL PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SOUNDTOUCH_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES      "${SOUNDTOUCH_LIBRARIES}"
  )
  set(SoundTouch_FOUND TRUE)
else()
  set(SoundTouch_FOUND FALSE)
endif()
EOF

  # Shaderc (provide Shaderc::shaderc_shared)
  cat > "${S}/CMakeModules/FindShaderc.cmake" << 'EOF' || die
find_package(PkgConfig QUIET)
pkg_check_modules(SHADERC QUIET shaderc)
if(SHADERC_FOUND)
  add_library(Shaderc::shaderc_shared INTERFACE IMPORTED)
  set_target_properties(Shaderc::shaderc_shared PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SHADERC_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES      "${SHADERC_LIBRARIES}"
  )
  set(Shaderc_FOUND TRUE)
else()
  set(Shaderc_FOUND FALSE)
endif()
EOF

  cat > "${S}/CMakeModules/Findspirv_cross_c_shared.cmake" << 'EOF' || die
find_package(PkgConfig REQUIRED)
pkg_check_modules(SPCRSC REQUIRED spirv-cross-c)  # actual .pc name

if(SPCRSC_FOUND)
  add_library(spirv-cross-c-shared STATIC IMPORTED)
set_target_properties(spirv-cross-c-shared PROPERTIES
  IMPORTED_LOCATION "/usr/lib64/libspirv-cross-c.a"
  INTERFACE_INCLUDE_DIRECTORIES "${SPCRSC_INCLUDE_DIRS}"
)
  set(spirv_cross_c_shared_FOUND TRUE)
else()
  set(spirv_cross_c_shared_FOUND FALSE)
endif()
EOF

  # DiscordRPC (define an imported target; upstream varies)
  cat > "${S}/CMakeModules/FindDiscordRPC.cmake" << 'EOF' || die
find_path(DiscordRPC_INCLUDE_DIR NAMES discord_rpc.h)
find_library(DiscordRPC_LIBRARY NAMES discord-rpc)
if(DiscordRPC_INCLUDE_DIR AND DiscordRPC_LIBRARY)
  add_library(DiscordRPC::discord-rpc INTERFACE IMPORTED)
  set_target_properties(DiscordRPC::discord-rpc PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${DiscordRPC_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${DiscordRPC_LIBRARY}"
  )
  # Optional bare shim
  if(NOT TARGET discord-rpc)
    add_library(discord-rpc INTERFACE)
    target_link_libraries(discord-rpc INTERFACE DiscordRPC::discord-rpc)
  endif()
  set(DiscordRPC_FOUND TRUE)
else()
  set(DiscordRPC_FOUND FALSE)
endif()
EOF

  # IMPORTANT: Remove the previous risky edits (see below). We intentionally do NOT:
  # - Inject find_package() into subdirs
  # - s/plutosvg/ replacements in target_link_libraries
}


src_configure() {
    local cmake_args=(
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        -DCMAKE_CXX_FLAGS="${CXXFLAGS} -fexceptions"
        -DCMAKE_INSTALL_PREFIX=/usr
        -DCMAKE_MODULE_PATH="${S}/CMakeModules"
        -DBUILD_NOGUI_FRONTEND=$(usex nogui)
        -DBUILD_QT_FRONTEND=$(usex qt5)
        -DENABLE_CHEEVOS=$(usex retroachievements)
        -DENABLE_DISCORD_PRESENCE=$(usex discord)
        -DUSE_DRMKMS=$(usex gbm)
        -DUSE_EGL=$(usex egl)
        -DUSE_EVDEV=$(usex evdev)
        -DUSE_FBDEV=$(usex fbdev)
        -DUSE_SDL2=$(usex gamepad)
        -DUSE_WAYLAND=$(usex wayland)
        -DUSE_X11=$(usex X)
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_CXX_STANDARD=17
    )

    append-cxxflags -fexceptions  # Still good for other consumers

    cmake_src_configure "${cmake_args[@]}"
}

# Let cmake.eclass handle src_compile and src_install
