use <pipe-fitting-SCAD/pipeFitting.scad>;
use <threadlib/threadlib.scad>;

// ----------------------------
// -------- Parameters --------
// ----------------------------

// The input diameter for the pipe(s) being coupled
input_dia = 12.00;

// The upper and lower limits for the desired gasket thickness
// These are used along with input_dia to determine valid thread types
// upper limit for the gasket thickness
gasket_thickness_upper = 15;

// lower limit for the gasket thickness
gasket_thickness_lower = 13;

// Allows addition of extra length to the gasket to ensure a tight fit
gasket_extra_length = 3;

// Tolerance between the input pipe(s) and the main fitting part and nut part
tol_pipe = 0.2;

// Tolerance between the input pipe(s) and the gasket(s)
tol_gasket = 0.1;

// Number of turns for the thread
turns = 5;

// Wall thickness of the fitting parts
wall_thickness = 1.2;

// Lower part length, length of the center tube is lower_length * 2
middle_length = 20.0;

// Mid part height between the upper part where the thread is and lower part that makes up the center tube
transition_length = 15.0;

// Cap thickness for the fitting nut
cap_thickness = 1.0;

// Wall thickness of the nut
nut_wall_thickness = 2.4;

// Entry chamfer for the fitting mate
entry_chamfer = true; // [true, false]

// The style of the fitting
style = "Hexagon"; // ["Hexagon", "Cone", "Circular"]

// see the <<<ECHO: "SHOWING[0/X]:">>> for the number of available threads X
selectedPart = "all"; // ["fitting", "nut", "gasket", "all"]

// show the pipe that the fitting is designed for
showInputPipe = true; // [true, false]

// show the cross section of the fitting
showXSection = true; // [true, false]

// The thread type to use for the fitting
thread_type_select = "UNC-7/8-ext";

// ----------------------------
// ------ End Parameters ------
// ----------------------------

// ----------------------------
// ----- Global Variables -----
// ----------------------------

// dummy module to stop cuztomizer
module dummy()
{
}

$fn = $preview ? 120 * 1 / 4 : 120 * 1;

// correction factor for circle subtraction to avoid undersized holes
fudge = 1 / cos(180 / $fn);
corrector = 0.15;

lower_length = middle_length / 2;
mid_height = transition_length / 2;

thread_specs = thread_specs(thread_type_select);
thread_pitch = thread_specs[0];
thread_height = (turns + 1) * thread_pitch;

// ----------------------------
// --- End Global Variables ---
// ----------------------------

// ----------------------------
// -----      Design      -----
// ----------------------------

if ((selectedPart == "fitting" || selectedPart == "all"))
{

    color("green") xSection(showXSection)
        generateFitting(corrector = corrector, thread_type = thread_type_select, input_dia = input_dia, turns = turns,
                        wall_thickness = wall_thickness, tol_pipe = tol_pipe, entry_chamfer = entry_chamfer,
                        style = style, mid_height = mid_height, lower_length = lower_length);

    if (showInputPipe)
    {
        color(c = "pink", alpha = 0.25) cylinder(
            h = (middle_length + transition_length * 2 + (turns + 1) * thread_specs(thread_type_select)[0] * 2) +
                input_dia * 4,
            d = input_dia, center = true);
    }
}

if ((selectedPart == "nut" || selectedPart == "all"))
{
    translate([ 0, 0.05, thread_height + cap_thickness / 2 + lower_length + mid_height * 2 ]) rotate([ 0, 180, 0 ])
        color("blue") xSection(showXSection) rotate([ 0, 0, 180 ])
            generateNut(corrector = corrector, thread_type = thread_type_select, turns = turns,
                        wall_thickness = nut_wall_thickness, entry_chamfer = entry_chamfer, style = style,
                        cap_thickness = cap_thickness, input_dia = input_dia, tol_pipe = tol_pipe, fudge = fudge);
}

if ((selectedPart == "gasket" || selectedPart == "all"))
{
    translate([ 0, -0.05, lower_length + mid_height ]) color("orange") xSection(showXSection)
        generateGasket(corrector = corrector, designator = thread_type_select, mid_height = mid_height,
                       wall_thickness = wall_thickness, fudge = fudge, turns = turns, input_dia = input_dia,
                       fit_excess = gasket_extra_length, tol_gasket = tol_gasket, tol_pipe = tol_pipe);
}

module xSection(showXSection)
{
    if (showXSection)
    {
        difference()
        {
            children();

            for (i = [0:1])
                mirror([ i, 1, 0 ]) translate([ 0, 0, -50 ]) cube([ 100, 100, 100 ]);
        }
    }
    else
    {
        children();
    }
}

// ----------------------------
// ---     End Design      ---
// ----------------------------