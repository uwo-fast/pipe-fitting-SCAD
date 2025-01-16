/*

Author:     Cameron K. Brooks
Version:    0.4
Date:       06.06.2024

Author:     Makrokaba
Version:    0.3
Date:       25.05.2020

Author:     Makrokaba
Version:    0.0-0.2

Universal FEMALE-FEMALE fitting generator
Can be used to join 2 external threaded pieces.
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

// Adapter_Internal_Cap.scad

use <AdapterGenerator.scad>
use <threadlib/threadlib.scad>

echo("threadlib version: ", __THREADLIB_VERSION());

module Adapter_Internal_Cap(corrector, min_wall_size, upper_thread, upper_turns, upper_chamfer, upper_style,
                            upper_diameter, cap_height)
{

    $fn = 120 * 1;
    fudge = 1 / cos(180 / $fn);

    union()
    {
        translate([ 0, 0, cap_height / 2 ]) create_internal_threaded_part(
            upper_part = true, thread = upper_thread, style = upper_style, outer_diameter = upper_diameter,
            chamfer = upper_chamfer, turns = upper_turns, min_wall_size = min_wall_size, corrector = corrector);

        resize([ 0, 0, cap_height + 0.02 ])
            create_cap(corrector, min_wall_size, upper_thread, upper_diameter, upper_style, cap_height);
    }
}

module create_cap(corrector, min_wall_size, upper_thread, upper_diameter, cap_style, cap_height)
{

    fudge = 1 / cos(180 / $fn);

    specs_up = thread_specs(upper_thread);
    Dsupport_up = specs_up[2];
    Rsupport_up = (Dsupport_up / 2 * fudge);

    real_upper_dia =
        (upper_diameter < (Rsupport_up + min_wall_size) * 2) ? (Rsupport_up + min_wall_size) * 2 : upper_diameter;

    min_cap_dia = (Rsupport_up + min_wall_size) * 2;
    real_cap_outer_dia = (upper_diameter < min_cap_dia) ? min_cap_dia : upper_diameter;

    resize([ 0, 0, cap_height ]) translate([ 0, 0, -cap_height / 2 ]) if (cap_style == "Circular")
    {
        difference()
        {
            cylinder(h = cap_height, d = real_cap_outer_dia, center = false);
        }
    }
    else
    {
        difference()
        {
            hexagon(real_cap_outer_dia, cap_height);
        }
    }
}

// Define the test variables
test_corrector = 0.15;
test_min_wall_size = 1.0; // corrector, min_wall_size

// Upper Internal Thread Part
test_thread = "G1/2";
test_upper_thread = str(test_thread, "-int");
test_upper_turns = 5;
test_upper_chamfer = true;
test_upper_style = "Hexagon";
test_upper_diameter = 28;

// Cap Part
test_cap_height = 5.0;

// Call the function with the test variables
Adapter_Internal_Cap(test_corrector, test_min_wall_size, // corrector, min_wall_size
                     test_upper_thread, test_upper_turns, test_upper_chamfer, test_upper_style,
                     test_upper_diameter, // Upper Internal Thread Part
                     test_cap_height      // Cap Part
);