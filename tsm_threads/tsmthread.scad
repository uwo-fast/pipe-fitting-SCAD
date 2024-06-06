/**
 *  TSM Generic Thread Generator 0.0.4, Tyler Montbriand, 2019
 *
 * Fast and flexible threaded profile generator producing
 * frugal and consistent meshes. It can use arbitrary
 * profiles, i.e., UTS or ACME, and can do NPT-style
 * tapering.
 *
 * Public functions:
 * tsmthread(DMAJ, L, PITCH, PR, STARTS, POINTS, OFF, TAPER);
 *      Generates an arbitrary thread.
 *      DMAJ    diameter. Threads all cut below this diameter.
 *      L       Length.
 *      PITCH   Distance between threads.
 *      PR      Point profile.
 *                  THREAD_UTS     All normal screws.
 *                  THREAD_ACME    ACME leadscrews.
 *                  THREAD_TRAP    Metric leadscrews
 *                  THREAD_NH      North American Garden Hose
 *                  ...or any other profile following the form
 *                      [ [x1,y1], ..., [xn,yn] ] xn+1 > xn, 0 <= y <= 1
 *                      Both X and Y in units of pitch.
 *      STARTS  >1 are multi-start threads, like some leadscrews or bottles.
 *      OFF     Small increase or decrease to radius for tolerances.
 *      TAPER   Adds offset of [1,tan(TAPER)] per thread. This tapers
 *              in a manner which preserves pitch and pitch depth. Thread
 *              angles change but can be compensated for. See prof_npt()
 *              and add_npt() and visual_test() for how that was done.
 *
 * thread_npt(DMAJ, L, PITCH, POINTS, OFF);
 *      Generates an NPT thread of 1 degree 47 second taper.
 *
 * X = prof(A, MIN, MAX)
 *      Generates a truncated thread profile. A is angle in degrees,
 *      MIN and MAX are positive numbers denoting distance above and
 *      below centerline in pitch units. i.e., prof(29, 0.25, 0.25) is ACME.
 *
 * comp_thread(DMAJ = 11, L = 20, PITCH = 2, A = 30, H1 = 0.5 / 2, H2 = 0.5 / 2, STARTS = 1, in = false)
 *      Generates a thread profile with teeth thinned an amount configurable by $PE.
 *      DMAJ, L, PITCH, STARTS all as for tsmthread.
 *      A, H1, H2   See prof().
 */

/**
 * Corrections for inside and outside diameters in mm. Only comp_thread
 * and the test platters care, not raw tsmthread. They are $metavariables
 * so imperial() can scale them.
 *
 * Basically, tsmthread(DMAJ = X + $OD_COMP) for outside diameters and
 * tsmthread(DMAJ = X + $ID_COMP) for insides is good enough for wide-angled
 * like the ordinary UTS bolts used everywhere internationally.
 *
 * Leadscrews, on the other hand, are very steep and print horribly. comp_thread will
 * generate them with narrower teeth to compensate.
 */

include <thread_profiles.scad>;
include <utils.scad>;

$OD_COMP = -0.25; // Add this to outside diameters, in mm
$ID_COMP = 1;     // Add this to inside diameters, in mm
$PE = 0.35;       // Pitch Error. Adjusts tooth thickness.

module tsmthread(
    DMAJ = 20,       // Major diameter
    L = 50,          // Length of thread in mm. Accuracy depends on pitch.
    PITCH = 2.5,     // Scale of the thread itself.
    PR = THREAD_UTS, // Thread profile, i.e., ACME, UTS, other
    STARTS = 1,      // Multi-start threads, like some leadscrews or bottles
    TAPER = 0,       // Adds an offset of [1, tan(TAPER)] per thread.
    STUB = 0,        // Extends a cylinder below the thread. In pitch units.
    STUB_OFF = 0     // Reduces the diameter of stub. In pitch units.
) {

    /* Minimum number of radial points required to match thread profile */
    POINTS_MIN = len(PR) * STARTS * 2;

    // OpenSCAD-style fragment generation via $fa and $fs.
    // See https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features
    function points_r(r) = ceil(max(min(360.0 / $fa, (r * 2) * 3.14159 / $fs), 5));

    // Rounds X up to a nonzero multiple of Y.
    function roundup(X, Y) = Y * max(1, floor(X / Y) + (((X % Y) > 0) ? 1 : 0));

    // Points can be forced with $fn
    POINTS = ($fn > 0) ? $fn : max(roundup(16, POINTS_MIN), roundup(points_r(DMAJ / 2), POINTS_MIN));

    if (POINTS % POINTS_MIN) {
        echo("WARNING:  DMAJ", DMAJ, "PITCH", PITCH, "STARTS", STARTS, "POINTS", POINTS);
        echo("WARNING:  POINTS should be a multiple of", POINTS_MIN);
        echo("WARNING:  Top and bottom geometry may look ugly");
    }

    ADD = add_npt(TAPER); // How much radius to add to pitch each rotation

    // 1 * STARTS rows of thread taper happens which isn't drawn
    // Add this to radius to compensate for it
    TAPER_COMP = STARTS * ADD[1] * PITCH;

    // [X, Y, Z] point along a circle of radius R, angle A, at position Z.
    function traj(R, A, Z) = R * [sin(A), cos(A), 0] + [0, 0, Z];

    /**
     * The top and bottom are cut off, so more height than 0 is needed
     * to generate a thread.
     */
    RING_MIN = (STARTS + 1) * len(PR);

    // Find the closest PR[N] for a given X, to estimate thread length
    function minx(PR, X, N = 0) = (X > wrap(PR, N + 1, ADD)[0]) ? minx(PR, X, N + 1) : max(0, N);

    // Calculated number of rings per height.
    RINGS = let(SEG = floor(L / PITCH), X = (L % PITCH) / PITCH) max(RING_MIN + 1, RING_MIN + SEG * len(PR) + minx(PR, X));

    SHOW = 0; // Debug value. Offsets top and bottom to highlight any mesh flaws

    /**
     * How this works: Take PR to be the outside edge of a cylinder of radius DMAJ.
     * Generate points for 360 degrees. N is angle along this circle, RING is height.
     *
     * Now, to turn this circle into a spiral, a little Z is added for each value of N.
     * The join between the first and last vertex of each circle must jump to meet.
     */
    function zoff(RING, N) = (wrap(PR, RING, ADD)[0] + STARTS * (N / POINTS));
    FLAT_B = zoff(len(PR) * STARTS, 0); // Z coordinates of bottom flat
    FLAT_T = zoff(RINGS - len(PR), 0);  // Z coordinates of top flat

    /**
     * Delimit what spiral coordinates exist between the top and bottom flats.
     * Used for loops, so that only those polygons are joined and nothing outside it.
     */
    // function ringmin(N) = binsearch2(PR, FLAT_B - (N / POINTS) * STARTS) + 1;
    // function ringmax(N) = binsearch2(PR, FLAT_T - (N / POINTS) * STARTS);

    // Fast-lookup arrays
    MIN = [for (N = [0:POINTS - 1]) binsearch2(PR, FLAT_B - (N / POINTS) * STARTS) + 1];
    MAX = [for (N = [0:POINTS - 1]) binsearch2(PR, FLAT_T - (N / POINTS) * STARTS)];

    // Array-lookup wrappers which speed up ringmax/ringmin manyfold.
    // binsearch makes them fast enough to be tolerable, but still much better
    function ringmax(N) = MAX[N % POINTS];
    function ringmin(N) = MIN[N % POINTS];

    /**
     * Interpolate along the profile to find the points it cuts through
     * the main spiral.
     *
     * Some difficulty is RING coordinates increase P, while N decreases
     * it as it crosses the spiral!
     *
     * Taper must be accounted for as well.
     */
    function radius_flat(RING, N) = TAPER_COMP + (DMAJ / 2) -
                                    PITCH * interpolate(PR,
                                                        wrap(PR, len(PR) * STARTS + RING, ADD)[0] -
                                                            (STARTS * (N / POINTS)) % 1 - STARTS,
                                                        ADD)
                                    - ADD[1] * STARTS * (((N / POINTS) * STARTS) % 1);

    /**
     * Radius is generated differently for the top & bottom faces than the spiral because
     * they exist in different coordinate spaces. Also, the top & bottom faces must be
     * interpolated to fit.
     */
    function cap(RING, ZOFF = 0, ROFF = 0) = [for (N = [0:POINTS - 1])
            let(P = N / POINTS, A = -360 * P, R = radius_flat(RING, N) + ROFF) traj(R, A, zoff(RING, 0) + ZOFF)];

    /**
     * Debug function.
     * Draws little outlines at every ring height to compare spiral generation
     * to face generation.
     */
    module test() {
        for (RING = [0:RINGS - 1]) {
            POLY = cap(RING, ROFF = 0.1);
            LIST = [[for (N = [0:POINTS - 1]) N]];

            polyhedron(POLY, LIST);
        }
    }

    /**
     * Helper array for generating polygon points.
     * DATA[0]+N, N=[0:POINTS-1] for a point on the bottom face
     * DATA[1]+N, N=[0:POINTS-1] for a point on the top face
     * DATA[2]+N + (M*POINTS), N=[0:POINTS-1], M=[0:RINGS-1] for
     * a point on the main spiral.
     */
    DATA = [
        0,          // 0 = bottom face
        POINTS,     // 1 = top face
        4 * POINTS, // 2 = main spiral
        2 * POINTS, // 3 = stub top
        3 * POINTS, // 4 = stub bottom
        2 * POINTS + POINTS * len(PR), 2 * POINTS + POINTS * len(PR) + RINGS * POINTS
    ];

    /**
     * This is it, this is where the magic happens.
     * Given a point in RING, N spiral coordinates, this decides whether it
     * ends up in the top, the spiral, or the bottom.
     */
    function point(RING, N) = (RING < ringmin(N))   ? DATA[0] + (N % POINTS)                  // Bottom flat
                              : (RING > ringmax(N)) ? DATA[1] + (N % POINTS)                  // Top flat
                                                    : DATA[2] + RING * POINTS + (N % POINTS); // In between

    // Like above but takes a vector to transform into a triangle
    function pointv(V) = [for (N = V) point(N[0], N[1])];

    /**
     * List of points, organized in sections.
     * 0 - RINGS-1          Bottom cap
     * RINGS - (2*RINGS)-1  Top cap
     * RINGS - (3*RINGS)-1  Stub
     * (2*RINGS) - end      Spiral
     * Do not change this arrangement without updating DATA to match!
     */
    POLY = concat(
        // Bottom cap, top cap
        cap(len(PR) * STARTS, -SHOW), cap(RINGS - len(PR), SHOW),
        // Stub top
        [for (N = [0:POINTS - 1]) let(R = (DMAJ / 2) - (STUB_OFF * PITCH)) traj(R, -360 * (N / POINTS), 1)],
        // Stub bottom
        [for (N = [0:POINTS - 1]) let(R = (DMAJ / 2) - (STUB_OFF * PITCH)) traj(R, -360 * (N / POINTS), -STUB)],
        // Main spiral
        [for (RING = [0:RINGS - 1], N = [0:POINTS - 1]) let(
            A = -360 * (N / POINTS), P1 = wrap(PR, RING, ADD), P2 = wrap(PR, RING + len(PR) * STARTS, ADD),
            UV = mix(P1, P2, N / POINTS), R = TAPER_COMP + (DMAJ / 2) - PITCH * UV[1], Z = UV[0]) traj(R, A, Z)]
    );

    /**
     * Remove redundant points from polygons.
     * collapse([0,1,1,2,3,4,0]) == [0,1,2,3,4]
     */
    function collapse(V) = [for (N = [0:len(V) - 1]) if (V[(N + 1) % len(V)] != V[N]) V[N]];

    // Should we use quads here? Will fewer loops be faster?
    // Probably shouldn't alter the hard-won mesh maker, but
    // can we do more per loops somehow?
    PLIST = concat(
        // Main spiral A
        [for (N = [0:POINTS - 2], RING = [ringmin(N) - 1:ringmax(N)])
                pointv([[RING, N + 1], [RING, N], [RING + 1, N]])],
        // Main spiral B
        [for (N = [0:POINTS - 2], RING = [ringmin(N + 1) - 1:ringmax(N + 1)])
                pointv([[RING + 1, N + 1], [RING, N + 1], [RING + 1, N]])],
        // stitch A
        [for (N = POINTS - 1, RING = [ringmin(N) - 1:ringmax(0)]) let(
            P = pointv([[RING, N], [RING + 1, N],
                        [RING + len(PR) * STARTS, 0]])) if ((P[0] != P[1]) && (P[0] != P[2]) && (P[1] != P[2])) P],
        // Stitch B
        [for (N = 0, RING = [ringmin(N) - 1:ringmax(N)]) let(
            P = pointv([[RING + 1, N], [RING, N], [RING + 1 - len(PR) * STARTS, POINTS - 1]])) if ((P[0] != P[1]) &&
                                                                                                   (P[0] != P[2]) &&
                                                                                                   (P[1] != P[2])) P],

        // Bottom extension
        [if (STUB) for (WELD = [ [ 0, 3 ], [ 3, 4 ] ],
                        N = [0:POINTS - 1])[DATA[WELD[0]] + N, DATA[WELD[0]] + (N + 1) % POINTS,
                                            DATA[WELD[1]] + (N + 1) % POINTS]],
        [if (STUB) for (WELD = [ [ 0, 3 ], [ 3, 4 ] ],
                        N = [0:POINTS - 1])[DATA[WELD[1]] + N, DATA[WELD[0]] + N, DATA[WELD[1]] + (N + 1) % POINTS]],

        // Bottom flat
        [[for (N = [0:POINTS - 1]) N + DATA[(STUB > 0) ? 4 : 0]]],
        // top flat. Note reverse direction to mirror the normal.
        [[for (N = [0:POINTS - 1], N2 = POINTS - (N + 1)) N2 + DATA[1]]]
    );

    // Scale after, PITCH = 1 is so much less math
    scale([1, 1, PITCH]) translate([0, 0, STUB ? STUB : -FLAT_B]) polyhedron(POLY, PLIST, convexity = 5);
}
