input = getDirectory("Choose the directory where the files are");
psf = File.openDialog("Select where the PSF file is stored");
 
output = input + "deconvolved/";

File.makeDirectory(output) 

setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++) 
        if (endsWith(list[i],'.tif')) 
        	action(input, output, list[i],psf);

function action(input,output,filename,pathToPsf){
	run("Bio-Formats Importer", "open=["+input+filename+"] autoscale color_mode=Default split_channels view=[Standard ImageJ] stack_order=Default");
	decon(input,output,filename,pathToPsf);
call("java.lang.System.gc");
}

function decon(input,output,filename,pathToPsf) {
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// MRNSD
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	pathToBlurredImage = input + filename;
	pathToDeblurredImage = output + filename;
	preconditioner = "FFT"; //available options: FFT, NONE
	preconditionerTol = "-1"; //if -1, then GCV is used to compute preconditionerTol
	boundary = "REFLEXIVE"; //available options: REFLEXIVE, PERIODIC, ZERO
	resizing = "AUTO"; // available options: AUTO, MINIMAL, NEXT_POWER_OF_TWO
	output = "SAME_AS_SOURCE"; // available options: SAME_AS_SOURCE, BYTE, SHORT, FLOAT  
	precision = "SINGLE"; //available options: SINGLE, DOUBLE
	stoppingTol = "-1"; //if -1, then stoppingTol is computed automatically
	threshold = "-1"; //if -1, then disabled
	logConvergence = "true";
	maxIters = "10";
	nOfThreads = "8";
	showIter = "false";
	call("edu.emory.mathcs.restoretools.iterative.ParallelIterativeDeconvolution3D.deconvolveMRNSD", pathToBlurredImage, pathToPsf, pathToDeblurredImage, preconditioner, preconditionerTol, boundary, resizing, output, precision, stoppingTol, threshold, logConvergence, maxIters, nOfThreads, showIter);
}