include <../pipe_fitting.scad>;

pipe_length = 80;
pipe_dia = 25;
pipe_tol = 2;
pipe_thickness = 2;
gasket_depth = 20;
gasket_width = 10;
gasket_min_thickness = 3;
gasket_seat_depth = 19;
gasket_seat_width = 9.5;
thread_length = 40;
thread_depth = 15;
thread_tol = 0.04;
nut_end_thickness = 5;
nut_circle_depression = 5;
nut_spacing = 45;
gasket_spacing = 30;
pipe_surfaces = 8;
scale = 0.7;

// Preview modifiers for decreasing fractal number, enabling counter-zfighting, and removing extensions in preview
$fn = $preview ? 16 : 32;
z_fite = $preview ? 0.05 : 0;
pipe_extensions = $preview ? pipe_length * 2 : 0;

// Calculated variables for the assembly
pipe_fit_length = pipe_length + pipe_tol;
pipe_fit_dia = pipe_dia + pipe_tol;
fitting_total_length = pipe_fit_length + gasket_seat_depth * 2;
middle_section_distance = fitting_total_length - thread_length * 2;
middle_section_outer_dia = pipe_fit_dia + gasket_seat_width*2;
fitting_total_outer_dia = middle_section_outer_dia + thread_depth;

/*
// Assemble components
inputPipe(pipe_length, pipe_dia, pipe_thickness, pipe_extensions, gasket_seat_depth, pipe_tol);

*/
mainFitting(pipe_fit_dia, pipe_fit_length, pipe_tol, gasket_seat_width, gasket_seat_depth, thread_length, thread_tol, pipe_surfaces);

/*
// Nuts and Gaskets Assembly
// Nuts
translate([0,0,middle_section_distance+thread_length+thread_length+nut_spacing]) 
pfNut(pipe_dia, pipe_length, pipe_tol, nut_end_thickness, nut_circle_depression, gasket_seat_width, gasket_seat_depth, thread_length, thread_depth, thread_tol, scale);

translate([0,0,-nut_spacing]) 
rotate([180,0,0]) 
pfNut(pipe_dia, pipe_length, pipe_tol, nut_end_thickness, nut_circle_depression, gasket_seat_width, gasket_seat_depth, thread_length, thread_depth, thread_tol, scale);

// Gaskets
translate([0,0,-gasket_spacing])
pfGasket(pipe_dia, pipe_length, pipe_tol, gasket_depth, gasket_width, gasket_min_thickness);

translate([0,0,gasket_spacing])
translate([0,0,middle_section_distance+thread_length+thread_length]) 
rotate([180,0,0])
pfGasket(pipe_dia, pipe_length, pipe_tol, gasket_depth, gasket_width, gasket_min_thickness);
*/