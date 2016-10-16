soptin - Spotlight Opt-In
=========================

What is it?
-----------

Spotlight keeps my laptop hot and drains battery as crazy. I like its search
interface, but I only use it for starting applications, looking up words in
dictionary and doing simple arithmetic.

Spotlight allows one to exclude specific directories from indexing, but what I
need is a tool to only include specific directories, so it will index only
applications and System Preferences' applets, and not spend CPU cycles on the
bulk of the filesystem contents. This tool provides the functionality.

How to use it?
--------------

Every now and then run the following:

    sudo ruby main.rb '/path/*/to/dir/to/index' /another/dir/to/index

One can use `*` and `?` wildcards to match directories.

By default `soptin` indexes the following:
- `/Applications`
- `/Users/*/Applications`
- `/Library/Fonts`
- `/System/Library/Fonts`
- `/Library/PreferencePanes`
