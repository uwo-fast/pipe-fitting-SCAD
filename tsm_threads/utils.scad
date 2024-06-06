/******************************************************************************/
/******************************MISC UTILITIES**********************************/
/******************************************************************************/

/**
 * Calculates the flat-to-flat dimension of a polygon.
 * Example: cylinder(d = flat(6) * 10, $fn = 6) makes a 10mm flat-to-flat hexagon.
 * 
 * @param N - Number of sides of the polygon.
 * @return The flat-to-flat dimension.
 */
function flat(N = 6) = 1 / cos(180 / N);

/**
 * Scales up objects to imperial inches and alters $fs accordingly.
 * Example: imperial() cylinder(d = 1, h = 1); renders a satisfying number of facets
 * instead of the default low number of facets.
 * 
 * @param F - Scaling factor, default is 25.4 to convert mm to inches.
 */
module imperial(F = 25.4) {
    // Modified $... values will be seen by children
    $fs = $fs / F;
    $OD_COMP = $OD_COMP / F;
    $ID_COMP = $ID_COMP / F;
    $PE = $PE / F;
    $SCALE = F;
    scale(F) children();
}

/**
 * Creates a double-pointed cone or pyramid of exactly 45 degrees for tapers.
 * Obeys $fn, $fs, $fa, r, d, center = true in a manner like cylinder().
 * 
 * Example:
 * // Outside taper
 * taper(d = 10, h = 10, off = 1) cylinder(d = 10, h = 10);
 * 
 * // Inside taper
 * difference() { cylinder(d = 10, h = 10); taper(in = true, d = 5, h = 10, off = 1) cylinder(d = 5, h = 10); }
 * 
 * @param d - Diameter.
 * @param h - Height.
 * @param off - Offset for bevel.
 * @param r - Radius.
 * @param center - Center the taper.
 * @param in - Create an inside taper.
 */
module taper(d = 1, h = 1, off = 0, r = 0, center = false, in = false) {
    function points_r(r) = $fn ? $fn : (ceil(max(min(360.0 / $fa, (r * 2) * 3.14159 / $fs), 5)));

    if (r) {
        taper(r * 2, h, off, r = 0, center = center, in = in);
    } else {
        // Calculate number of fragments same way OpenSCAD does
        U = points_r(d / 2);

        if (in) {
            difference() {
                children();
                translate(center ? [0, 0, 0] : [0, 0, h / 2]) union() {
                    for (M = [[0, 0, 1], [0, 0, 0]])
                        mirror(M) translate([0, 0, h / 2 - d / 2 - off])
                            cylinder(d1 = 0, d2 = d * 2, h = d, $fn = points_r(d / 2));
                }
            }
        } else {
            intersection() {
                children();
                translate(center ? [0, 0, 0] : [0, 0, h / 2]) scale(h + d - off) polyhedron(
                    concat([for (N = [0:U - 1]) 0.5 * [cos((N * 360) / U), sin((N * 360) / U), 0]],
                           // Top and bottom of pyramid
                           [0.5 * [0, 0, 1], -0.5 * [0, 0, 1]]),
                    concat([for (N = [0:U - 1])[N, U, (N + 1) % U]], [for (N = [0:U - 1])[(N + 1) % U, U + 1, N]])
                );
            }
        }
    }
}

/**
 * Creates a flange pattern as described by the given URL:
 * https://www.helixlinear.com/Product/PowerAC-38-2-RA-wBronze-Nut/
 * 
 * B is height of stem
 * C is diameter of stem
 * F is the radius of the screw pattern
 * F2 is the diameter of the screw holes
 * G is the thickness of the base
 * H is the width of the base
 * 
 * holes is the pattern of holes to drill. Default is 4 holes, 1 every 90 degrees.
 * when open is true, the holes are slots extending to the edge.
 * off is how much to bevel.
 * 
 * @param B - Height of stem.
 * @param C - Diameter of stem.
 * @param F - Radius of the screw pattern.
 * @param F2 - Diameter of the screw holes.
 * @param G - Thickness of the base.
 * @param H - Width of the base.
 * @param off - Bevel offset.
 * @param holes - Pattern of holes to drill.
 * @param open - If true, holes are slots extending to the edge.
 */
module flange(B, C, F, F2, G, H, off = 0, holes = [45:90:360], open = false) {
    taper(d = H, h = G, off = off) linear_extrude(G, convexity = 3) offset(off / 2) offset(-off / 2) difference() {
        circle(d = H);
        for (A = holes)
            hull() {
                translate(F * [sin(A), cos(A)] / 2) circle(d = F2);
                if (open)
                    translate(3 * F * [sin(A), cos(A)] / 2) circle(d = F2);
            }
    }
    if (B && C)
        taper(d = C, h = G + B, off = off) cylinder(d = C, h = G + B);
}

/**
 * Profile Interpolation
 *
 * prof() generates, and tsmthread expects, a profile of [X,Y] values like
 * [ [0,0.25], [0.25, 1], [0.5,0.25] ]
 * The first X must be 0.  The last X cannot be 1.  All values are in pitch units.
 *
 * Get a value out with interpolate(PR, X).
 *      interpolate(PR, 0.25) would return 1,
 *      interpolate(PR, 0) would give 0.25,
 *      interpolate(PR, 0.125) would give something in between,
 *      interpolate(PR, 0.5) would give 0.25,
 *      interpolate(PR, 0.75) would wrap, interpolating between P[2] and p[0].
 *
 * Should wrap cleanly for any positive or negative value.
 */

/**
 * Helper function for interpolate(). Allows
 * a thread profile to repeat cleanly for increasing
 * values of N, with growing X accordingly.
 *
 * @param V - Vector of points.
 * @param N - Index.
 * @param ACC - Accumulated value.
 * @return The wrapped value.
 */
function wrap(V, N, ACC = [1, 0]) = let(M = floor(N / len(V))) V[N % len(V)] + M * ACC;

/**
 * Basic interpolation function.
 * mix(A, B, 0) = A, mix(A, B, 1) = B, 0 <= X <= 1.
 * 
 * @param A - Start value.
 * @param B - End value.
 * @param X - Interpolation factor.
 * @return Interpolated value.
 */
function mix(A, B, X) = (A * (1 - X)) + B * X;

/**
 * Line-matching function. V1-V2 are a pair of XY coordinates describing a line.
 * Returns [X,Y] along that line for the given X.
 * 
 * @param V1 - First coordinate.
 * @param V2 - Second coordinate.
 * @param X - X value.
 * @return [X, Y] coordinate along the line.
 */
function mixv(V1, V2, X) = let(XP = X - V1[0]) mix(V1, V2, XP / (V2[0] - V1[0]));

/**
 * Same as mixv, but for given Y.
 * 
 * @param V1 - First coordinate.
 * @param V2 - Second coordinate.
 * @param Y - Y value.
 * @return [X, Y] coordinate along the line.
 */
function mixvy(V1, V2, Y) = let(OUT = mixv([V1[1], V1[0]], [V2[1], V2[0]], Y))[OUT[1], OUT[0]];

/**
 * Returns Y for given X along an interpolated Y.
 * V must be a set of points [ [0,Y1], [X2,Y2], ..., [XN,YN] ] where X < 1.
 * X can be any value, even negative.
 * 
 * @param V - Vector of points.
 * @param X - X value.
 * @param ACC - Accumulated value.
 * @param N - Index.
 * @return Interpolated Y value.
 */
function interpolate(V, X, ACC = [1, 0], N = 0) =
    (X > 1) ? interpolate(V, (X % 1), ACC, N) + floor(X) * ACC[1] :
    (X > wrap(V, N + 1)[0]) ? interpolate(V, X, ACC, N + 1) :
    mixv(wrap(V, N, ACC), wrap(V, N + 1, ACC), X)[1];

/**
 * Binary search function to find index where XN > X.
 * V = [ [X0,Y0], [X1,Y1], ..., [XN,YN] ] where X0 < X1 < X2 ... < XN.
 * 
 * @param PR - Vector of points.
 * @param X - X value.
 * @param MIN - Minimum index.
 * @param IMAX - Maximum index.
 * @return Index where XN > X.
 */
function binsearch(PR, X, MIN = 0, IMAX = -1) = let(MAX = (IMAX < 0) ? len(PR) : IMAX, N = floor((MIN + MAX) / 2))
    ((MAX - MIN) <= 1) ? N : X < PR[N][0] ? binsearch(PR, X, MIN, ceil((MIN + MAX) / 2)) : binsearch(PR, X, floor((MIN + MAX) / 2), MAX);

/**
 * Binary search function that wraps X > 1 to 0-1 and returns correspondingly higher N.
 * V = [ [X0,Y0], [X1,Y1], ..., [XN,YN] ] where X0 < X1 < X2 ... < XN and XN < 1.
 * 
 * @param PR - Vector of points.
 * @param X - X value.
 * @return Index for given X.
 */
function binsearch2(PR, X) = binsearch(PR, X % 1) + floor(X) * len(PR);

/**
 * Faster lookup for interpolate() using logarithmic time complexity.
 * 
 * @param V - Vector of points.
 * @param X - X value.
 * @param ADD - Accumulated value.
 * @return Interpolated Y value.
 */
function interpolate2(V, X, ADD = [1, 0]) = V[binsearch(V, (X % 1))][1] + floor(X) * ADD[1];

/**
 * Returns the index for given X using binary search.
 * 
 * @param V - Vector of points.
 * @param X - X value.
 * @param ADD - Accumulated value.
 * @return Index for given X.
 */
function interpolaten(V, X, ADD = [1, 0]) = binsearch(V, (X % 1)) + floor(X);

/**
 * Differentiate an array.
 * Example: delta([0,1,2,3,4,5])=[1,1,1,1,1].
 * 
 * @param V - Array to differentiate.
 * @return Differentiated array.
 */
function delta(V) = [for (N = [0:len(V) - 2]) V[N + 1] - V[N]];

/**
 * Integrate an array up to element N.
 * 
 * @param A - Array to integrate.
 * @param ADD - Addition matrix.
 * @param KEEP - Keep matrix.
 * @return Integrated array.
 */
function integ(A, ADD = [[1, 0], [0, 1]], KEEP = [[0, 0], [0, 0]]) = [for (N = [0:len(A) - 2]) integ2(A, N, ADD, KEEP)];

/**
 * Helper function for integ() to integrate an array up to element N.
 * 
 * @param A - Array to integrate.
 * @param N - Element index.
 * @param ADD - Addition matrix.
 * @param KEEP - Keep matrix.
 * @return Integrated array up to element N.
 */
function integ2(A, N, ADD = [[1, 0], [0, 1]], KEEP = [[0, 0], [0, 0]]) = (N <= 0) ? A[0] : (A[N] * KEEP) + (A[N] * ADD) + (integ2(A, N - 1, ADD, KEEP) * ADD);

/**
 * Normalize a vector along Y.
 * Example: normy([3, 0.5]) -> [6, 1].
 * 
 * @param V - Vector to normalize.
 * @return Normalized vector.
 */
function normy(V) = V / V[1];

/**
 * Adds NPT taper.
 * Example: add_npt(ANGLE) returns [1, tan(ANGLE)].
 * 
 * @param TAPER - Taper angle.
 * @return [1, tan(TAPER)].
 */
function add_npt(TAPER) = [1, tan(TAPER)];
