window-layout
=============

Simple Linux command-line tool to save and load different window configurations.
I switch often from working on my laptop itself and on my laptop plugged into a
docking station on my desk and found it frustrating to re-position most/all of
my windows with each change.


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


Limitations
-----------
Windows are saved by ID. If a program is closed and reopened, it will get a new
ID. Similarly, all windows get a new ID if the system is rebooted. Therefore,
the configuration must be saved every time windows are manually moved into
position.
