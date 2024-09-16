// pipeFittingDesigner.scad

include <threadlib/THREAD_TABLE.scad>
use <threadlib/threadlib.scad>;

use <adaptersMod/externalToPipe.scad>;
use <adaptersMod/internalToPipe.scad>;
use <pipeFitting.scad>;

// ----------------------------
// -------- Parameters --------
// ----------------------------

// The input diameter for the pipe(s) being coupled
input_dia = 12.00;

// The upper and lower limits for the desired gasket thickness
// Used along with input_dia to determine valid thread types 
gasket_thickness_upper = 15;
gasket_thickness_lower = 13;

gasket_extra_length = 3; // Allows addition of extra length to the gasket to ensure a tight fit

// Tolerance between the input pipe(s) and the main fitting part and nut part
tol_pipe = 0.2;

// Tolerance between the input pipe(s) and the gasket(s)
tol_gasket = 0.1;

turns = 5;

// Wall thickness of the fitting parts
wall_thickness = 1.2;

// Lower part length, length of the center tube is lower_length * 2
middle_length = 20.0;

// Mid part height between the upper part where the thread 
// is and lower part that makes up the center tube
transition_length = 15.0;

// Cap thickness for the fitting nut
cap_thickness = 1.0;
nut_wall_thickness = 2.4;

// Entry chamfer for the fitting mate
entry_chamfer = false;

// The style of the fitting
style = "Hexagon"; // "Hexagon", "Cone", "Circular"

// see the <<<ECHO: "SHOWING[0/X]:">>> for the number of available threads X
// based on your above specifications
selectedThread = 5; 

export = false;       // when true derenders all but the selected 'selectedPart'
selectedPart = "all"; // show the fitting, nut, gasket, or all

showInputPipe = false; // show the input pipe(s) for reference

// ----------------------------
// ------ End Parameters ------
// ----------------------------

// ----------------------------
// ----- Global Variables -----
// ----------------------------

// full circle has 120 fragments
$fn = $preview ? 120 * 1 / 4 : 120 * 1;
// correction factor for circle subtraction to avoid undersized holes
fudge = 1 / cos(180 / $fn);
corrector = 0.15;

lower_length = middle_length / 2;
mid_height = transition_length / 2;

// ----------------------------
// --- End Global Variables ---
// ----------------------------

// ----------------------------
// ----- Design Solutions -----
// ----------------------------

// Designators for external threads within gasket thicknesses ranges
designators = thread_specD("ext", (input_dia + gasket_thickness_lower / 2), (input_dia + gasket_thickness_upper / 2));

if (!export)
{
    translate([ thread_specs(designators[0])[2] * 2, thread_specs(designators[0])[2] * 2, 0 ])
    {
        for (i = [0:len(designators) - 1])
        {
            echo(designators[i]);
            specs = thread_specs(designators[i]);
            pitch = specs[0];
            Dsupport = specs[2];
            DsuppTogg = i % 2 == 0 ? Dsupport : -Dsupport; // Toggle Dsupport
            lower_outer_to_inner_corr = input_dia + wall_thickness * 2 + tol_pipe * 2;
            translate([ input_dia * 3 * i, 0, 0 ])
            {
                Adapter_External_Bare(corrector, // corrector
                                      designators[i], turns, wall_thickness,
                                      entry_chamfer,              // Upper External Thread Part
                                      style, 0, mid_height, 0, 0, // Middle Part
                                      lower_outer_to_inner_corr, wall_thickness, lower_length // Lower Part
                );
                translate([ 0, DsuppTogg, 0 ])
                    text(text = str("[", i, "]: ", designators[i]), size = 5, halign = "center", valign = "center");
            }

            translate([ input_dia * 3 * i, Dsupport * 2, -mid_height / 2 ])
            {
                color(c = "blue", alpha = 0.1) translate([ 0, 0, -input_dia * 5 ])
                    cylinder(h = input_dia * 10, d = input_dia);
                generateGasket(designator = designators[i], mid_height = mid_height, wall_thickness = wall_thickness,
                               fudge = fudge, turns = turns, input_dia = input_dia, fit_excess = gasket_extra_length, tol_gasket = tol_gasket,
                               tol_pipe = tol_pipe);
            }
        }
    }
}

// ----------------------------
// --- End Design Solutions ---
// ----------------------------

// ----------------------------
// ----- Design Selection -----
// ----------------------------

thread_type_select = designators[selectedThread];
echo(str("SHOWING", "[", selectedThread, "/", len(designators), "]", ":"));
echo(thread_type_select);

if (!export || (selectedPart == "fitting" || selectedPart == "all"))
{
    generateFitting(corrector = corrector, thread_type = thread_type_select, input_dia = input_dia, turns = turns,
                    wall_thickness = wall_thickness, tol_pipe = tol_pipe, entry_chamfer = entry_chamfer, style = style,
                    mid_height = mid_height, lower_length = lower_length);
    if (showInputPipe)
    {
        color(c = "blue", alpha = 10) 
            cylinder(h = (middle_length + transition_length * 2 + (turns + 1) * thread_specs(thread_type_select)[0] * 2) + input_dia * 4, d = input_dia, center = true);
    }
}

if (!export || (selectedPart == "nut" || selectedPart == "all"))
{
    translate([ -thread_specs(thread_type_select)[2], -thread_specs(thread_type_select)[2], 0 ])
        generateNut(corrector = corrector, thread_type = thread_type_select, turns = turns,
                    wall_thickness = nut_wall_thickness, entry_chamfer = entry_chamfer, style = style,
                    cap_thickness = cap_thickness, input_dia = input_dia, tol_pipe = tol_pipe, fudge = fudge);
}

if (!export || (selectedPart == "gasket" || selectedPart == "all"))
{
    translate([ thread_specs(thread_type_select)[2], -thread_specs(thread_type_select)[2], 0 ])
        generateGasket(corrector = corrector, designator = thread_type_select, mid_height = mid_height,
                       wall_thickness = wall_thickness, fudge = fudge, turns = turns, input_dia = input_dia, fit_excess = gasket_extra_length,
                       tol_gasket = tol_gasket, tol_pipe = tol_pipe);
}

// ----------------------------
// --- End Design Selection ---
// ----------------------------