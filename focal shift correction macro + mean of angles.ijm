// Create window to get info

	Dialog.create("Parameters of your acquisition");
	Dialog.addMessage("If you use this macro, please reference the following publication: currently unpublished");
	Dialog.addMessage("Directory and file names CANNOT contain spaces.");
	Dialog.addMessage("Please provide the following information about your acquisition:");
	Dialog.addNumber("What was the NA of the imaging objective?",0.80);
	Dialog.addNumber("What was the refractive index of the immersion medium? Air = 1.00, Water = 1.33, oil= 1.52",1.00);
	Dialog.addNumber("What was the refractive index of the mounting/clearing medium? PBS ~ 1.33, Glycerol-based ~ 1.43, solvent-based >= 1.50",1.43);
	Dialog.addNumber("What is the shortest wavelength of excitation light used (in nm)?",488);
	Dialog.addCheckbox("Provide recomended Z-step ONLY (does not process any images)", false);
	Dialog.addCheckbox("Batch process multiple files (all images must use same objective, immersion RI and mounting RI)", false);
	Dialog.show();
	NA = Dialog.getNumber();
	NAincr = NA / 100;
	RIimm = Dialog.getNumber();
	RImount = Dialog.getNumber();
	wavelength = Dialog.getNumber();
	ZstepOnly = Dialog.getCheckbox();
	batch = Dialog.getCheckbox();
	Z_correction_sum = 0;
	count = 0;
	//print(ZstepOnly);
	//print(batch);


// Calculate focal shift correction factor
 
    for (i=0.001; i <= NA; i += NAincr) {
    	x = (tan(asin(i/RIimm))) / (tan(asin(i/RImount)));
    	Z_correction_sum = Z_correction_sum + x;
    	count = count + 1;
    }
    Z_correction_mean = (Z_correction_sum / count);
    print("");
    print("Focal shift correction factor = " + d2s(Z_correction_mean,2) + "x");

// Calculate Z resolution

Zres = ((0.88 * wavelength ) / (RIimm - (sqrt(pow(RIimm, 2) - pow(NA, 2))))) / 1000;

// Calculate the corrected Nyquist Z-sampling

NyquistZ = Zres/2.3;
NyquistZcorr = NyquistZ / Z_correction_mean;


//Print some info

print("");
print("The NA of the imaging objective is: " + NA);
print("The RI of the immersion media is: " + RIimm);
print("The RI of the mounting media is: " + RImount);
print("The recomended Z-step for this experiment is (no correction): " + d2s(NyquistZ,2));
print("The recomended focal shift corrected Z-step for this experiment is: " + d2s(NyquistZcorr,2) + " micrometers.");

if (ZstepOnly == true) {
	exit()
}

//Process single file

setBatchMode (true);

if (batch == false) {
    print("");
    print("1 file to be processed.");
    //Select the file to be processed and an output location
	filePath=File.openDialog("Locate the original file.");
	fileName=File.getName(filePath);
	outputDir=getDirectory("Choose an output directory.");
    //Open file and get actual Z spacing
    run("Bio-Formats Importer", "open=" + filePath + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    filename = getTitle();
    getVoxelSize(Xpix, Ypix, Zpix, unit);
    getDimensions(width, height, channels, slices, frames);
    //print("The units are: " + unit);
    //print("The image has " + slices + " Z slices.");
    if (unit != "microns") {
		print("WARNING: metadata does not indicate pixel size in micrometers!");
		print("Please convert pixel spacing to micrometers and resave the file.");
		print("Quitting macro");
		exit()
	}
	print("");
	if (Zpix <= NyquistZcorr) {
	    print("The Z-step of " + Zpix + " " + unit + " satisfies the RI-corrected Nyquist sampling factor."); 
	}
	if (Zpix > NyquistZcorr) {
		print("WARNING: The Z-step of " + Zpix + " " + unit + " was too large. It should have been: " + NyquistZcorr + " um.");
		print("Processing will continue.");
	}	
	      	
	//*Reset Z spacing (no interpolation)
	setVoxelSize(Xpix, Ypix, Zpix*Zcorrection, "um");
	//Save and close file
	saveAs("Tiff", outputDir + File.separator + filename + ".tif");
	close();
	exit()
}


//Process multiple files (batch)


if (batch == true); {
	print("");
	print("Multiple files will be processed.");
	inputDir = getDirectory("Choose input Directory");
    dir_array = getFileList(inputDir);
    dir_length = dir_array.length;
    outputDir= getDirectory("Choose an output Directory");
    for (i=0; i < dir_array.length; i++) {
    	//Open file and get actual Z spacing
        run("Bio-Formats Importer", "open=" + inputDir + dir_array[i] + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    	filename = getTitle();
        getVoxelSize(Xpix, Ypix, Zpix, unit);
        getDimensions(width, height, channels, slices, frames);
        //print("The units are: " + unit);
        //print("The image has " + slices + " Z slices.");
        if (unit != "microns") {
		    print("WARNING: metadata for file: " + filename + " does not indicate pixel size in micrometers!");
		    print("Please convert pixel spacing to micrometers and resave the file.");
		    print("Quitting macro");
		    exit()
	    }
	    print("");
	    if (Zpix <= NyquistZcorr) {
	        print("The Z-step of " + Zpix + " " + unit + " satisfies the RI-corrected Nyquist sampling factor."); 
	    }
	    if (Zpix > NyquistZcorr) {
		    print("WARNING: In file '" + filename + "' The Z-step of " + Zpix + " " + unit + " was too large. It should have been: " + NyquistZcorr + " um.");
		    print("Processing will continue.");
	    }	
	    //*Reset Z spacing (no interpolation)
	    setVoxelSize(Xpix, Ypix, Zpix*Zcorrection, "um");
	    //Save and close file
	    saveAs("Tiff", outputDir + File.separator + filename + ".tif");
	    close();
	}
}
