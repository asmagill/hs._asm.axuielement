hs.axuielement examples
=======================

These are just a few examples to show some of the features of this module. Eventually I intend to do some writeups for the Hammerspoon wiki going into specific detail about various features, possibilities, and pitfalls. Some of these examples may one day make it there as well and others may be added. For now these are provided solely as examples and probably need some adjusting if you wish to use them in your own setups.

* `axbrowse`
    Uses hs.chooser to provide a browser which allows you to view an element and its attributes. Any attribute whose value is a table or another hs.axuielement can be selected and will change the chooser view to that element and its attributes. Prints the path followed to the console so you can copy it and paste it into your own code if you've found something you'd like to use.
* `axh`
    Prints out a "hierarchial" view of the element and all of its descendants. Warning, this can be very slow and locks up Hammerspoon while it is running. It was written as a quick-and-dirty example and for initial exploration; a more useful version would run in the background (via coroutines) and initiate a callback when it was completed, but I've found I spend more time in axbrowse these days, so... may not happen. Still, sometimes this view is useful, so I include the example anyways.
* `axtypeMarker`
    Will draw red squares around elements of the type specified for a given element (and it's children). Runs mostly in the background (via coroutines) but can take a while if the element specified has a lot of children.
* `dockStuff`
    Some examples of interacting with the Dock. Specifically, gets a list of applications in it (and whether they are running), shows how to detect if you're in Expose or Mission Control, and shows how to select a menu item for a Dock item.

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
