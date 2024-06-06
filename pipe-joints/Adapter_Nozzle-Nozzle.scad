/*
Author:     Makrokaba
Version:    0.3
Date:       25.05.2020

Universal NOZZLE-NOZZLE fitting generator
Can be used to join a hose with another hose of same or different diameter

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

use <AdapterGenerator.scad>

//full circle has 120 fragments
$fn = 120*1;
//correction factor for circle subtraction to avoid undersized holes
fudge = 1/cos(180/$fn);

/* [Upper Nozzle Part] */
// Height of the nozzle
upper_height = 15; // [0:0.1:100]
// Outer diameter of the nozzle
upper_diameter = 10; // [2:0.1:100]
// Wall Thickness in mm
upper_wall = 1.2; // [0.5:0.1:10]
// Bracket size in mm
upper_bracket = 0.6; // [0:0.1:3]


/* [Middle Part] */
// Style
mid_style = "Circular"; // [Circular, Hexagon]
// Outer diameter or wrench size in mm
mid_outer_diameter = 24; // [2:0.1:100]
// Height
mid_height = 5; // [2:0.1:100]

/* [Lower Nozzle Part] */
// Height of the nozzle
lower_height = 15; // [0:0.1:100]
// Outer diameter of the nozzle
lower_diameter = 20; // [2:0.1:100]
// Wall Thickness
lower_wall = 1.2; // [0.5:0.1:10]
// Bracket size
lower_bracket = 0.6; // [0:0.1:3]


union(){
    //create upper part
    translate([0,0,mid_height/2])
    create_nozzle_part(
        upper_part=true, 
        height=upper_height, 
        diameter=upper_diameter, 
        wall_size=upper_wall, 
        bracket_size=upper_bracket);
    
    //create middle part
    resize([0,0,mid_height+0.02]) 
    create_middle();

    //create lower part
    translate([0,0,-lower_height-mid_height/2])
    create_nozzle_part(
        upper_part=false, 
        height=lower_height, 
        diameter=lower_diameter, 
        wall_size=lower_wall, 
        bracket_size=lower_bracket);
}

module create_middle() {
    r_up_outer = (upper_diameter > mid_outer_diameter) ? upper_diameter/2*fudge : mid_outer_diameter/2;
    r_lo_outer = (lower_diameter > mid_outer_diameter) ? lower_diameter/2*fudge : mid_outer_diameter/2;
    d_mid = (r_up_outer > r_lo_outer) ? r_up_outer*2 : r_lo_outer*2;
    r_up_inner = (upper_diameter/2-upper_wall)*fudge;
    r_lo_inner = (lower_diameter/2-lower_wall)*fudge;

    translate([0,0,-mid_height/2])
    if (mid_style == "Circular")
    {
        difference()
        {
            cylinder(h=mid_height, d=d_mid, center=false);
            cylinder(h=mid_height, r1=r_lo_inner, r2=r_up_inner, center=false);
        }
    }
    else
    {
        difference()
        {
            hexagon(d_mid, mid_height);
            cylinder(h=mid_height, r1=r_lo_inner, r2=r_up_inner, center=false);
        }
    }
}
