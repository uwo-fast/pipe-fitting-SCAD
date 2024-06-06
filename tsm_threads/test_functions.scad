include <thread_generators.scad>
include <utils.scad>

// Uncomment the following functions to test:
print_test();       // Generate some objects to test against things I have
// print_acme();       // Print some leadscrew flanges
// print_npt();        // Generate some objects with North-American Pipe Threads
// visual_test();      // Look for any glaring errors and compare to other people's STL's

/**
 * Generates ACME leadscrew flanges for testing.
 */
module print_acme() {
    // Tested on ground metal 3/8-10 ACME rod
    // Flange for 3/8"-10 ACME
    // Flange dimensions: https://www.helixlinear.com/Product/PowerAC-38-2-RA-wBronze-Nut/
    translate([40, 0]) imperial() difference() {
        taper(d = 3 / 8, h = 0.41 + 0.62, off = 1 / 16, in = true)
            flange(B = 0.62, C = 0.85, G = 0.41, H = 1.606 + $OD_COMP, F = 1.25, F2 = .266, off = 1 / 16, open = true);

        comp_thread(DMAJ = 3 / 8, L = 2, PITCH = 1 / 10, A = 29, H1 = 0.5 / 2, H2 = 0.5 / 2, in = true);
    }

    // Tested on ground metal TR11x2 rod.
    // TR11x2 flange: https://www.omc-stepperonline.com/download/23LS22-2004E-300T.pdf
    difference() {
        intersection() {
            flange(B = 17, G = 8, F = 23, F2 = 5, C = 15 + $OD_COMP, H = 30 + $OD_COMP, holes = [0, 180], off = 1, open = 1);
            taper(d = 11, h = 25, off = 1, in = true) translate([30 - 25 - $OD_COMP, 0, 0] / 2)
                cube([25, 40, 50], center = true);
        }

        // Compensated thread, otherwise leadscrews need to be oversized a significant amount
        comp_thread(11, 30, 2, 30, 0.5 / 2, 0.5 / 2, in = true);
    }
}

/**
 * Generates various NPT (National Pipe Thread) profiles for testing.
 */
module print_npt() {
    // Reference: https://mdmetric.com/tech/thddat19.htm
    imperial() {
        // 1/2" NPT. Tested.
        difference() {
            union() {
                translate([0, 0, 15 / 64]) thread_npt(DMAJ = 0.840 + $OD_COMP, PITCH = 0.07143, L = 0.07143 * 8);
                cylinder(d = flat(), h = 1 / 4, $fn = 6);
            }
            translate([0, 0, 1 / 4 - 1 / 64]) cylinder(d = 5 / 8, h = 2);
        }

        // 3/8" compression fitting thread. Tested.
        translate([0, 2.5]) {
            translate([0, 0, 1 / 4 - 1 / 16]) difference() {
                tsmthread(DMAJ = 9 / 16 + $OD_COMP, PITCH = 1 / 18, L = 9 / 18);
                cylinder(d = 3 / 8 + $ID_COMP, h = 1);
            }
            cylinder(d = (5 / 8) * flat(), h = 1 / 4, $fn = 6);
        }

        // Nut for 1 1/2" NPT fitting. Tested.
        difference() {
            cylinder(d = flat() * (2 + 1 / 16), h = 1 / 4, $fn = 6);
            translate([0, 0, -1 / 64]) thread_npt(DMAJ = 1.900 + $ID_COMP, PITCH = 1 / 11.5, L = 8 / 11.5);
        }

        // 1 1/4" NPT pipe. Tested.
        translate([0, 2.5]) difference() {
            union() {
                cylinder(d = flat() * (1 + 3 / 4), h = 1 / 4, $fn = 6);
                translate([0, 0, 15 / 64]) thread_npt(DMAJ = 1.660 + $OD_COMP, PITCH = 1 / 11.5, L = 8 / 11.5);
            }
            translate([0, 0, -1 / 4]) cylinder(d = 1 + 3 / 8 + $ID_COMP, h = 2);
        }

        // NPT 1 1/2 external - 1 1/4 internal adapter. Tested.
        translate([0, -2.5]) difference() {
            union() {
                cylinder(d = flat() * (2 + 1 / 16), h = 1 / 4, $fn = 6);
                translate([0, 0, 15 / 64]) thread_npt(DMAJ = 1.900 + $OD_COMP, PITCH = 1 / 11.5, L = 8 / 11.5);
            }
            translate([0, 0, -1 / 64]) thread_npt(DMAJ = 1.660 + $ID_COMP, PITCH = 1 / 11.5, L = 8 / 11.5);
            translate([0, 0, 7.5 / 11.5]) cylinder(d = 1.660 - (1 / 16) * (8 / 11.5), h = 1);
        }
    }
}

/**
 * Generates a variety of thread profiles for testing.
 */
module print_test() {
    // tsmthread obeys $fs, $fn, $fa
    $fs = 1;
    $fa = 1.5;

    // 1/2" NPT
    imperial() difference() {
        union() {
            translate([0, 0, 15 / 64]) thread_npt(DMAJ = 0.840 + $OD_COMP, PITCH = 0.07143, L = 0.07143 * 8);
            cylinder(d = flat() * 1, h = 1 / 4, $fn = 6);
        }
        cylinder(d = 5 / 8, h = 2, center = true);
    }

    // Coax F-connector, 3/8"-32. Tested.
    translate([-15, 15]) imperial() difference() {
        translate([0, 0, 1 / 16]) tsmthread(DMAJ = 3 / 8 + $OD_COMP, L = 3 / 8, PITCH = 1 / 32);
        cylinder(d = (3 / 16) + $ID_COMP, h = 2, center = true);
        cylinder(d = (1 / 2) * flat() + $OD_COMP, h = (1 / 8), $fn = 6);
    }

    // Garden hose, 1 1/16-11.5, 1/4" hex. Tested.
    translate([0, 30]) imperial() difference() {
        taper(d = 1 + 1 / 16, h = 3 / 8, off = 1 / 8)
            tsmthread((1 + 1 / 16) + $OD_COMP, 3 / 8, 1 / 11.5, PR = THREAD_NH);
        // 1/4" hex key
        cylinder(d = flat() * (1 / 4) + $ID_COMP, h = 2, $fn = 6, center = true);
    }

    // 1/4" camera screw. Tested.
    translate([15, 15]) imperial() {
        translate([0, 0, 1 / 8]) tsmthread(1 / 4 + $OD_COMP, 1 / 4, 1 / 20, STUB = 20 * (1 / 4), STUB_OFF = 1);
        difference() {
            // Pretty, oh, so pretty
            taper(d = (1 / 2) * flat(), h = 1 / 8, off = (1 / 2) * (3 / 16))
                cylinder(d = flat() * (1 / 2) + $OD_COMP, $fn = 6, h = 1 / 8);
            // Cut slot for screwdriver
            cube([(1 / 16), 1, 2 / 16], center = true);
        }
    }
}

/**
 * Visual tests for thread profiles.
 */
module visual_test() {
    $fs = 1;
    $fa = 1.5;

    // Visual test 1, compare thread profiles to cross-section of thread
    translate([10, 0]) 
        for (X = [["ACME", [0, 0], THREAD_ACME, 2], ["UTS", [8, 0], THREAD_UTS, 1], ["BUTT", [8, -5], THREAD_BUTT, 1]])
            translate(X[1]) show_profile(X[2], X[0]);

    translate([10, -5]) show_profile(V = prof_npt(10), TAPER = 10, title = "NPT");

    // Visual test 2, demonstration of NPT profile angles
    translate([-10, -25]) scale([5, 5, 1]) color("lightblue") npt_profile_test();

    // Visual test 3, meshing with ACME thread of Thingiverse object
    translate([0, 8]) {
        // https://www.thingiverse.com/thing:1954719/files
        /**
         * 3D-printed thread design which has a nominal DMAJ of 8mm
         * but is actually 9mm when you measure the STL file.
         */
        color("lightgreen") projection(cut = true) rotate([90, 0]) import("nut_8mm4start2mm.stl");

        /**
         * An 8mm thread fitting in that object. It "fits right", but
         * notice how only the tips are touching.
         */
        color("green") difference() {
            projection(cut = true) rotate([90, 0]) translate([0, 0, 2 + 0.25])
                tsmthread(DMAJ = 8, L = 5, PITCH = 2, PR = THREAD_TRAP, STARTS = 4);
            translate([-1.5, -3.5]) text("8mm", 1);
            translate([-3, -5]) text("UNCOMP", 1);
        }

        /**
         * Pitch-compensated 9mm.
         * A perfect match for the "8mm" thread!
         */
        color("cyan") difference() {
            projection(cut = true) rotate([90, 0]) translate([0, 0, 10 + 0.40])
                comp_thread(DMAJ = 9 + $OD_COMP, L = 5, PITCH = 2, STARTS = 4, A = 30, H1 = 0.25, H2 = 0.25);
            translate([-1.5, -11.5]) text("9mm", 1);
            translate([-2, -13]) text("COMP", 1);
        }
    }

    // Visual test 4: UTS metric threads, 20mm.
    // https://www.thingiverse.com/thing:25705
    translate([-30, 8]) {
        color("lightblue") projection(cut = true) rotate([90, 0]) import("Teil_1.stl");
        projection(cut = true) rotate([90, 0]) translate([0, 0, -2.5]) rotate([0, 0, -80])
            tsmthread(20, 20, 2.5, STARTS = 1);
    }

    // Visual test 5: Torture test using all features at once.
    // If I break anything, it usually shows up here.
    // translate([10,25])
    // tsmthread(DMAJ=18, L=20, PITCH=6, STARTS=6, PR=THREAD_BALL, TAPER=-30);
}

/**
 * Displays a thread profile for visual inspection.
 * 
 * @param V - Thread profile vector.
 * @param title - Title of the profile.
 * @param l - Length.
 * @param s - Number of starts.
 * @param TAPER - Taper angle.
 */
module show_profile(V = THREAD_ACME, title = "ACME", l = 4, s = 1, TAPER = 0) {
    ADD = (TAPER > 0) ? add_npt(TAPER) : [1, 0];

    POLY = concat(
        [[0, -1]],
        [for (N = [0:(len(V) * l)])[wrap(V, N, ADD)[0], 1 + 4 * ADD[1] - wrap(V, N, ADD)[1]]],
        [[l, -1]]
    );

    color("lightblue") difference() {
        polygon(POLY);
        translate([0.5, -0.75]) text(title, 0.75);
    }

    translate([4, -1]) 
        rotate([0, 90]) tsmthread(4, 3, 1, PR = V, STARTS = s, TAPER = TAPER, $fn = 64);
}

/**
 * Test and visualize NPT taper profile.
 * 
 * @param TAPER - Taper angle.
 * @param W - Width.
 */
module npt_profile_test(TAPER = 15, W = 3) translate([1 / 8, 2 / 3]) {
    // Calculate taper and matching NPT profile
    PR = prof_npt(TAPER, 0.4, 0.4);
    ADD = add_npt(TAPER);

    // A diagram of NPT thread calculated the same way tsmthread does it
    difference() {
        for (X = W)
            polygon(concat([[0, -0.125]], [for (N = [0:X * len(PR)]) wrap(PR, N, ADD)], [[X, -0.125]]));
        translate([0, -0.1]) rotate([0, 0, TAPER]) square([10, 0.025]);

        translate([1.5, -1 / 16]) text("A", 0.25);
    }

    translate([0.25, -0.5]) text("NPT Taper Profile", 0.25);

    for (X = [1:W - 1], S = 0.8)
        translate([0.02, 1 - .22] + X * ADD) difference() {
            // Equilateral triangles to eyeball with
            rotate([0, 0, -90]) intersection() {
                circle($fn = 3, d = S / cos(60));
                rotate([0, 0, 60]) circle($fn = 3, d = -.1 + flat(3) * S / cos(60));
            }
            translate(-[0.75, 1] * 0.25) text("60", 0.25);
        }

    echo("Input angle", TAPER, "Measured Angle", atan((interpolate(PR, 2, ADD) - interpolate(PR, 0, ADD)) / 2), "Diff",
         TAPER - atan((interpolate(PR, 2, ADD) - interpolate(PR, 0, ADD)) / 2));
}
