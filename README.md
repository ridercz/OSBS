# OpenSCAD Build System

[OpenSCAD](https://www.openscad.org/) is great 3D modelling software, where you write the model in code, instead of graphically designing it. It's strength is in easy parametric modelling. It's weakness is that it lacks the ability to export the parametrically customized models easily in batches. So I designed **OSBS - the OpenSCAD Build System**.

It's basically a fancy name for (not so) simple Windows batch script. (So, sorry Linux or Mac folks, someone else has to rewrite it to Bash or something.) But I'm using it for some time already and I think it's a good idea to publish it.

## Features

* Process running from command line.
* Build one or more output (typically `.stl`) files from one or more `.scad` files.
* Allow to build multiple output files for multi-extruder printers.
* Allow to customize the build with external variable and command sets.

# Getting Started With OSBS

In default configuration, the `build.cmd` file is supposed to be placed in the same folder as your `.scad` files. The output `.stl` files are generated in the `.\STL` subfolder. The output folder name and format is configurable.

## Building Simple Files

To build the `.scad` file using OSBS, include the following string anywhere in the file:

```
/* OSBS:build */
```

If the above string is present, the file is included in build. Otherwise it's ignored.

## Building Multiple Versions Using Variables

In many cases you want to build multiple versions of files. In OpenSCAD, this may be achieved using variables. See for example the following file [`sample-sm.scad`](sample-sm.scad), where text on disc and the disc dimensions are configurable:

```
// The following line is requied for file to be included in OSBS build
/* OSBS:build */

// Set the default values of variables; they may be changed later by OSBS
text = "DEFAULT";
diameter = 50;
thickness = 1;

cylinder(d = diameter, h = thickness);
translate([0, 0, thickness]) 
    linear_extrude(thickness / 2) 
        text(text = text, size = 6, halign = "center", valign = "center");
```

To build multiple versions of files, create file with the same name, but add the `.vars` extensions - ie. [`sample-sm.scad.vars`](sample-sm.scad.vars):

```
# Lines starting with hash are comments and are ignored
small:  text = "SMALL"; diameter = 30;
medium: text = "MEDIUM";
large:  text = "LARGE"; diameter = 75;
```

Each line has the following form:

```
label: commands;
```

* `label` is name of given variant. It may contain any characters that are valid in file name, as it will be part of resulting file name, separated with `-`. So the file `something.scad` with variant `label` would result into file named `something-label.scad`.
* `commands` are any valid OpenSCAD commands, including the terminating `;`. Generally it would be one or more variable assigments (see example above), but it might be anything. Everything after `:` is added at the end of `.scad` file and executed.

## Building Files for Multiple Extruders

OSBS supports building several files for multiple extruders. To use this functionality, include the following string in the `.scad` file:

```
/* OSBS:build:2E */
```

The number (`2` above) specifies number of extruders. Up to 9 extruders is supported. So, for four extruders, use:

```
/* OSBS:build:4E */
```

For `n` extruders, OSBS will compile the file `n+1` times, each time incrementing the `osbs_selected_extruder` variable from `0` to `n`. You may use the variable inside the `.scad` file to render parts of the file.

The following function, defined in [`_OSBSlib.scad`](_OSBSlib.scad) may come handy:

```
function osbs_extruder(extruder_number) = 
    osbs_selected_extruder == undef || osbs_selected_extruder == 0 
    ? true 
    : osbs_selected_extruder == extruder_number;
```

You may use it to conditionally render part of model if given extruder is selected. If the `osbs_selected_extruder` variable is not defined or equals to `0`, everything is rendered.

See the following sample file, [`sample-mm.scad`](sample-mm.scad):

```
// The following line is requied for file to be included in OSBS build
/* OSBS:build:2E */

// Include  OSBS library so we can use the osbs_extruder() function
use <_OSBSlib.scad>;

// Set the default values of variables; they may be changed later by OSBS
text = "DEFAULT";
diameter = 50;
thickness = 1;

if(osbs_extruder(1)) color("RoyalBlue") {
    cylinder(d = diameter, h = thickness);
}

if(osbs_extruder(2)) color("Firebrick") {
    translate([0, 0, thickness]) 
        linear_extrude(thickness / 2) 
            text(text = text, size = 6, halign = "center", valign = "center");
}
```

The `osbs_extruder(n)` function is used to determine parts that will be extruded using different extruder.

OSBS will render the following files:

* `sample-mm.stl` which is the full model.
* `sample-mm-E1.stl` which is the plate, shown in blue in preview, extruded with extruder #1.
* `sample-mm-E2.stl` which is the text, shown in red in preview, extruded with extruder #2.

Of course, you can combine multiple extruders with `.vars` files as mentioned above.

# OSBS Configuration

You may set the following variables at the beginning of the `build.cmd` file:

```
SET OSBS_SCAD="C:\Program Files\OpenSCAD\openscad.com"
```
Path to OpenSCAD executable.

```
SET OSBS_TARGET_FOLDER=.\STL
```
Folder where the generated files are stored. Do not use ending backslash.

```
SET OSBS_TARGET_FORMAT=stl
```
Format of generated files. May be `stl`, `off`, `dxf` or `csg`.