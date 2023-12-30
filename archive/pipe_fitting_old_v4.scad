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


use <C:\Program Files\OpenSCAD\libraries\threads-scad\threads.scad>;

module pipeFittingAssembly(
    pipe_length = 80,
    pipe_dia = 25,
    pipe_tol = 2,
    pipe_thickness = 2,
    gasket_depth = 20,
    gasket_width = 10,
    gasket_min_thickness = 3,
    gasket_seat_depth = 19,
    gasket_seat_width = 9.5,
    thread_length = 40,
    thread_depth = 15,
    thread_tol = 0.04,
    nut_end_thickness = 5,
    nut_circle_depression = 5,
    nut_spacing = 25,
    gasket_spacing = 20,
    pipe_surfaces = 8
) {
    // Preview modifiers for decreasing fractal number and enabling zfite in preview
    $fn = $preview ? 16 : 64;
    z_fite = $preview ? 0.05 : 0;

    // Calculated variables for the assembly
    pipe_extensions = pipe_length * 2;
    pipe_fit_length = pipe_length + pipe_tol;
    pipe_fit_dia = pipe_dia + pipe_tol;
    fitting_total_length = pipe_fit_length + gasket_seat_depth * 2;
    middle_section_distance = fitting_total_length - thread_length * 2;
    middle_section_outer_dia = pipe_fit_dia + gasket_seat_width*2;
    fitting_total_outer_dia = middle_section_outer_dia + thread_depth;

    // Assemble components
    inputPipe(pipe_length, pipe_dia, pipe_thickness, pipe_extensions, gasket_seat_depth, pipe_tol, z_fite);
    mainFitting(pipe_fit_dia, pipe_fit_length, gasket_seat_width, gasket_seat_depth, thread_length, middle_section_distance, middle_section_outer_dia, fitting_total_outer_dia, thread_tol, pipe_surfaces, z_fite);
    nutsAndGaskets(fitting_total_outer_dia, pipe_fit_dia, thread_tol, nut_end_thickness, nut_circle_depression, z_fite, nut_spacing, gasket_spacing, middle_section_distance, thread_length, gasket_depth, gasket_min_thickness, gasket_width);
}

module inputPipe(length, dia, thickness, extensions, gasket_seat_depth, tol, z_fite) {
    //color("darkred")
    translate([0, 0, -extensions + tol/2 + gasket_seat_depth])
    difference() {
        color("blue") {cylinder(h=length + extensions*2, r1=dia/2, r2=dia/2)};
        translate([0,0,-z_fite]) cylinder(h=length + extensions*2 + z_fite*2, r1=dia/2 - thickness/2, r2=dia/2 - thickness/2);
    }
}

module mainFitting(pipe_fit_dia, pipe_fit_length, gasket_seat_width, gasket_seat_depth, thread_length, middle_section_distance, middle_section_outer_dia, fitting_total_outer_dia, thread_tol, pipe_surfaces, z_fite) {
    color("darkgrey", alpha=0.5) 
    difference() {
        union() {
            ScrewThread(fitting_total_outer_dia, thread_length, tolerance=thread_tol, tip_height=2, tip_min_fract=3/4);
            translate([0,0,thread_length]) 
            cylinder(middle_section_distance, middle_section_outer_dia/2, middle_section_outer_dia/2, $fn=pipe_surfaces);
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
}

module nutsAndGaskets(outer_dia, fit_dia, tol, end_thickness, circle_depression, z_fite, nut_spacing, gasket_spacing, middle_section_distance, thread_length, gasket_depth, gasket_min_thickness, gasket_width) {
    // Nuts
    translate([0,0,middle_section_distance+thread_length+thread_length+nut_spacing]) 
    generateNut(outer_dia, tol, end_thickness, circle_depression, z_fite);

    translate([0,0,-nut_spacing]) 
    rotate([180,0,0]) 
    generateNut(outer_dia, tol, end_thickness, circle_depression, z_fite);

    // Gaskets
    translate([0,0,-gasket_spacing])
    generateGasket(gasket_depth, fit_dia, gasket_min_thickness, gasket_width, z_fite);

    translate([0,0,gasket_spacing])
    translate([0,0,middle_section_distance+thread_length+thread_length]) 
    rotate([180,0,0])
    generateGasket(gasket_depth, fit_dia, gasket_min_thickness, gasket_width, z_fite);
}

module generateNut(outer_dia, tol, end_thickness, circle_depression, z_fite) {
    color("blue", alpha=0.5)
    union() {
        difference() {
            MetricNut(outer_dia, tolerance=tol);
            translate([0,0,-z_fite]) 
            cylinder(circle_depression+z_fite,outer_dia/2+circle_depression*2,outer_dia/2+circle_depression*2);
        }
        translate([0,0,NutThickness(outer_dia)]) 
        difference() {
            cylinder(h=end_thickness, r=HexAcrossCorners(outer_dia)/2-0.5*tol, $fn=6);
            translate([0,0,-z_fite]) 
            cylinder(NutThickness(outer_dia)+z_fite*2, outer_dia/2, outer_dia/2);
        }
    }
}

module generateGasket(depth, fit_dia, min_thickness, width, z_fite) {
    color("green", alpha=0.5) 
    difference() {
        cylinder(depth, (fit_dia+min_thickness+width*2)/2, (fit_dia+min_thickness)/2);
        translate([0,0,-z_fite]) 
        cylinder(depth+z_fite*2, fit_dia/2, fit_dia/2);
    }
}

// Example usage of the module
pipeFittingAssembly();