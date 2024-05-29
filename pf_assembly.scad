include <pipe_fitting.scad>;

module pipeFittingAssembly(
    pipe_length = def_pipe_length,
    pipe_dia = def_pipe_dia,
    pipe_tol = def_pipe_tol,
    pipe_thickness = def_pipe_thickness,
    gasket_depth = def_gasket_depth,
    gasket_width = def_gasket_width,
    gasket_min_thickness = def_gasket_min_thickness,
    gasket_seat_depth = def_gasket_seat_depth,
    gasket_seat_width = def_gasket_seat_width,
    thread_length = def_thread_length,
    thread_depth = def_thread_depth,
    thread_tol = def_thread_tol,
    nut_end_thickness = def_nut_end_thickness,
    nut_circle_depression = def_nut_circle_depression,
    nut_spacing = def_nut_spacing,
    gasket_spacing = def_gasket_spacing,
    pipe_surfaces = def_pipe_surfaces
) {
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

    // Assemble components
    inputPipe(pipe_length, pipe_dia, pipe_thickness, pipe_extensions, gasket_seat_depth, pipe_tol);

    mainFitting(pipe_fit_dia, pipe_fit_length, pipe_tol, gasket_seat_width, gasket_seat_depth, thread_length, thread_tol, pipe_surfaces);

   // Nuts and Gaskets Assembly
   // Nuts
    translate([0,0,middle_section_distance+thread_length+thread_length+nut_spacing]) 
    pfNut(pipe_dia, pipe_length, pipe_tol, nut_end_thickness, nut_circle_depression, gasket_seat_width, gasket_seat_depth, thread_length, thread_depth, thread_tol);

    translate([0,0,-nut_spacing]) 
    rotate([180,0,0]) 
    pfNut(pipe_dia, pipe_length, pipe_tol, nut_end_thickness, nut_circle_depression, gasket_seat_width, gasket_seat_depth, thread_length, thread_depth, thread_tol);

    // Gaskets
    translate([0,0,-gasket_spacing])
    pfGasket(pipe_dia, pipe_length, pipe_tol, gasket_depth, gasket_width, gasket_min_thickness);

    translate([0,0,gasket_spacing])
    translate([0,0,middle_section_distance+thread_length+thread_length]) 
    rotate([180,0,0])
    pfGasket(pipe_dia, pipe_length, pipe_tol, gasket_depth, gasket_width, gasket_min_thickness);
}

pipeFittingAssembly();