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


use <threads-scad\threads.scad>;

$fn=16;

def_diameter = 10;

module inputPipes(diameter=def_diameter, thickness=undef) {
    z_fite = $preview ? 0.05 : 0;
    thickness = is_undef(thickness) ? diameter / 10 : thickness;    


    union() {
        // First cylinder
        color("LightCoral")
        difference() {
            cylinder(h=diameter*10, r1=diameter/2, r2=diameter/2);

            translate([0,0,-z_fite]) 
            cylinder(h=diameter*10 + z_fite*2, r1=diameter/2 - thickness/2, r2=diameter/2 - thickness/2);
        }

        translate([0,0,-diameter*10])
        // Second cylinder
        color("PowderBlue")
        difference() {
            cylinder(h=diameter*10, r1=diameter/2, r2=diameter/2);

            translate([0,0,-z_fite]) 
            cylinder(h=diameter*10 + z_fite*2, r1=diameter/2 - thickness/2, r2=diameter/2 - thickness/2);
        }
    }
}

inputPipes();



/*

1. **P vs D**: P = 0.54D + 6.51 

2. **L vs D**: L = 1.35D - 23.11

3. **G vs D**: G = 0.24D - 3.69 

4. **B vs D**: B = 0.24D - 0.40

5. **B0 vs D**: B0 = 0.26D - 0.17

-------------------------------

1. **P vs D**: 
P = 0.55D + 6.5

2. **L vs D**: 
L = 1.35D - 23.0

3. **G vs D**: 
G = 0.25D - 3.5

4. **B vs D**: 
B = 0.1D - 0.40

5. **B0 vs D**: 
B0 = 0.25D - 0.15

*/
module mainFitting(
    pipe_dia = def_diameter, 
    pipe_tol = undef,
    gasket_dia1 = undef, 
    gasket_dia2 = undef, 
    gasket_height = undef, 
    thread_length = undef,
    thread_tol = undef, 
    thread_pitch = undef,
    thread_tooth_height = undef,
    pipe_surfaces = 8, 
) {
    z_fite = $preview ? 0.05 : 0;

    pipe_fit_length = 0.25*pipe_dia - 0.15;
    pipe_fit_dia = pipe_dia + pipe_tol;



    thread_length = 0.25*pipe_dia - 0.15;

    gasket_dia1 = undef, 
    gasket_height = thread_length/2;

    fitting_total_length = pipe_fit_length + gasket_height * 2;

    middle_section_distance = fitting_total_length - thread_length * 2;

    middle_section_outer_dia = pipe_fit_dia + gasket_dia1*2;

    fitting_total_outer_dia = middle_section_outer_dia + thread_depth;


    color("DarkSlateGray", alpha=1.0) 
    difference() {
        union() {
            ScrewThread(fitting_total_outer_dia, thread_length, tolerance=thread_tol, tip_height=2, tip_min_fract=3/4);
            cylinder(h=thread_length, r=fitting_total_outer_dia/2-thread_tol);

            translate([0,0,thread_length]) 
            cylinder(middle_section_distance, middle_section_outer_dia/2, middle_section_outer_dia/2, $fn=pipe_surfaces);
            
            translate([0,0,middle_section_distance+thread_length+thread_length]) 
            rotate([180,0,0]) 
            ScrewThread(fitting_total_outer_dia, thread_length, tolerance=thread_tol, tip_height=2, tip_min_fract=3/4);
        }

        translate([0,0,0]) 
        union() {
            translate([0,0,-z_fite]) 
            cylinder(gasket_height+z_fite, (pipe_fit_dia+gasket_dia1 * 2)/2, pipe_fit_dia/2);
            translate([0,0,gasket_height]) 
            cylinder(pipe_fit_length, pipe_fit_dia/2, pipe_fit_dia/2);
            translate([0,0,gasket_height+pipe_fit_length+gasket_height+z_fite]) 
            rotate([180,0,0]) 
            cylinder(gasket_height+z_fite, (pipe_fit_dia+gasket_dia1*2)/2, pipe_fit_dia/2);
        }
    }
}

mainFitting();

module pfNut(
    pipe_dia = def_pipe_dia, 
    pipe_tol = def_pipe_tol,
    nut_end_thickness = def_nut_end_thickness, 
    nut_circle_depression = def_nut_circle_depression, 
    gasket_dia1 = def_gasket_dia1, 
    gasket_height = def_gasket_height, 
    thread_length = def_thread_length,
    thread_tol = def_thread_tol, 
    scale = 1,
) {
    z_fite = $preview ? 0.05 : 0;

    pipe_fit_dia = pipe_dia + pipe_tol;

    middle_section_outer_dia = pipe_fit_dia + gasket_dia1*2;
    fitting_total_outer_dia = middle_section_outer_dia ;

    outer_dia = fitting_total_outer_dia*scale;

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
    pipe_tol = def_pipe_tol,
    gasket_depth = def_gasket_depth,
    gasket_width = def_gasket_width,
    gasket_min_thickness = def_gasket_min_thickness,
    ) {
    z_fite = $preview ? 0.05 : 0;
    
    pipe_fit_dia = pipe_dia + pipe_tol;

    color("DarkGrey", alpha=0.5) 
    difference() {
        cylinder(gasket_depth, (pipe_fit_dia+gasket_min_thickness+gasket_width*2)/2, (pipe_fit_dia+gasket_min_thickness)/2);
        translate([0,0,-z_fite]) 
        cylinder(gasket_depth+z_fite*2, pipe_fit_dia/2, pipe_fit_dia/2);
    }
}