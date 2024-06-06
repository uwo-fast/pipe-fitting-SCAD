/**
 * Common thread profiles.
 */

/* UTS (Unified Thread Standard) profile. Used for most common nuts and bolts. */
THREAD_UTS = let(H = 0.8660) prof(60, H * (7 / 16), H * (3 / 8));

/* Garden Hose thread profile. Very close to UTS but sharper and deeper. */
THREAD_NH = let(H = 0.8660) prof(60, H * (3 / 8), H * (3 / 8));

/* Imperial leadscrews. */
THREAD_ACME = let(H = 0.5 / 2) prof(29, H, H);

/* Metric leadscrews. */
THREAD_TRAP = let(H = 0.5 / 2) prof(30, H, H);

/* Vises and other square threads. */
THREAD_EXTERNAL_SQUARE = [[0, 0], [0.25 + .1, 0], [0.25 + .1, 0.5], [0.75 + .1, 0.5], [0.75 + .1, 0]];

/**
 * Generates truncated, symmetrical thread profiles like UTS or ACME.
 * 
 * @param A - Pitch angle in degrees.
 * @param MIN - Distance below centerline in pitch units.
 * @param MAX - Distance above centerline in pitch units.
 * @return Truncated thread profile.
 */
function prof(A, MIN, MAX) = let(
    M = tan(90 - (A / 2)),          // Slope of tooth
    X1 = ((M / 2) - (MIN * 2)) / M, // Given a Y of MIN, calculate X
    X2 = ((M / 2) + (MAX * 2)) / M, // Given a Y of MAX, calculate X
    OFF = -X1 * M
)[
    [0, OFF + M * X1],  // Starting point, always
    [X1 + X1, OFF + M * X1], 
    [X1 + X2, OFF + M * X2], 
    [X1 + 2 - X2, OFF + M * X2]  // Profile wraps here
] / 2;

/**
 * Generates buttress thread profiles.
 * 
 * @param A - Pitch angle in degrees.
 * @param FLAT - Flat distance in pitch units.
 * @return Buttress thread profile.
 */
function prof_butt(A, FLAT) = let(M = tan(A))[
    [0, 0], 
    [FLAT, 0], 
    [FLAT, M * (1 - (2 * FLAT))], 
    [2 * FLAT, M * (1 - (2 * FLAT))]
];

THREAD_BUTT = prof_butt(30, 0.2);

/**
 * Generates NPT (National Pipe Thread) profiles.
 * Length is added to one specific tooth so the distorted half is bent back up to the correct angle.
 * 
 * @param TAPER - Taper angle in degrees.
 * @param H1 - Distance below centerline in pitch units.
 * @param H2 - Distance above centerline in pitch units.
 * @return NPT thread profile.
 */
function prof_npt(TAPER = 30, H1 = 0.8 / 2, H2 = 0.8 / 2) = let(
    M = tan(TAPER), 
    PR2 = delta(prof(60, H1, H2))
) integ([
    [0, 0],  // Replace origin deleted by delta()
    PR2[0],  // Bottom flat, OK
    PR2[1] + M * normy(PR2[1]) * (PR2[1][0] + PR2[0][0]),  // Add length of line and flat
    PR2[2],  // Top flat
    PR2[3]
]);

/* Ball threads, just for fun. */
THREAD_BALL = concat(
    [[0, 0]],
    // Designed for 4.5mm balls used at a 6mm pitch
    [for (A = [0:12.857:180]) let(R = (4.5 + 0.25) / (6 * 2)) R * [-cos(A), sin(A)] + [0.5, 0]]
);
