/*

Author:     Cameron K. Brooks
Version:    0.4
Date:       06.06.2024

Author:     Makrokaba
Version:    0.3
Date:       25.05.2020

Author:     Makrokaba
Version:    0.0-0.2

Universal MALE-MALE fitting generator
Can be used to join 2 internal threaded pieces
Supports the following thread specifications:
G(BSP), M(Metric), PCO-1881, UNC, UNF, UNEF, x-UN-x

After installation you can find all supported threads in the file
THREAD_TABLE.scad in the library/threadlib folder

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Adapter_External_Bare.scad

use <AdapterGenerator.scad>;
use <threadlib/threadlib.scad>;

echo("threadlib version: ", __THREADLIB_VERSION());

// full circle has 120 fragments
$fn = 120 * 1;
// correction factor for circle subtraction to avoid undersized holes
fudge = 1 / cos(180 / $fn);

// Z-Fite
z_fite = 0.01;

module Adapter_External_Bare(corrector, upper_thread, upper_turns, upper_wall, upper_chamfer, mid_style,
                             mid_outer_diameter, mid_height, mid_upper_stopper, mid_lower_stopper, lower_diameter,
                             lower_wall, lower_length, lower_mid_outer_chamfer = undef)
{

    specs_up = thread_specs(upper_thread);
    Dsupport_up = specs_up[2];
    min_mid_outer_dia = (lower_diameter > Dsupport_up) ? lower_diameter : Dsupport_up;
    real_mid_outer_dia = (mid_outer_diameter < min_mid_outer_dia) ? min_mid_outer_dia : mid_outer_diameter;

    real_lower_mid_outer_chamfer = is_undef(lower_mid_outer_chamfer) ? mid_height : lower_mid_outer_chamfer;

    translate([ 0, 0, mid_height * 1.5 + lower_length ]) union()
    {
        translate([ 0, 0, mid_height / 2 ])
            create_external_threaded_part(upper_part = true, thread = upper_thread, turns = upper_turns,
                                          min_wall_size = upper_wall, chamfer = upper_chamfer, corrector = corrector);

        resize([ 0, 0, mid_height + 0.02 ])
            create_middle(upper_thread, upper_wall, mid_style, mid_outer_diameter, mid_height, mid_upper_stopper,
                          mid_lower_stopper, lower_diameter, lower_wall, fudge);

        difference()
        {
            {
                if (mid_style == "Circular")
                {
                    translate([ 0, 0, -lower_length - mid_height / 2 - real_lower_mid_outer_chamfer ])
                        cylinder(h = lower_length + real_lower_mid_outer_chamfer, d = lower_diameter, center = false);

                    translate([ 0, 0, -real_lower_mid_outer_chamfer - mid_height / 2 ]) cylinder(
                        h = real_lower_mid_outer_chamfer, r1 = lower_diameter / 2, r2 = real_mid_outer_dia / 2);
                }
                else if (mid_style == "Cone")
                {
                    translate([ 0, 0, -lower_length - mid_height / 2 - real_lower_mid_outer_chamfer ])
                        cylinder(h = lower_length + real_lower_mid_outer_chamfer + mid_height / 2, d = lower_diameter,
                                 center = false);
                }
                else
                {
                    union()
                    {
                        translate([ 0, 0, -lower_length - mid_height / 2 - real_lower_mid_outer_chamfer ])
                            hexagon(width = lower_diameter, height = lower_length + real_lower_mid_outer_chamfer);

                        translate([ 0, 0, -real_lower_mid_outer_chamfer - mid_height / 2 ])
                            hexagon_doubleR(width1 = lower_diameter, width2 = real_mid_outer_dia,
                                            height = real_lower_mid_outer_chamfer);
                    }
                }
            }
            translate([ 0, 0, -lower_length - mid_height - real_lower_mid_outer_chamfer - z_fite ])
                cylinder(h = mid_height + lower_length + real_lower_mid_outer_chamfer + z_fite * 2,
                         r = (lower_diameter / 2 - lower_wall) * fudge, center = false);
        }
    }
}

module create_middle(upper_thread, upper_wall, mid_style, mid_outer_diameter, mid_height, mid_upper_stopper,
                     mid_lower_stopper, lower_diameter, lower_wall, fudge)
{

    specs_up = thread_specs(upper_thread);
    Dsupport_up = specs_up[2];

    min_mid_outer_dia = (lower_diameter > Dsupport_up) ? lower_diameter : Dsupport_up;
    real_mid_outer_dia = (mid_outer_diameter < min_mid_outer_dia) ? min_mid_outer_dia : mid_outer_diameter;

    resize([ 0, 0, mid_height ]) translate([ 0, 0, -mid_height / 2 ])
    {
        if (mid_style == "Circular")
        {
            difference()
            {
                cylinder(h = mid_height, d = real_mid_outer_dia, center = false);
                translate([ 0, 0, -0.001 ]) if (lower_diameter == 0)
                {
                    cylinder(h = mid_height + 0.002, r = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
                }
                else
                {
                    cylinder(h = mid_height + 0.002, r1 = (lower_diameter / 2 - lower_wall) * fudge,
                             r2 = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
                }
            }
        }
        else if (mid_style == "Cone")
        {
            difference()
            {
                cylinder(h = mid_height, r1 = lower_diameter / 2 + mid_lower_stopper,
                         r2 = Dsupport_up / 2 + mid_upper_stopper, center = false);
                translate([ 0, 0, -0.001 ])
                    cylinder(h = mid_height + 0.002, r1 = (lower_diameter / 2 - lower_wall) * fudge,
                             r2 = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
            }
        }
        else
        {
            difference()
            {
                hexagon(real_mid_outer_dia, mid_height);
                translate([ 0, 0, -0.001 ]) if (lower_diameter == 0)
                {
                    cylinder(h = mid_height + 0.002, r = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
                }
                else
                {
                    cylinder(h = mid_height + 0.002, r1 = (lower_diameter / 2 - lower_wall) * fudge,
                             r2 = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
                }
            }
        }
    }
}

// Define the test variables
test_corrector = 0.15; // corrector

// Upper External Thread Part
test_thread = "G1/2";
test_thread_f = "G1/2-ext";
test_upper_thread = str(test_thread, "-ext");
test_upper_turns = 5;
test_upper_wall = 1.2;
test_upper_chamfer = true;

// Middle Part
test_mid_style = "Hexagon";
test_mid_outer_diameter = 20.00;
test_mid_height = 5;
test_mid_upper_stopper = 0;
test_mid_lower_stopper = 0;

// Lower Part
test_lower_diameter = 15.00;
test_lower_wall = 1.2;
test_lower_length = 10;
// test_lower_mid_outer_chamfer = (test_mid_outer_diameter - test_lower_diameter) / 2;

// Call the function with the test variables
Adapter_External_Bare(test_corrector, // corrector
                      test_upper_thread, test_upper_turns, test_upper_wall,
                      test_upper_chamfer, // Upper External Thread Part
                      test_mid_style, test_mid_outer_diameter, test_mid_height, test_mid_upper_stopper,
                      test_mid_lower_stopper, // Middle Part
                      test_lower_diameter, test_lower_wall, test_lower_length
                      // Lower Part
);