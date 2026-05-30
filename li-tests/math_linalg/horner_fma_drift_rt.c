/* Runtime-only float fixtures for horner_fma_drift_step.li (volatile — no DCE). */
#include <stdint.h>

static volatile double g_horner_fma_drift[3] = {
    -482166.4994140733, 22549.44273721706, -190131.7250991714};

double horner_fma_drift_acc(void) { return g_horner_fma_drift[0]; }
double horner_fma_drift_x(void) { return g_horner_fma_drift[1]; }
double horner_fma_drift_addend(void) { return g_horner_fma_drift[2]; }
