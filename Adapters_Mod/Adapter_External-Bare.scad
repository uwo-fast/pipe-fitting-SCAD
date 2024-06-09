/*

Author: Cameron K. Brooks
Version: 0.4
Date: 06.06.2024

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

use <AdapterGenerator.scad>;
use <threadlib/threadlib.scad>;

echo("threadlib version: ", __THREADLIB_VERSION());

// full circle has 120 fragments
$fn = 120 * 1;
// correction factor for circle subtraction to avoid undersized holes
fudge = 1 / cos(180 / $fn);

// Z-Fite
z_fite = 0.01;

module Adapter_External_Bare(
    corrector, 
    upper_thread, upper_turns, upper_wall, upper_chamfer,
    mid_style, mid_outer_diameter, mid_height, mid_upper_stopper, mid_lower_stopper,
    lower_diameter, lower_wall, lower_length, lower_mid_outer_chamfer=undef) {
        
    specs_up = thread_specs(str(upper_thread, "-ext"));
    Dsupport_up = specs_up[2];
    min_mid_outer_dia = (lower_diameter > Dsupport_up) ? lower_diameter : Dsupport_up;
    real_mid_outer_dia = (mid_outer_diameter < min_mid_outer_dia) ? min_mid_outer_dia : mid_outer_diameter;

    real_lower_mid_outer_chamfer = is_undef(lower_mid_outer_chamfer) ? (real_mid_outer_dia - lower_diameter) / 2 : lower_mid_outer_chamfer;

    union() {
        translate([0, 0, mid_height / 2])
        create_external_threaded_part(
            upper_part = true, 
            thread = upper_thread, 
            turns = upper_turns,
            min_wall_size = upper_wall, 
            chamfer = upper_chamfer, 
            corrector = corrector
        );

        resize([0, 0, mid_height + 0.02]) 
        create_middle(
            upper_thread, upper_wall, 
            mid_style, mid_outer_diameter, mid_height, mid_upper_stopper, mid_lower_stopper,
            lower_diameter, lower_wall, fudge
        );

        difference() {
            if(mid_style == "Circular") {
                translate([0, 0, -lower_length - mid_height / 2]) 
                cylinder(h = lower_length, d = lower_diameter, center = false);

                    translate([0, 0, -real_lower_mid_outer_chamfer - mid_height / 2 ]) 
                    cylinder(h = real_lower_mid_outer_chamfer, r1 = lower_diameter/2, r2 = real_mid_outer_dia/2);
            }
            else if(mid_style == "Cone") {
                    translate([0, 0, -lower_length - mid_height / 2]) 
                cylinder(h = lower_length, d = lower_diameter, center = false);
            }
            else {
                union() {
                    translate([0, 0, -lower_length - mid_height / 2 ]) 
                    hexagon(width = lower_diameter, height = lower_length);
                    
                    translate([0, 0, -real_lower_mid_outer_chamfer - mid_height / 2 ]) 
                    hexagon_doubleR(width1 = lower_diameter, width2 = real_mid_outer_dia, height = real_lower_mid_outer_chamfer);
                }
            }
            translate([0, 0, -lower_length - mid_height / 2 - z_fite]) 
            cylinder(h = mid_height + lower_length + z_fite * 2, r = (lower_diameter / 2 - lower_wall) * fudge, center = false);
        }
    }
}

module create_middle(
    upper_thread, upper_wall, 
    mid_style, mid_outer_diameter, mid_height, mid_upper_stopper, mid_lower_stopper,
    lower_diameter, lower_wall, fudge) {

    specs_up = thread_specs(str(upper_thread, "-ext"));
    Dsupport_up = specs_up[2];

    min_mid_outer_dia = (lower_diameter > Dsupport_up) ? lower_diameter : Dsupport_up;
    real_mid_outer_dia = (mid_outer_diameter < min_mid_outer_dia) ? min_mid_outer_dia : mid_outer_diameter;

    resize([0, 0, mid_height]) 
    translate([0, 0, -mid_height / 2]) 
    if (mid_style == "Circular") {
        difference() {
            cylinder(h = mid_height, d = real_mid_outer_dia, center = false);
            translate([0, 0, -0.001]) 
            cylinder(h = mid_height + 0.002, r1 = (lower_diameter / 2 - lower_wall) * fudge,
                     r2 = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
        }
    }
    else if (mid_style == "Cone") {
        difference() {
            cylinder(h = mid_height, r1 = lower_diameter / 2 + mid_lower_stopper,
                     r2 = Dsupport_up / 2 + mid_upper_stopper, center = false);
            translate([0, 0, -0.001]) 
            cylinder(h = mid_height + 0.002, r1 = (lower_diameter / 2 - lower_wall) * fudge,
                     r2 = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
        }
    }
    else {
        difference() {
            hexagon(real_mid_outer_dia, mid_height);
            translate([0, 0, -0.001]) 
            cylinder(h = mid_height + 0.002, r1 = (lower_diameter / 2 - lower_wall) * fudge,
                     r2 = (Dsupport_up / 2 - upper_wall) * fudge, center = false);
        }
    }
}

// Define the test variables
test_corrector = 0.15; // corrector

// Upper External Thread Part
test_upper_thread = "G1/2";
test_upper_turns = 5;
test_upper_wall = 1.2;
test_upper_chamfer = true;

// Middle Part
test_mid_style = "Circular";
test_mid_outer_diameter = 20.00;
test_mid_height = 5;
test_mid_upper_stopper = 0;
test_mid_lower_stopper = 0;

// Lower Part
test_lower_diameter = 15.00;
test_lower_wall = 1.2;
test_lower_length = 10;
test_lower_mid_outer_chamfer = (test_mid_outer_diameter - test_lower_diameter) / 2;

// Call the function with the test variables
Adapter_External_Bare(
    test_corrector, // corrector
    test_upper_thread, test_upper_turns, test_upper_wall, test_upper_chamfer, // Upper External Thread Part
    test_mid_style, test_mid_outer_diameter, test_mid_height, test_mid_upper_stopper, test_mid_lower_stopper, // Middle Part
    test_lower_diameter, test_lower_wall, test_lower_length, test_lower_mid_outer_chamfer // Lower Part
);



// Compatible Threads:
// [G1/16, G1/8, G1/4, G3/8, G1/2, G5/8, G3/4, G7/8, G1, G1 1/8, G1 1/4, G1 1/2, G1 3/4, G2, G2 1/4, G2 1/2,
// G2 3/4, G3, G3 1/2, G4, G4 1/2, G5, G5 1/2, G6, M0.25x0.075, M0.3x0.08, M0.3x0.09, M0.35x0.09, M0.4x0.1,
// M0.45x0.1, M0.5x0.125, M0.55x0.125, M0.6x0.15, M0.7x0.175, M0.8x0.2, M0.9x0.225, M1, M1x0.2, M1.1x0.25,
// M1.1x0.2, M1.2, M1.2x0.2, M1.4, M1.4x0.2, M1.6, M1.6x0.3, M1.6x0.2, M1.7x0.35, M1.8, M1.8x0.2, M2,
// M2x0.25, M2.2, M2.2x0.25, M2.3x0.45, M2.3x0.4, M2.5, M2.5x0.35, M2.6x0.45, M3, M3x0.35, M3.5, M3.5x0.35,
// M4, M4x0.5, M4.5x0.75, M4.5x0.5, M5, M5x0.5, M5.5x0.5, M6, M6x0.8, M6x0.75, M6x0.7, M6x0.5, M7, M7x0.75,
// M7x0.5, M8, M8x1, M8x0.8, M8x0.75, M8x0.5, M9x1.25, M9x1, M9x0.75, M9x0.5, M10, M10x1.25, M10x1.12,
// M10x1, M10x0.75, M10x0.5, M11x1.5, M11x1, M11x0.75, M11x0.5, M12, M12x1.5, M12x1.25, M12x1, M12x0.75,
// M12x0.5, M14, M14x1.5, M14x1.25, M14x1, M14x0.75, M14x0.5, M15x1.5, M15x1, M16, M16x1.6, M16x1.5,
// M16x1.25, M16x1, M16x0.75, M16x0.5, M17x1.5, M17x1, M18, M18x2, M18x1.5, M18x1.25, M18x1, M18x0.75,
// M18x0.5, M20, M20x2, M20x1.5, M20x1, M20x0.75, M20x0.5, M22x3, M22, M22x2, M22x1.5, M22x1, M22x0.75,
// M22x0.5, M24, M24x2.5, M24x2, M24x1.5, M24x1, M24x0.75, M25x2, M25x1.5, M25x1, M26x1.5, M27, M27x2,
// M27x1.5, M27x1, M27x0.75, M28x2, M28x1.5, M28x1, M30, M30x3, M30x2.5, M30x2, M30x1.5, M30x1, M30x0.75,
// M32x2, M32x1.5, M33, M33x3, M33x2, M33x1.5, M33x1, M33x0.75, M35x1.5, M36, M36x3, M36x2, M36x1.5, M36x1,
// M38x1.5, M39, M39x3, M39x2, M39x1.5, M39x1, M40x3, M40x2.5, M40x2, M40x1.5, M42, M42x4, M42x3, M42x2,
// M42x1.5, M42x1, M45, M45x4, M45x3, M45x2, M45x1.5, M45x1, M48, M48x4, M48x3, M48x2, M48x1.5, M50x4,
// M50x3, M50x2, M50x1.5, M52, M52x4, M52x3, M52x2, M52x1.5, M55x4, M55x3, M55x2, M55x1.5, M56, M56x4,
// M56x3, M56x2, M56x1.5, M56x1, M58x4, M58x3, M58x2, M58x1.5, M60, M60x4, M60x3, M60x2, M60x1.5, M60x1,
// M62x4, M62x3, M62x2, M62x1.5, M63x1.5, M64, M64x5.5, M64x4, M64x3, M64x2, M64x1.5, M64x1, M65x4, M65x3,
// M65x2, M65x1.5, M68x6, M68x4, M68x3, M68x2, M68x1.5, M68x1, M70x6, M70x4, M70x3, M70x2, M70x1.5, M72x6,
// M72x4, M72x3, M72x2, M72x1.5, M72x1, M75x6, M75x4, M75x3, M75x2, M75x1.5, M76x6, M76x4, M76x3, M76x2,
// M76x1.5, M76x1, M78x2, M80x6, M80x4, M80x3, M80x2, M80x1.5, M80x1, M82x2, M85x6, M85x4, M85x3, M85x2,
// M85x1.5, M90x6, M90x4, M90x3, M90x2, M90x1.5, M95x6, M95x4, M95x3, M95x2, M95x1.5, M100x6, M100x4,
// M100x3, M100x2, M100x1.5, M105x6, M105x4, M105x3, M105x2, M105x1.5, M110x6, M110x4, M110x3, M110x2,
// M110x1.5, M115x6, M115x4, M115x3, M115x2, M115x1.5, M120x6, M120x4, M120x3, M120x2, M120x1.5, M125x8,
// M125x6, M125x4, M125x3, M125x2, M125x1.5, M130x8, M130x6, M130x4, M130x3, M130x2, M130x1.5, M135x6,
// M135x4, M135x3, M135x2, M135x1.5, M140x8, M140x6, M140x4, M140x3, M140x2, M140x1.5, M145x6, M145x4,
// M145x3, M145x2, M145x1.5, M150x8, M150x6, M150x4, M150x3, M150x2, M150x1.5, M155x6, M155x4, M155x3,
// M155x2, M160x8, M160x6, M160x4, M160x3, M160x2, M165x6, M165x4, M165x3, M165x2, M170x8, M170x6, M170x4,
// M170x3, M170x2, M175x6, M175x4, M175x3, M175x2, M180x8, M180x6, M180x4, M180x3, M180x2, M185x6, M185x4,
// M185x3, M185x2, M190x8, M190x6, M190x4, M190x3, M190x2, M195x6, M195x4, M195x3, M195x2, M200x8, M200x6,
// M200x4, M200x3, M200x2, M205x6, M205x4, M205x3, M205x2, M210x8, M210x6, M210x4, M210x3, M210x2, M215x6,
// M215x4, M215x3, M220x8, M220x6, M220x4, M220x3, M220x2, M225x6, M225x4, M225x3, M225x2, M230x6, M230x4,
// M230x3, M230x2, M235x6, M235x4, M235x3, M240x8, M240x6, M240x4, M240x3, M240x2, M245x6, M245x4, M245x3,
// M245x2, M250x8, M250x6, M250x4, M250x3, M250x2, M255x6, M255x4, M255x3, M260x8, M260x6, M260x4, M260x3,
// M265x6, M265x4, M265x3, M270x6, M270x4, M270x3, M275x6, M275x4, M275x3, M280x8, M280x6, M280x4, M280x3,
// M285x6, M285x4, M285x3, M290x6, M290x4, M290x3, M295x6, M295x4, M295x3, M300x8, M300x6, M300x4, M300x3,
// M310x6, M310x4, M320x6, M320x4, M330x6, M330x4, M340x6, M340x4, M350x6, M350x4, M360x6, M360x4, M370x6,
// M370x4, M380x6, M380x4, M390x6, M390x4, M400x6, M400x4, M410x6, M420x6, M430x6, M440x6, M450x6, M460x6,
// M470x6, M480x6, M490x6, M500x6, M510x6, M520x6, M530x6, M540x6, M550x6, M560x6, M570x6, M580x6, M590x6,
// M600x6, PCO-1881, UNC-#1, UNC-#2, UNC-#3, UNC-#4, UNC-#5, UNC-#6, UNC-#8, UNC-#10, UNC-#12, UNC-1/4,
// UNC-5/16, UNC-3/8, UNC-7/16, UNC-1/2, UNC-9/16, UNC-5/8, UNC-3/4, UNC-7/8, UNC-1, UNC-1 1/8, UNC-1 1/4,
// UNC-1 3/8, UNC-1 1/2, UNC-1 3/4, UNC-2, UNC-2 1/4, UNC-2 1/2, UNC-2 3/4, UNC-3, UNC-3 1/4, UNC-3 1/2,
// UNC-3 3/4, UNC-4, UNF-#0, UNF-#1, UNF-#2, UNF-#3, UNF-#4, UNF-#5, UNF-#6, UNF-#8, UNF-#10, UNF-#12,
// UNF-1/4, UNF-5/16, UNF-3/8, UNF-7/16, UNF-1/2, UNF-9/16, UNF-5/8, UNF-3/4, UNF-7/8, UNF-1, UNF-1 1/8,
// UNF-1 1/4, UNF-1 3/8, UNF-1 1/2, UNEF-#12, UNEF-1/4, UNEF-5/16, UNEF-3/8, UNEF-7/16, UNEF-1/2, UNEF-9/16,
// UNEF-5/8, UNEF-11/16, UNEF-3/4, UNEF-13/16, UNEF-7/8, UNEF-15/16, UNEF-1, UNEF-1 1/16, UNEF-1 1/8, UNEF-1
// 3/16, UNEF-1 1/4, UNEF-1 5/16, UNEF-1 3/8, UNEF-1 7/16, UNEF-1 1/2, UNEF-1 9/16, UNEF-1 5/8, UNEF-1
// 11/16, 4-UN-2 1/2, 4-UN-2 5/8, 4-UN-2 3/4, 4-UN-2 7/8, 4-UN-3, 4-UN-3 1/8, 4-UN-3 1/4, 4-UN-3 3/8, 4-UN-3
// 1/2, 4-UN-3 5/8, 4-UN-3 3/4, 4-UN-3 7/8, 4-UN-4, 4-UN-4 1/8, 4-UN-4 1/4, 4-UN-4 3/8, 4-UN-4 1/2, 4-UN-4
// 5/8, 4-UN-4 3/4, 4-UN-4 7/8, 4-UN-5, 4-UN-5 1/8, 4-UN-5 1/4, 4-UN-5 3/8, 4-UN-5 1/2, 4-UN-5 5/8, 4-UN-5
// 3/4, 4-UN-5 7/8, 4-UN-6, 6-UN-1 3/8, 6-UN-1 7/16, 6-UN-1 1/2, 6-UN-1 9/16, 6-UN-1 5/8, 6-UN-1 11/16,
// 6-UN-1 3/4, 6-UN-1 13/16, 6-UN-1 7/8, 6-UN-1 15/16, 6-UN-2, 6-UN-2 1/8, 6-UN-2 1/4, 6-UN-2 3/8, 6-UN-2
// 1/2, 6-UN-2 5/8, 6-UN-2 3/4, 6-UN-2 7/8, 6-UN-3, 6-UN-3 1/8, 6-UN-3 1/4, 6-UN-3 3/8, 6-UN-3 1/2, 6-UN-3
// 5/8, 6-UN-3 3/4, 6-UN-3 7/8, 6-UN-4, 6-UN-4 1/8, 6-UN-4 1/4, 6-UN-4 3/8, 6-UN-4 1/2, 6-UN-4 5/8, 6-UN-4
// 3/4, 6-UN-4 7/8, 6-UN-5, 6-UN-5 1/8, 6-UN-5 1/4, 6-UN-5 3/8, 6-UN-5 1/2, 6-UN-5 5/8, 6-UN-5 3/4, 6-UN-5
// 7/8, 6-UN-6, 8-UN-1, 8-UN-1 1/16, 8-UN-1 1/8, 8-UN-1 3/16, 8-UN-1 1/4, 8-UN-1 5/16, 8-UN-1 3/8, 8-UN-1
// 7/16, 8-UN-1 1/2, 8-UN-1 9/16, 8-UN-1 5/8, 8-UN-1 11/16, 8-UN-1 3/4, 8-UN-1 13/16, 8-UN-1 7/8, 8-UN-1
// 15/16, 8-UN-2, 8-UN-2 1/8, 8-UN-2 1/4, 8-UN-2 3/8, 8-UN-2 1/2, 8-UN-2 5/8, 8-UN-2 3/4, 8-UN-2 7/8,
// 8-UN-3, 8-UN-3 1/8, 8-UN-3 1/4, 8-UN-3 3/8, 8-UN-3 1/2, 8-UN-3 5/8, 8-UN-3 3/4, 8-UN-3 7/8, 8-UN-4,
// 8-UN-4 1/8, 8-UN-4 1/4, 8-UN-4 3/8, 8-UN-4 1/2, 8-UN-4 5/8, 8-UN-4 3/4, 8-UN-4 7/8, 8-UN-5, 8-UN-5 1/8,
// 8-UN-5 1/4, 8-UN-5 3/8, 8-UN-5 1/2, 8-UN-5 5/8, 8-UN-5 3/4, 8-UN-5 7/8, 8-UN-6, 12-UN-9/16, 12-UN-5/8,
// 12-UN-11/16, 12-UN-3/4, 12-UN-13/16, 12-UN-7/8, 12-UN-15/16, 12-UN-1, 12-UN-1 1/16, 12-UN-1 1/8, 12-UN-1
// 3/16, 12-UN-1 1/4, 12-UN-1 5/16, 12-UN-1 3/8, 12-UN-1 7/16, 12-UN-1 1/2, 12-UN-1 9/16, 12-UN-1 5/8,
// 12-UN-1 11/16, 12-UN-1 3/4, 12-UN-1 13/16, 12-UN-1 7/8, 12-UN-1 15/16, 12-UN-2, 12-UN-2 1/8, 12-UN-2 1/4,
// 12-UN-2 3/8, 12-UN-2 1/2, 12-UN-2 5/8, 12-UN-2 3/4, 12-UN-2 7/8, 12-UN-3, 12-UN-3 1/8, 12-UN-3 1/4,
// 12-UN-3 3/8, 12-UN-3 1/2, 12-UN-3 5/8, 12-UN-3 3/4, 12-UN-3 7/8, 12-UN-4, 12-UN-4 1/8, 12-UN-4 1/4,
// 12-UN-4 3/8, 12-UN-4 1/2, 12-UN-4 5/8, 12-UN-4 3/4, 12-UN-4 7/8, 12-UN-5, 12-UN-5 1/8, 12-UN-5 1/4,
// 12-UN-5 3/8, 12-UN-5 1/2, 12-UN-5 5/8, 12-UN-5 3/4, 12-UN-5 7/8, 12-UN-6, 16-UN-3/8, 16-UN-7/16,
// 16-UN-1/2, 16-UN-9/16, 16-UN-5/8, 16-UN-11/16, 16-UN-3/4, 16-UN-13/16, 16-UN-7/8, 16-UN-15/16, 16-UN-1,
// 16-UN-1 1/16, 16-UN-1 1/8, 16-UN-1 3/16, 16-UN-1 1/4, 16-UN-1 5/16, 16-UN-1 3/8, 16-UN-1 7/16, 16-UN-1
// 1/2, 16-UN-1 9/16, 16-UN-1 5/8, 16-UN-1 11/16, 16-UN-1 3/4, 16-UN-1 13/16, 16-UN-1 7/8, 16-UN-1 15/16,
// 16-UN-2, 16-UN-2 1/8, 16-UN-2 1/4, 16-UN-2 3/8, 16-UN-2 1/2, 16-UN-2 5/8, 16-UN-2 3/4, 16-UN-2 7/8,
// 16-UN-3, 16-UN-3 1/8, 16-UN-3 1/4, 16-UN-3 3/8, 16-UN-3 1/2, 16-UN-3 5/8, 16-UN-3 3/4, 16-UN-3 7/8,
// 16-UN-4, 16-UN-4 1/8, 16-UN-4 1/4, 16-UN-4 3/8, 16-UN-4 1/2, 16-UN-4 5/8, 16-UN-4 3/4, 16-UN-4 7/8,
// 16-UN-5, 16-UN-5 1/8, 16-UN-5 1/4, 16-UN-5 3/8, 16-UN-5 1/2, 16-UN-5 5/8, 16-UN-5 3/4, 16-UN-5 7/8,
// 16-UN-6, 20-UN-1/4, 20-UN-5/16, 20-UN-3/8, 20-UN-7/16, 20-UN-1/2, 20-UN-9/16, 20-UN-5/8, 20-UN-11/16,
// 20-UN-3/4, 20-UN-13/16, 20-UN-7/8, 20-UN-15/16, 20-UN-1, 20-UN-1 1/16, 20-UN-1 1/8, 20-UN-1 3/16, 20-UN-1
// 1/4, 20-UN-1 5/16, 20-UN-1 3/8, 20-UN-1 7/16, 20-UN-1 1/2, 20-UN-1 9/16, 20-UN-1 5/8, 20-UN-1 11/16,
// 20-UN-1 3/4, 20-UN-1 13/16, 20-UN-1 7/8, 20-UN-1 15/16, 20-UN-2, 20-UN-2 1/8, 20-UN-2 1/4, 20-UN-2 3/8,
// 20-UN-2 1/2, 20-UN-2 5/8, 20-UN-2 3/4, 20-UN-2 7/8, 20-UN-3, 28-UN-#12, 28-UN-1/4, 28-UN-5/16, 28-UN-3/8,
// 28-UN-7/16, 28-UN-1/2, 28-UN-9/16, 28-UN-5/8, 28-UN-11/16, 28-UN-3/4, 28-UN-13/16, 28-UN-7/8,
// 28-UN-15/16, 28-UN-1, 28-UN-1 1/16, 28-UN-1 1/8, 28-UN-1 3/16, 28-UN-1 1/4, 28-UN-1 5/16, 28-UN-1 3/8,
// 28-UN-1 7/16, 28-UN-1 1/2, 32-UN-#6, 32-UN-#8, 32-UN-#10, 32-UN-#12, 32-UN-1/4, 32-UN-5/16, 32-UN-3/8,
// 32-UN-7/16, 32-UN-1/2, 32-UN-9/16, 32-UN-5/8, 32-UN-11/16, 32-UN-3/4, 32-UN-13/16]
