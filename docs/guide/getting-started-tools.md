# Getting started — tools

You need a C++ compiler, CMake, Ninja, and **LLVM 18** once. After that, building Li is one command.

## macOS

```bash
brew install llvm@18 cmake ninja
export LLVM_DIR="$(brew --prefix llvm@18)/lib/cmake/llvm"
export CC=clang CXX=clang++
./scripts/build.sh
./build/compiler/lic/lic --version
```

## Linux (Ubuntu)

```bash
sudo apt-get install cmake ninja-build clang-18 llvm-18-dev
export LLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm
export CC=clang-18 CXX=clang++-18
./scripts/build.sh
```

## Windows

Use the GitHub Actions recipe as a reference: LLVM 18 via Chocolatey, then `cmake -B build` with `LLVM_DIR` pointing at the install.

## Your first build

```bash
./build/compiler/lic/lic build examples/hello.li -o hello --release
./hello
```

## Commands you will use

| Command | What it does |
|---------|----------------|
| `lic parse file.li` | Is the syntax OK? |
| `lic check file.li` | Syntax + types (quick, for the editor) |
| `lic build file.li -o app` | Full pipeline → runnable program |
| `lic build file.li -o app --release` | Optimized native binary |
| `lic build file.li -o app --threads=8` | Hint OpenMP to use 8 threads (when parallel code is present) |
| `lic check file.li --strict-contracts` | Same as `lic check`, but **`ensures true` on value-returning `def` is an error (E0303)** instead of warning (W0601) |
| `LI_STRICT_CONTRACTS=1 lic build …` | Same strict rule for **`lic build`** / **`lic verify`** without repeating the flag |

`lic check` is for speed while you type. **`lic build` is the real gate** when you want a program you trust.

## Run the project’s tests

```bash
./scripts/ci.sh
```

That builds Li, runs security checks, and runs the full `li-tests` suite.

Next: [Hello world in depth](hello-world.md).
