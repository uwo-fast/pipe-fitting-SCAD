/*
Author: Cameron K. Brooks
Version: 0.4
Date: 06.06.2024

Author:     Makrokaba
Version:    0.3
Date:       25.05.2020

Author:     Makrokaba
Version:    0.0-0.2

Universal fitting adapter generator common library

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

use <threadlib/threadlib.scad>
echo("threadlib version: ", __THREADLIB_VERSION());

// full circle has 120 fragments
$fn = 120 * 1;
// correction factor for circle subtraction to avoid undersized holes
fudge = 1 / cos(180 / $fn);

//
z_fite = 0.02;

module create_nozzle_part(upper_part = true, height = 15, diameter = 10, wall_size = 1, bracket_size = 0.5,
                          num_cylinders = 4, base = true)
{
    union()
    {
        difference()
        {
            n_cylinder = num_cylinders + (base ? 1 : 0);
            union()
            {
                if (upper_part)
                {
                    if (base)
                    {
                        cylinder(h = height / n_cylinder, d = diameter);
                    }
                    for (i = [1:num_cylinders])
                    {
                        translate([ 0, 0, height / n_cylinder * (n_cylinder - i) ])
                            cylinder(h = height / n_cylinder, r1 = diameter / 2 + bracket_size, r2 = diameter / 2);
                    }
                }
                else
                {
                    if (base)
                    {
                        translate([ 0, 0, height / n_cylinder * (n_cylinder - 1) ])
                            cylinder(h = height / n_cylinder, d = diameter);
                    }
                    for (i = [1:num_cylinders])
                    {
                        translate([ 0, 0, height / n_cylinder * (n_cylinder - i) ])
                            cylinder(h = height / n_cylinder, r1 = diameter / 2, r2 = diameter / 2 + bracket_size);
                    }
                }
            }
            translate([ 0, 0, -z_fite / 2 ]) cylinder(h = height + z_fite, r = diameter / 2 - wall_size);
        }
    }
}

module create_external_threaded_part(upper_part = true, thread = "M8", turns = 1, min_wall_size = 1.0, chamfer = true,
                                     corrector = 0.00)
{

    specs = thread_specs(str(thread, "-ext"));
    P = specs[0];
    Rrot = specs[1];
    Dsupport = specs[2];
    section_profile = specs[3];
    H = (turns + 1) * P;
    TH = section_profile[3][0];
    Douter = (Rrot + TH - corrector) * 2;

    // Set chamfer size to thread height if ther is a chamfer to be created
    chamfer_size = chamfer ? TH : 0;

    difference()
    {
        difference()
        {
            // Create core and resized thread
            union()
            {
                cylinder(h = H, r = Dsupport / 2); // core
                translate([ 0, 0, P * 0.5 ]) resize([ Douter, Douter, 0 ]) thread(str(thread, "-ext"), turns = turns);
            }

            // Subtract chamfer
            if (upper_part)
            {
                translate([ 0, 0, H - chamfer_size * 2 + z_fite / 2 ]) difference()
                {
                    cylinder(h = chamfer_size * 3 + z_fite, d = Douter + z_fite, center = false);
                    cylinder(h = chamfer_size * 3 + z_fite, r1 = Dsupport / 2 + chamfer_size,
                             r2 = Dsupport / 2 - chamfer_size * 2, center = false);
                }
            }
            else
            {
                translate([ 0, 0, -z_fite / 2 ]) difference()
                {
                    cylinder(h = chamfer_size * 3 + z_fite, d = Douter + 2, center = false);
                    cylinder(h = chamfer_size * 3 + z_fite, r1 = Dsupport / 2 - chamfer_size * 2,
                             r2 = Dsupport / 2 + chamfer_size, center = false);
                }
            }
        }
        // Subtract inner channel
        translate([ 0, 0, -z_fite / 2 ]) cylinder(h = H + z_fite, r = (Dsupport / 2 - min_wall_size) * fudge);
    }
}

create_external_threaded_part(turns=10);

module create_internal_threaded_part(upper_part = true, thread = "M10", style = "Circular", outer_diameter = 0.0,
                                     chamfer = true, turns = 1, min_wall_size = 1.0, corrector = 0.00)
{

    specs = thread_specs(str(thread, "-int"));
    P = specs[0];
    Rrot = specs[1];
    Dsupport = specs[2];
    section_profile = specs[3];
    H = (turns + 1) * P;
    TH = section_profile[2][0];

    // Support radius
    Rsupport = (Dsupport / 2 * fudge);

    // Correct lower_diameter if it was set too low
    real_dia = (outer_diameter < (Rsupport + min_wall_size) * 2) ? (Rsupport + min_wall_size) * 2 : outer_diameter;

    // Set chamfer size to thread height if ther is a chamfer to be created
    chamfer_size = chamfer ? TH : 0;

    difference()
    {
        difference()
        {
            // Create shape and chamfer
            difference()
            {
                if (style == "Circular")
                {
                    cylinder(h = H, d = real_dia);
                }
                else
                {
                    hexagon(real_dia, H);
                };
                if (upper_part)
                {
                    translate([ 0, 0, H - chamfer_size * 3 + z_fite / 2 ])
                        cylinder(h = chamfer_size * 3 + z_fite, r1 = Rsupport - chamfer_size * 2,
                                 r2 = Rsupport + chamfer_size, center = false);
                }
                else
                {
                    translate([ 0, 0, -z_fite / 2 ])
                        cylinder(h = chamfer_size * 3 - z_fite, r1 = Rsupport + chamfer_size,
                                 r2 = Rsupport - chamfer_size * 2, center = false);
                }
            }

            // Subtract core and and resized thread
            // resize([Rsupport*2, Rsupport*2, 0])
            difference()
            {
                translate([ 0, 0, -z_fite / 2 ]) cylinder(H + z_fite, d = Rsupport * 2);
                translate([ 0, 0, P / 2 ]) resize([ (Rsupport + corrector) * 2, (Rsupport + corrector) * 2, 0 ])
                    thread(str(thread, "-int"), turns = turns);
            }
        }
        // Workaround to remove distortions
        translate([ 0, 0, H - z_fite / 2 ]) cylinder(h = z_fite, r = Rsupport);
        translate([ 0, 0, -z_fite / 2 ]) cylinder(h = z_fite, r = Rsupport);
    }
}

module hexagon(width, height)
{
    fudge = 1 / cos(180 / 6);
    cylinder(h = height, r = width / 2 * fudge, $fn = 6);
}