// pipeFitting.scad

include <threadlib/THREAD_TABLE.scad>
use <threadlib/threadlib.scad>;

use <adaptersMod/externalToPipe.scad>;
use <adaptersMod/internalToPipe.scad>;

// Function to check if a string ends with a given suffix
function ends_with(str, suffix) = let(str_len = len(str), suffix_len = len(suffix))
                                  // Check each character manually
                                  (str_len >= suffix_len) &&
                                  [for (i = [0:suffix_len - 1]) str[str_len - suffix_len + i] == suffix[i]] ==
                                      [for (i = [0:suffix_len - 1]) true];

// Define the thread_specD function
function thread_specD(type, min_diameter, max_diameter) =
    let(filtered_rows = [for (row = THREAD_TABLE) if (
            (type == "int" && ends_with(row[0], "-int")) ||
            (type == "ext" && ends_with(row[0], "-ext"))) if (row[1][2] >= min_diameter && row[1][2] <= max_diameter)
                row[0]]) filtered_rows;

// Define the function to remove the last X characters
function remove_last_chars(str, num_chars) = substr(str, 0, max(0, len(str) - num_chars));

// Define the function to join a list of strings with a delimiter
function join(l, delimiter = "") = let(s = len(l), d = delimiter,
                                       jb = function(b, e) let(s = e - b, m = floor(b + s / 2)) // join binary
                                                    s > 2
                                                ? str(jb(b, m), jb(m, e))
                                            : s == 2 ? str(l[b], l[b + 1])
                                                     : l[b],
                                       jd = function(b, e) let(s = e - b, m = floor(b + s / 2)) // join delimiter
                                                    s > 2
                                                ? str(jd(b, m), d, jd(m, e))
                                            : s == 2 ? str(l[b], d, l[b + 1])
                                                     : l[b]) s
                                           > 0
                                       ? (d == "" ? jb(0, s) : jd(0, s))
                                       : "";

// Define the function to extract a substring from a string
function substr(s, b, e) = let(e = is_undef(e) || e > len(s) ? len(s) : e)(b == e) ? ""
                                                                                   : join([for (i = [b:1:e - 1]) s[i]]);

// generateGasket module to create a gasket for the pipe fitting
module generateGasket(corrector, designator, mid_height, wall_thickness, fudge, turns, input_dia, fit_excess, tol_gasket, tol_pipe, z_fite = 0.05)
{
    // adapter generation uses external diameter, this maps to the inner diameter
    lower_outer_to_inner_corr = input_dia + wall_thickness * 2 + tol_pipe * 2;

    specs = thread_specs(designator);
    pitch = specs[0];
    Dsupport = specs[2];

    difference()
    {
        union()
        {
            cylinder(h = mid_height, r1 = (lower_outer_to_inner_corr / 2 - wall_thickness) * fudge,
                     r2 = (Dsupport / 2 - wall_thickness) * fudge, center = false);
            translate([ 0, 0, mid_height ])
                cylinder(h = (turns * pitch) + fit_excess, r = (Dsupport / 2 - wall_thickness) * fudge, center = false);
        }
        translate([ 0, 0, -z_fite / 2 ]) cylinder(h = mid_height + (turns * pitch) + fit_excess + z_fite,
                                                  r = (input_dia / 2 + tol_gasket) * fudge, center = false);
    }
}

// generateFitting module to create the pipe fitting
module generateFitting(corrector, thread_type, input_dia, turns, wall_thickness, tol_pipe, entry_chamfer, style,
                       mid_outer_diameter = 0, mid_height, lower_length)
{
    // adapter generation uses external diameter, this maps to the inner diameter
    lower_outer_to_inner_corr = input_dia + wall_thickness * 2 + tol_pipe * 2;

        Adapter_External_Bare( corrector,                                           
                              thread_type, turns, wall_thickness, entry_chamfer,      // Upper External Thread Part
                              style, mid_outer_diameter, mid_height, 0, 0,            // Middle Part
                              lower_outer_to_inner_corr, wall_thickness, lower_length // Lower Part
        );

    rotate([ 0, 180, 0 ]) 
        Adapter_External_Bare(  corrector,                                         
                              thread_type, turns, wall_thickness, entry_chamfer,      // Upper External Thread Part
                              style, mid_outer_diameter, mid_height, 0, 0,            // Middle Part
                              lower_outer_to_inner_corr, wall_thickness, lower_length // Lower Part
        );
}

// generateNut module to create the nut for the pipe fitting
module generateNut(corrector, thread_type, turns, wall_thickness, entry_chamfer, style, cap_diameter = 0,
                   cap_thickness, z_fite=0.05, input_dia, tol_pipe, fudge)
{
    {
        difference()
        {

            Adapter_Internal_Cap(corrector, wall_thickness, // corrector, min_wall_size
                                 str(remove_last_chars(thread_type, 4), "-int"), turns, entry_chamfer, style,
                                 cap_diameter, // Upper Internal Thread Part
                                 cap_thickness // Cap Part
            );
            cylinder(h = cap_thickness + z_fite, r = (input_dia / 2 + tol_pipe) * fudge, $fn = 120, center = true);
        }
    }
}