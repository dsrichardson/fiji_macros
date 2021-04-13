input = getDirectory("Choose the directory where the ND2 files are");
psf = File.openDialog("Select where the PSF file is stored");

input_tif = input + "tifs/"; 
output = input + "deconvolved/";

File.makeDirectory(input_tif) 
File.makeDirectory(output) 

setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++) 
        if (endsWith(list[i],'.nd2')) 
        	action(input, input_tif, output, list[i],psf);
setBatchMode(false);

function action(input,input_tif,output,filename,pathToPsf){
	run("Bio-Formats Importer", "open=["+input+filename+"] autoscale color_mode=Default split_channels view=[Standard ImageJ] stack_order=Default");
	run("Save", "save=["+input_tif+filename+" - C=1.tif]");	close();
	run("Save", "save=["+input_tif+filename+" - C=0.tif]");	close();

	decon(input_tif,output,filename+" - C=0.tif",pathToPsf);
	decon(input_tif,output,filename+" - C=1.tif",pathToPsf);
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
	output = "FLOAT"; // available options: SAME_AS_SOURCE, BYTE, SHORT, FLOAT  
	precision = "SINGLE"; //available options: SINGLE, DOUBLE
	stoppingTol = "-1"; //if -1, then stoppingTol is computed automatically
	threshold = "-1"; //if -1, then disabled
	logConvergence = "false";