set -ex

if [[ ${hip_compiler_version:-None} != "None" ]]; then
  # Note: as of April 2026, the rocm version is not actually have AMD gpu-specific code, it is 
  # just a CPU variant that can be installed with pytorch * rocm*, see https://github.com/ROCm/TheRock/issues/1490
  # and https://github.com/meta-pytorch/torchcodec/issues/444
   export ENABLE_CUDA=0
   export USE_ROCM=1
   export USE_CUDA=0
   export ROCM_PATH="${BUILD_PREFIX}"
   export ROCM_HOME="${BUILD_PREFIX}"
   export HIP_PATH="${BUILD_PREFIX}"
   export HIP_ROOT_DIR="${BUILD_PREFIX}"
   if [[ -n "${ROCK_THE_CONDA_ROCM_GPU_TARGETS:-}" ]]; then
      export PYTORCH_ROCM_ARCH="${ROCK_THE_CONDA_ROCM_GPU_TARGETS}"
   fi
elif [[ ${cuda_compiler_version} != "None" ]]; then
   export ENABLE_CUDA=1
else
   export ENABLE_CUDA=0
fi

# Workaround for https://github.com/conda-forge/conda-forge.github.io/issues/1880
export PKG_CONFIG=$BUILD_PREFIX/bin/pkgconf

# We explicitly depend on lgpl's variant of ffmpeg in the recipe.yaml to ensure that
# we do not have license violation due to linking a GPL project
export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

export TORCHCODEC_DISABLE_COMPILE_WARNING_AS_ERROR=ON

# Disable homebrew-specific workaround
export TORCHCODEC_DISABLE_HOMEBREW_RPATH=ON

# Use Ninja generator for consistency with Windows
export CMAKE_GENERATOR=Ninja

pip install . --no-deps --no-build-isolation -vv

# Remove spurious files created by gtk post-link activation script,
# that should not be included as part of the installed files
rm -f $PREFIX/lib/gdk-pixbuf-2.0/*/loaders.cache
