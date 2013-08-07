this.onmessage = function(e){
	importScripts('/static/js/jquery-1.9.0.js');
	importScripts('/static/js/jquery-ui-1.10.0.custom.js');
	importScripts('/static/js/sop/Application.js');
	
	
	this.postMessage('msg from worker with data' + e.data)
	
};