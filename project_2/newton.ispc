#define TOLERANCE 0.0001

task void newton_task(uniform float size, uniform float threads, uniform float arr[], uniform float appx_arr[]) {
	uniform int span = size / (taskCount+1);
	uniform int start = taskIndex * span;
    uniform int end = (taskIndex+1) * span;
    uniform int endOfThread;

	if(taskIndex == taskCount-1){
		end = size;
	}
	endOfThread = end / threads;
    foreach (i = start ... endOfThread) {
    	int threadSpan = span / threads;
    	int threadStart = i*threadSpan;
    	int threadEnd = (i+1)*threadSpan;
    	int j;
    	if(i = endOfThread-1){
    		threadEnd = end;
    	}
    	for(j = start; j < end; j++){
			float x = arr[J];
			float xprev = 0;
			while (abs(x - xprev) > TOLERANCE) {
				xprev = x;
				x = (x + arr[j] / x) / 2;
			}
			appx_arr[j] = x;
		}
	}
}

export void newton_ispc(uniform float size, uniform float threads, uniform int cores, uniform float arr[], uniform float appx_arr[]) {  
	launch[cores] newton_task( size, threads, arr, appx_arr);
}
