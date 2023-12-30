/*
 * Title: [Pipe Fitting and Gasket Assembly]
 * Author: Cameron K. Brooks
 * Organization: FAST Research Group
 * Date: [2023-12-29]
 * License: GPL 3.0 or later
 *
 * Description:
 * This script models a pipe fitting assembly complete with gaskets and threaded nuts. It features customizable dimensions for the pipe, gasket, and fitting, as well as thread and nut parameters.
 *
 * Dependencies:
 * Requires 'threads-scad' library by rcolyer, available at https://github.com/rcolyer/threads-scad
 * Typical Windows Library Path: C:\Program Files\OpenSCAD\libraries\threads-scad\threads.scad
 *
 * Usage Notes:
 * Adjust the dimensional variables at the beginning of the script to modify the pipe, gasket, and fitting sizes according to your needs. The script is not yet optimized for edge cases.
 *
 * Parameters:
 * gasket_depth, gasket_width, gasket_min_thickness, gasket_seat_depth, gasket_seat_width, pipe_length, pipe_dia, pipe_tol, thread_length, thread_depth, thread_tol, nut_end_thickness, nut_circle_depression, z_fite
 *
 * Revision History:
 * [2023-11-20 - Initial version]
 * [2023-12-29 - Revision v2]
 */

use <C:\Program Files\OpenSCAD\libraries\threads-scad\threads.scad> 

$fn = $preview ? 16 : 64;

// Gasket dimensions and tolerance
gasket_depth = 20;
gasket_width = 10;
gasket_min_thickness = 3;

// Gasket seat dimensions
gasket_seat_depth = 19;
gasket_seat_width = 9.5;

// Pipe dimensions and tolerance
pipe_length = 80;
pipe_dia = 25;
pipe_tol = 2;
pipe_surfaces = 8; // affects $fn of the outer part if pipe (for wrench)

pipe_thickness = 2; // for input pipe preview only 
pipe_extensions = pipe_length * 2; // for input pipe preview only, adds to both ends

// Calculating pipe fit dimensions
pipe_fit_length = pipe_length + pipe_tol;
pipe_fit_dia = pipe_dia + pipe_tol;

// Thread dimensions
thread_length = 40;
thread_depth = 15;

// Calculating fitting total length
fitting_total_length = pipe_fit_length + gasket_seat_depth * 2;

// Calculating middle section distance
middle_section_distance = fitting_total_length - thread_length * 2;

// Calculating middle section and total outer diameters
middle_section_outer_dia = pipe_fit_dia + gasket_seat_width*2;
fitting_total_outer_dia = middle_section_outer_dia + thread_depth;

// Thread parameters
thread_tol = 0.04;

// Nut parameters
nut_end_thickness=5;
nut_circle_depression=5;

// Variable to prevent z-fighting behaviour (visual preview error hence zero in render)
z_fite = $preview ? 0.05 : 0;

// Input pipe solid
color("darkred")
translate([0, 0, -pipe_extensions+pipe_tol/2+gasket_seat_depth])
difference() {
  cylinder(h=pipe_length+pipe_extensions*2, r1=pipe_dia/2, r2=pipe_dia/2);
  translate([0,0,-z_fite]) cylinder(h=pipe_length+pipe_extensions*2+z_fite*2, r1=pipe_dia/2 - pipe_thickness/2, r2=pipe_dia/2 - pipe_thickness/2);
}


// Main
color("darkgrey", alpha=0.5) 
difference() {
  union() {
   
    // bottom threads
    ScrewThread(fitting_total_outer_dia, thread_length, tolerance=thread_tol, tip_height=2, tip_min_fract=3/4);
    
    //middle section
    translate([0,0,thread_length]) 
    cylinder(middle_section_distance, middle_section_outer_dia/2, middle_section_outer_dia/2, $fn=pipe_surfaces);
    
    //top threads
    translate([0,0,middle_section_distance+thread_length+thread_length]) 
    rotate([180,0,0]) 
    ScrewThread(fitting_total_outer_dia, thread_length, tolerance=thread_tol, tip_height=2, tip_min_fract=3/4);
  }

  translate([0,0,0]) 
  union() {
    translate([0,0,-z_fite]) 
    cylinder(gasket_seat_depth+z_fite, (pipe_fit_dia+gasket_seat_width * 2)/2, pipe_fit_dia/2);

    translate([0,0,gasket_seat_depth]) 
    cylinder(pipe_fit_length, pipe_fit_dia/2, pipe_fit_dia/2);

    translate([0,0,gasket_seat_depth+pipe_fit_length+gasket_seat_depth+z_fite]) 
    rotate([180,0,0]) 
    cylinder(gasket_seat_depth+z_fite, (pipe_fit_dia+gasket_seat_width*2)/2, pipe_fit_dia/2);
  }
}

offset1 = 25;

// Nuts
color("blue", alpha=0.5) 
translate([0,0,middle_section_distance+thread_length+thread_length+offset1]) 
union() {
  difference() {
    MetricNut(fitting_total_outer_dia, tolerance=thread_tol);
    translate([0,0,-z_fite]) 
    cylinder(nut_circle_depression+z_fite,fitting_total_outer_dia/2+nut_circle_depression*2,fitting_total_outer_dia/2+nut_circle_depression*2);
  }
  
  translate([0,0,NutThickness(fitting_total_outer_dia)]) 
  difference() {
    cylinder(h=nut_end_thickness, r=HexAcrossCorners(fitting_total_outer_dia)/2-0.5*thread_tol, $fn=6);
    translate([0,0,-z_fite]) 
    cylinder(NutThickness(fitting_total_outer_dia)+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
  }
}

color("blue", alpha=0.5) 
translate([0,0,-offset1]) 
rotate([180,0,0]) 
union() {
  difference() {
    MetricNut(fitting_total_outer_dia, tolerance=thread_tol);
    translate([0,0,-z_fite]) 
    cylinder(nut_circle_depression+z_fite,fitting_total_outer_dia/2+nut_circle_depression*2,fitting_total_outer_dia/2+nut_circle_depression*2);
  }
  translate([0,0,NutThickness(fitting_total_outer_dia)]) 
  difference() {
    cylinder(h=nut_end_thickness, r=HexAcrossCorners(fitting_total_outer_dia)/2-0.5*thread_tol, $fn=6);
    
    translate([0,0,-z_fite]) 
    cylinder(NutThickness(fitting_total_outer_dia)+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
  }
}


offset2 = 2 * 10 * (gasket_depth-gasket_seat_depth);

// Gaskets
translate([0,0,-offset2])
color("green", alpha=0.5) 
difference() {
  cylinder(gasket_depth, (pipe_fit_dia+gasket_min_thickness+gasket_width*2)/2, (pipe_fit_dia+gasket_min_thickness)/2);
  
  translate([0,0,-z_fite]) 
  cylinder(gasket_depth+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
}

translate([0,0,offset2])
color("green", alpha=0.5) 
translate([0,0,middle_section_distance+thread_length+thread_length]) 
rotate([180,0,0])
difference() {
   cylinder(gasket_depth, (pipe_fit_dia+gasket_min_thickness+gasket_width*2)/2, (pipe_fit_dia+gasket_min_thickness)/2);
  
  translate([0,0,-z_fite]) 
  cylinder(gasket_depth+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
}