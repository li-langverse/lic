/* Runtime-only float fixtures for mat2_at2_fma_drift_cell.li (volatile — no DCE). */
#include <stdint.h>

static volatile double g_mat2_fma_drift[4] = {
    -352334.47033367527, -698301.65215099615, 301868.94607970747,
    -855127.42666491447};

double mat2_fma_drift_a00(void) { return g_mat2_fma_drift[0]; }
double mat2_fma_drift_b00(void) { return g_mat2_fma_drift[1]; }
double mat2_fma_drift_a01(void) { return g_mat2_fma_drift[2]; }
double mat2_fma_drift_b10(void) { return g_mat2_fma_drift[3]; }
