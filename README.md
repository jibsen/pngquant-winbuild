
pngquant-winbuild
=================

About
-----

This is my setup for building [pngquant][] on Windows. It is just a
couple of makefiles, and pngquant and its dependencies as git
submodules.

[pngquant]: https://github.com/pornel/pngquant


Usage
-----

To initialize the submodules, use

~~~.cmd
git submodule update --init --recursive
~~~

And then build with mingw-w64 (make).
