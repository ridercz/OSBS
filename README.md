# OpenSCAD Build System

[OpenSCAD](https://www.openscad.org/) is great 3D modelling software, where you write the model in code, instead of graphically designing it. It's strength is in easy parametric modelling. It's weakness is that it lacks the ability to export the parametrically customized models easily in batches. So I designed **OSBS - the OpenSCAD Build System**.

It's basically a fancy name for (not so) simple batch/shell script. But I'm using it for some time already and I think it's a good idea to publish it.

Original version was written as CMD for Windows, [Jiří Kubíček](https://github.com/kubicek) has translated the batch to shell script for Linux and Mac users.

## Features

* Process running from command line.
* Build one or more output (typically `.stl`) files from one or more `.scad` files.
* Allow to build multiple output files for multi-extruder printers.
* Allow to customize the build with external variable and command sets.

# Getting Started With OSBS

In default configuration, the `build.cmd` file is supposed to be placed in the same folder as your `.scad` files. The output `.stl` files are generated in the `.\STL` subfolder. The output folder name and format is configurable.

To build the `.scad` file using OSBS, include the following string anywhere in the file:

```
/* OSBS:build */
```

If the above string is present, the file is included in build. Otherwise it's ignored.

**For more documentation, see [wiki](https://github.com/ridercz/OSBS/wiki).**