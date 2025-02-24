# Solaris 11.4 Sysroot Builder

A Bash script to create a Solaris 11.4 sysroot for cross-compiling, with a focus on Rust cross-compilation.

Features

  * Builds a Solaris 11.4 sysroot for cross-compiling.
  * Supports both SPARC and x86 (i386/amd64) architectures.

Sysroot Contents

  *  Essential Solaris system libraries (libc, libm, libsocket, etc.)
  *  Required header files (system/header, system/library, etc.)
  *  GCC runtime and system object files (crt1.o, crti.o, etc.)

Prerequisites

  *  Solaris 11.4 (with Rust installed)
  *  `mf2tar` (https://github.com/illumos/sysroot/tree/master/mf2tar)

Usage

  * Clone and build `mf2tar`

     * `git clone https://github.com/illumos/sysroot.git`
     * `cd sysroot/mf2tar/`
     * `cargo build`
  
  * Build Solaris Sysroot

      * `git clone https://github.com/psumbera/solaris-sysroot.git`
      * `cd solaris-sysroot`
      * `PATH=~/sysroot/mf2tar/target/debug:$PATH ./build-sysroot.sh`

Example Output:

```
e82b78c14464cc2dc71f3cdab312df3dd63441d7c23eeeaf34d41d8b947688d3  solaris-11.4.42.111.0-i386-sysroot-v2025-02-21.tar.bz2
```
