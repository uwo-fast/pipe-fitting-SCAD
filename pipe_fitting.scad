/*
 * Title: [Pipe Fitting and Gasket Assembly]
 * Author: Cameron K. Brooks
 * Organization: FAST Research Group
 * Date: [2023-12-29]
 * License: GPL 3.0 or later
 *
 * Description:
 * This script models a comprehensive pipe fitting assembly, including gaskets, threaded nuts, and customizable pipe fittings. 
 * The script now includes new modules for detailed modeling of pipe inputs, main fittings, nuts, and gaskets. 
 * It supports advanced customization for each component, allowing for precise specifications in complex engineering designs.
 *
 * Dependencies:
 * Requires 'threads-scad' library by rcolyer, available at https://github.com/rcolyer/threads-scad
 * Typical Windows Library Path: C:\Program Files\OpenSCAD\libraries\threads-scad\threads.scad
 *
 * Usage Notes:
 * Update dimensional variables at the beginning of the script to modify the pipe, gasket, fitting, nuts, and threads. The script caters to a wide range of specifications and is adaptable for various engineering applications.
 *
 * Parameters:
 * - Pipe: length, diameter, thickness, extension, gasket seat depth, tolerance, 
 * - Main Fitting: pipe fitting diameter, length, gasket seat width, depth, thread length, middle section distance, outer diameter, tolerance, surface details
 * - Nuts and Gaskets: outer diameter, fit diameter, tolerance, end thickness, circle depression, spacing, gasket depth, minimum thickness, width
 *
 * Revision History:
 * [2023-11-20 - Initial version]
 * [2023-12-29 - Major revision with addition of new modules and parameters]
 */


use <C:\Program Files\OpenSCAD\libraries\threads-scad\threads.scad>;

def_pipe_length = 80;
def_pipe_dia = 25;
def_pipe_tol = 2;
def_pipe_thickness = 2;
def_gasket_depth = 20;
def_gasket_width = 10;
def_gasket_min_thickness = 3;
def_gasket_seat_depth = 19;
def_gasket_seat_width = 9.5;
def_thread_length = 40;
def_thread_depth = 15;
def_thread_tol = 0.04;
def_nut_end_thickness = 5;
def_nut_circle_depression = 5;
def_nut_spacing = 45;
def_gasket_spacing = 30;
def_pipe_surfaces = 8;


module inputPipe(length, dia, thickness, extension, gasket_seat_depth, tol) {
    z_fite = $preview ? 0.05 : 0;

    translate([0, 0, -extension + tol/2 + gasket_seat_depth])
    union() {
        // First cylinder
        color("PowderBlue", alpha=0.5)
        difference() {

            cylinder(h=extension, r1=dia/2, r2=dia/2);

            translate([0,0,-z_fite]) 
            cylinder(h=length + extension*2 + z_fite*2, r1=dia/2 - thickness/2, r2=dia/2 - thickness/2);
        }

        // Second cylinder
        color("LightCoral")
        difference() {
            translate([0, 0, extension]) 
            cylinder(h=length, r1=dia/2, r2=dia/2);

            translate([0,0,-z_fite]) 
            cylinder(h=length + extension*2 + z_fite*2, r1=dia/2 - thickness/2, r2=dia/2 - thickness/2);
        }

        // Third cylinder
        color("PowderBlue", alpha=0.5)
        difference() {
            translate([0, 0, extension+length]) 
            cylinder(h=extension, r1=dia/2, r2=dia/2);

            translate([0,0,-z_fite]) 
            cylinder(h=length + extension*2 + z_fite*2, r1=dia/2 - thickness/2, r2=dia/2 - thickness/2);
        }
    }
}


module mainFitting(
    pipe_dia = def_pipe_dia, 
    pipe_length = def_pipe_length, 
    pipe_tol = def_pipe_tol,
    gasket_seat_width = def_gasket_seat_width, 
    gasket_seat_depth = def_gasket_seat_depth, 
    thread_length = def_thread_length,
    thread_depth = def_thread_depth, 
    thread_tol = def_thread_tol, 
    pipe_surfaces = def_pipe_surfaces, 
) {
    z_fite = $preview ? 0.05 : 0;

    pipe_fit_length = pipe_length + pipe_tol;
    pipe_fit_dia = pipe_dia + pipe_tol;
    fitting_total_length = pipe_fit_length + gasket_seat_depth * 2;
    middle_section_distance = fitting_total_length - thread_length * 2;
    middle_section_outer_dia = pipe_fit_dia + gasket_seat_width*2;
    fitting_total_outer_dia = middle_section_outer_dia + thread_depth;


    color("DarkSlateGray", alpha=0.5) 
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


module pfNut(
    pipe_dia = def_pipe_dia, 
    pipe_length = def_pipe_length, 
    pipe_tol = def_pipe_tol,
    nut_end_thickness = def_nut_end_thickness, 
    nut_circle_depression = def_nut_circle_depression, 
    gasket_seat_width = def_gasket_seat_width, 
    gasket_seat_depth = def_gasket_seat_depth, 
    thread_length = def_thread_length,
    thread_depth = def_thread_depth, 
    thread_tol = def_thread_tol, 
) {
    z_fite = $preview ? 0.05 : 0;

    pipe_fit_length = pipe_length + pipe_tol;
    pipe_fit_dia = pipe_dia + pipe_tol;

    middle_section_outer_dia = pipe_fit_dia + gasket_seat_width*2;
    fitting_total_outer_dia = middle_section_outer_dia + thread_depth;

    outer_dia = fitting_total_outer_dia;

    color("SteelBlue", alpha=0.5)
    union() {
        difference() {
            MetricNut(outer_dia, tolerance=thread_tol);
            translate([0,0,-z_fite]) 
            cylinder(nut_circle_depression+z_fite,outer_dia/2+nut_circle_depression*2,outer_dia/2+nut_circle_depression*2);
        }
        translate([0,0,NutThickness(outer_dia)]) 
        difference() {
            cylinder(h=nut_end_thickness, r=HexAcrossCorners(outer_dia)/2-0.5*thread_tol, $fn=6);
            translate([0,0,-z_fite]) 
            cylinder(NutThickness(outer_dia)+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
        }
    }
}

module pfGasket(
    pipe_dia = def_pipe_dia, 
    pipe_length = def_pipe_length, 
    pipe_tol = def_pipe_tol,
    gasket_depth = def_gasket_depth,
    gasket_width = def_gasket_width,
    gasket_min_thickness = def_gasket_min_thickness,
    ) {
    z_fite = $preview ? 0.05 : 0;
    
    pipe_fit_length = pipe_length + pipe_tol;
    pipe_fit_dia = pipe_dia + pipe_tol;

    color("DarkGrey", alpha=0.5) 
    difference() {
        cylinder(gasket_depth, (pipe_fit_dia+gasket_min_thickness+gasket_width*2)/2, (pipe_fit_dia+gasket_min_thickness)/2);
        translate([0,0,-z_fite]) 
        cylinder(gasket_depth+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
    }
}