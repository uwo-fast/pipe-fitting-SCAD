include <tsmthread.scad>

/******************************************************************************/
/********************************NPT THREAD************************************/
/******************************************************************************/

/**
 * Generates an NPT (National Pipe Thread) profile.
 * Tapering only works without distorting teeth because of the special prof_npt thread profile.
 * 
 * @param DMAJ - Major diameter.
 * @param L - Length.
 * @param PITCH - Pitch.
 * @param TAPER - Taper angle.
 * @param STUB - Stub length.
 */
module thread_npt(DMAJ = 10, L = 10, PITCH = 2.5, TAPER = 1 + (47 / 60), STUB = 0) {
    PR = prof_npt(TAPER);
    echo(add_npt(TAPER));
    tsmthread(DMAJ = DMAJ, L = L, PITCH = PITCH, TAPER = TAPER, PR = PR, STUB = STUB);
}

/**
 * Generates compensated threads.
 * Threads are thinned by $PE mm. Diameter is adjusted by $OD_COMP/$ID_COMP amount
 * depending on whether they're inside or outside threads.
 * Only use this with leadscrews.
 * 
 * @param DMAJ - Major diameter.
 * @param L - Length.
 * @param PITCH - Pitch.
 * @param A - Pitch angle.
 * @param H1 - Distance below centerline in pitch units.
 * @param H2 - Distance above centerline in pitch units.
 * @param STARTS - Number of thread starts.
 * @param in - True if inside thread, false otherwise.
 */
module comp_thread(DMAJ = 11, L = 20, PITCH = 2, A = 30, H1 = 0.5 / 2, H2 = 0.5 / 2, STARTS = 1, in = false) {
    PE2 = (in ? $PE : -$PE) * (2.0 / PITCH) * cos(A);
    echo("PE", PE2, "$PE", $PE);
    PR = prof(A, H1 - PE2, H2 + PE2);
    echo("comp_thread", "DMAJ", DMAJ, "L", L, "PITCH", PITCH, "A", A, "H1", H1, "H2", H2, "=", PR);

    tsmthread(DMAJ + (in ? $ID_COMP : $OD_COMP), L = L, PITCH = PITCH, STARTS = STARTS, PR = PR);
}
