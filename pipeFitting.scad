use <Adapters_Mod/Adapter_External-Bare.scad>;
use <Adapters_Mod/Adapter_Internal-Cap.scad>;


// Define the common variables
corrector = 0.15;
turns = 4;
wall_thickness = 1.2;
entry_chamfer = true;
style = "Hexagon";

thread_type = "G3/4";

// Upper External Thread Part
// Middle Part
mid_outer_diameter = 20.00;
mid_height = 5;
// Pipe Part
lower_diameter = 12.00;
lower_length = 10;

// Pipe Cap
// Cap Diameter
cap_diameter = 28;
cap_height = 5.0;



Adapter_External_Bare(
    corrector, // corrector
    thread_type, turns, wall_thickness, entry_chamfer, // Upper External Thread Part
    style, mid_outer_diameter, mid_height, 0, 0, // Middle Part
    lower_diameter, wall_thickness, lower_length // Lower Part
);


translate([0,0,35]) 
rotate([0,180,0])
Adapter_Internal_Cap(
    corrector, wall_thickness, // corrector, min_wall_size
    thread_type, turns, entry_chamfer, style, cap_diameter, // Upper Internal Thread Part
    cap_height // Cap Part
);
