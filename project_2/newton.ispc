#define TOLERANCE 0.0001

task void newton_task(uniform float size, uniform float arr[], uniform float appx_arr[]) {
	uniform int span = size / (taskCount+1);
	uniform int start = taskIndex * span;
    uniform int end = (taskIndex+1) * span;
	if(taskIndex == taskCount-1){
		end = size;
	}
    foreach (i = start ... end) {
		float x = arr[i];
		float xprev = 0;
		while (abs(x - xprev) > TOLERANCE) {
			xprev = x;
			x = (x + arr[i] / x) / 2;
		}
		appx_arr[i] = x;
	}
}

export void newton_ispc(uniform float size, uniform int cores, uniform float arr[], uniform float appx_arr[]) {  
	launch[cores] newton_task( size, arr, appx_arr);
}
