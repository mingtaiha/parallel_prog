#define TOLERANCE 0.0001

task void threaded_newton_task(uniform float size, uniform float threads, uniform float arr[], uniform float appx_arr[]) {
	uniform int span = size / (taskCount+1);
	uniform int start = taskIndex * span;
    uniform int end = (taskIndex+1) * span;

	if(taskIndex == taskCount-1){
		end = size;
	}
    foreach (i = 0 ... threads) {
    	int threadSpan = span / threads;
    	int threadStart = i*threadSpan;
    	int threadEnd = (i+1)*threadSpan;
    	int j;
    	if(i == threads-1){
    		threadEnd = end;
    	}
    	for(j = start; j < end; j++){
			float x = arr[j];
			float xprev = 0;
			while (abs(x - xprev) > TOLERANCE) {
				xprev = x;
				x = (x + arr[j] / x) / 2;
			}
			appx_arr[j] = x;
		}
	}
}

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
void threaded_newton(uniform float size, uniform float threads, uniform float arr[], uniform float appx_arr[]) {
	
    foreach (i = 0 ... threads) {
    	int threadSpan = size / threads;
    	int threadStart = i*threadSpan;
    	int threadEnd = (i+1)*threadSpan;
    	int j;
    	if(i == threads-1){
    		threadEnd = size;
    	}
    	for(j = 0; j < size; j++){
			float x = arr[j];
			float xprev = 0;
			while (abs(x - xprev) > TOLERANCE) {
				xprev = x;
				x = (x + arr[j] / x) / 2;
			}
			appx_arr[j] = x;
		}
	}
}

void newton(uniform float size, uniform float arr[], uniform float appx_arr[]) {
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

export void newton_ispc(uniform float size, uniform float threads, uniform int cores, uniform float arr[], uniform float appx_arr[]) {  
	if(cores == 1){
		if(threads < 0)
			newton (size, arr, appx_arr);
		else
			threaded_newton( size, threads, arr, appx_arr);	
	}
	else{
		if(threads < 0)
			launch[cores] newton_task (size, arr, appx_arr);
		else
			launch[cores] threaded_newton_task( size, threads, arr, appx_arr);
	}
}
