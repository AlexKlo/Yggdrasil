# Note: this script will require BinaryBuilder.jl v0.3.0 or greater
using BinaryBuilder, Pkg

name = "Jinja2CppWrapper"
version = v"1.3.2"
# Collection of sources required to build ITKWrapper
sources = [
    DirectorySource("./src"),
]

# Once this Pkg issue is resolved, this must be removed
uuid = Base.UUID("a83860b7-747b-57cf-bf1f-3e79990d037f")
delete!(Pkg.Types.get_last_stdlibs(v"1.6.3"), uuid)
# needed for libjulia_platforms and julia_versions
include("../../L/libjulia/common.jl")

# Bash recipe for building across all platforms
script = raw"""
mkdir -p build/
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=$prefix \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DJulia_PREFIX=${prefix} \
    ..

cmake --build build --parallel ${nproc}
cmake --install build
install_license /usr/share/licenses/MIT
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = vcat(libjulia_platforms.(julia_versions)...)
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libjinja2cpp_wrapper", :libjinja2cpp_wrapper),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="Jinja2Cpp_jll", uuid="72923777-883d-5a9e-8d94-bec813f4d578")),
    Dependency(PackageSpec(name="libcxxwrap_julia_jll", uuid="3eaa8342-bff7-56a5-9981-c04077f7cee7"); compat = "0.13.4"),
    BuildDependency(PackageSpec(name="libjulia_jll", uuid="5ad3ddd2-0711-543a-b040-befd59781bbf")),
    Dependency("CompilerSupportLibraries_jll"; platforms=filter(p -> Sys.islinux(p) || Sys.isfreebsd(p) || Sys.iswindows(p), platforms)),
]

# Build the tarballs
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version=v"10")
