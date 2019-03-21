window-layout
=============

Simple Linux command-line tool to save and load different window configurations.
I switch often from working on my laptop itself and on my laptop plugged into a
docking station on my desk and found it frustrating to re-position most/all of
my windows with each change.

Windows are matched using various heuristics, and many windows should be able
to be repositioned even after windows have been closed and reopened or the
system has been rebooted.


Usage
-----

Save a configuration by running:
```
$ window-layout save optional-save-name
```

Load a configuration by running:
```
$ window-layout load optional-save-name
```
