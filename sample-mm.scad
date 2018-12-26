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