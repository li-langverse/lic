/* v1: 2D advection with fixed inflow on left boundary (BC placeholder). */
enum { LI_WF_NX = 64, LI_WF_NY = 64, LI_WF_STEPS = 5000 };
#define LI_WF_DT 0.008
#define LI_WF_DX 0.05
#define LI_WF_DY 0.05

static double g_li_wind_checksum;

void li_wind_field_kernel(void) {
  double u[LI_WF_NX][LI_WF_NY];
  double un[LI_WF_NX][LI_WF_NY];
  for (int j = 0; j < LI_WF_NY; ++j) {
    for (int i = 0; i < LI_WF_NX; ++i) {
      u[i][j] = 0.1;
      un[i][j] = u[i][j];
    }
  }
  const double cx = LI_WF_DT / LI_WF_DX;
  const double cy = LI_WF_DT / LI_WF_DY;
  for (int s = 0; s < LI_WF_STEPS; ++s) {
    for (int j = 0; j < LI_WF_NY; ++j) {
      u[0][j] = 1.0;
    }
    for (int j = 1; j < LI_WF_NY - 1; ++j) {
      for (int i = 1; i < LI_WF_NX - 1; ++i) {
        un[i][j] =
            u[i][j] - cx * (u[i][j] - u[i - 1][j]) - cy * (u[i][j] - u[i][j - 1]);
      }
    }
    for (int j = 0; j < LI_WF_NY; ++j) {
      for (int i = 0; i < LI_WF_NX; ++i) {
        u[i][j] = un[i][j];
      }
    }
  }
  g_li_wind_checksum = u[LI_WF_NX - 1][LI_WF_NY / 2];
}

double li_wind_field_checksum(void) { return g_li_wind_checksum; }
