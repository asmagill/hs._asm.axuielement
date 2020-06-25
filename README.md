hs.axuielement
===================

This is being integrated into the core Hammerspoon application. This repository will likely hang around for a while sine it's faster to rebuild this than the entire application when trying out new features -- and there are still a few I hope to bring back now that coroutines are normalized -- but the "official" version will be with the Hammerspoon development branch.

- - -

### Reference Contents

* [hs.axuielement](Reference_Core.md) - Documents the core module and how to query/set accessibility elements for applications
* [hs.axuielement.observer](Reference_Observers.md) - Documents the observer submodule which can generate notifications for changes to accessibility elements within an application
* [hs.axuielement.axtextmarker](Reference_AXTextMarker.md) - Provides basic textmarker support commonly found in WebKit based apps (e.g. Safari) or use the WKWebView class for display (many Apple apps these days)
* [Some examples](examples)
* [TODO](TODO.txt)


- - -

### Installation

A precompiled version of this module can be found in this directory with a name along the lines of `axuielement-v1.x.tar.gz`. This can be installed by downloading the file and then expanding it as follows:

~~~sh
$ cd ~/.hammerspoon # or wherever your Hammerspoon init.lua file is located
$ tar -xzf ~/Downloads/axuielement-v1.x.tar.gz # or wherever your downloads are located
~~~

If you wish to build this module yourself, and have XCode installed on your Mac, clone this repository and then do the following:

~~~sh
$ cd wherever-you-cloned-the-files
$ [HS_APPLICATION=/Applications] [PREFIX=~/.hammerspoon] make install
~~~

If your Hammerspoon application is located in `/Applications`, you can leave out the `HS_APPLICATION` environment variable, and if your Hammerspoon files are located in their default location, you can leave out the `PREFIX` environment variable.  For most people it will be sufficient to just type `make install`.

As always, whichever method you chose, if you are updating from an earlier version it is recommended to fully quit and restart Hammerspoon after installing this module to ensure that the latest version of the module is loaded into memory.

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

