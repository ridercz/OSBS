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