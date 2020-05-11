hs._asm.axuielement
===================

*** Version 0.7.6+ is a stripped down version, removing some of the more complex search methods to see what the primary functionality required for inclusion in core and migrating some existing fatures to a more responsive model will require (e.g. `hs.application:getMenuItems`). ***

* The removal of these methods is to help focus on the core requirements that can provide an immediate benefit to [Hammerspoon](https://github.com/Hammerspoon/hammerspoon) and [CommandPost](https://github.com/CommandPost/CommandPost).

* This removal *is* temporary, though when they return, it may be with slightly different syntax -- the focus will be on returning the search and filter functionality while keeping Hamemrspoon/CommandPost responsive, which is currently *not* the case.

* The current examples in this repository are probably broken or at least may differ in some respects -- this will be fixed once more responsive versions of the search methods can be developed

* See [references](#reference-contents) for commands currently supported -- I will endeavor to keep it as current as possible during this transition.

- - -

A precompiled version of this module can be found in this directory with a name along the lines of `axuielement-v0.x.tar.gz`. This can be installed by downloading the file and then expanding it as follows:

~~~sh
$ cd ~/.hammerspoon # or wherever your Hammerspoon init.lua file is located
$ tar -xzf ~/Downloads/axuielement-v0.x.tar.gz # or wherever your downloads are located
~~~

If you wish to build this module yourself, and have XCode installed on your Mac, the best way (you are welcome to clone the entire repository if you like, but no promises on the current state of anything) is to download `init.lua`, `internal.m`, `common.m`, `common.h`, `observer.m`, and `Makefile` (at present, nothing else is required) into a directory named `axuielement` (***make sure the directory containing the downloaded files is named `axuielement` or `make install` will install the files into the wrong path***) and then do the following:

~~~sh
$ cd wherever-you-downloaded-the-files
$ [HS_APPLICATION=/Applications] [PREFIX=~/.hammerspoon] make install
~~~

If you choose to clone the repository, the directory name the code will be in will be named `hs._asm.axuielement`. As noted in issue #14, this will cause the module install path to be incorrect when `make install` is run. If you want to clone the entire repository, currently the easiest fix is to rename the directory and build it like this:

~~~sh
$ git clone https://github.com/asmagill/hs._asm.axuielement.git
$ mv hs._asm.axuielement axuielement
$ cd axuielement
$ [HS_APPLICATION=/Applications] [PREFIX=~/.hammerspoon] make install
~~~

If your Hammerspoon application is located in `/Applications`, you can leave out the `HS_APPLICATION` environment variable, and if your Hammerspoon files are located in their default location, you can leave out the `PREFIX` environment variable.  For most people it will be sufficient to just type `make install`.

As always, whichever method you chose, if you are updating from an earlier version it is recommended to fully quit and restart Hammerspoon after installing this module to ensure that the latest version of the module is loaded into memory.

- - -

### Reference Contents

* [hs._asm.axuielement](Reference_Core.md)
* [hs._asm.axuielement.observer](Reference_Observers.md)
* ~~[Some examples](Queries.md)~~ -- uses temporarily disabled methods
* [TODO](TODO.txt)

- - -

### License

>     The MIT License (MIT)
>
> Copyright (c) 2020 Aaron Magill
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
>

