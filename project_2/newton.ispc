#define TOLERANCE 0.0001



export void newton_ispc(uniform float size, uniform float arr[], uniform float appx_arr[]) {

	foreach (i = 0 ... size) {
		float x = arr[i];
		float xprev = 0;
		while (abs(x - xprev) > TOLERANCE) {
			xprev = x;
			x = (x + arr[i] / x) / 2;
		}
		appx_arr[i] = x;
	}
}
