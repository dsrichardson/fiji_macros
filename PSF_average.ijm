//Get user defined variables
Dialog.create("Parameters of your acquisiton");
	Dialog.addMessage("First, define here the imaging parameters:");
	Dialog.addNumber("NA of imaging objective?",1.4);
	Dialog.addMessage("What is the maximum emission wavelegnth?");
	Dialog.addNumber("in nm",530);

	Dialog.show();
	NA = Dialog.getNumber();
	emWl = Dialog.getNumber();

// Get the path to each file and the output directory.
	filePath=File.openDialog("Locate bead image file");
	fileName=File.getName(filePath);
	outputDir=getDirectory("Choose an output location");

//Open File

run("Bio-Formats Importer", "open=" + filePath + " color_mode=Default view=Hyperstack stack_order=XYCZT");
rename("PSF");

//Get metadata from file
height = getHeight();
width = getWidth();
slices = nSlices;
midSlice = round(slices / 2);
getVoxelSize(pw, ph, pd, unit);
height_um = height * ph;
width_um = width * pw;
count = 1;

//Calculate theoretical resolution
res = (0.61*emWl)/NA;
respix = res/1000/pw;


//Expand theoretical resolution 7 times ..... this forms bounding box of each PSF
psfsize_pix = 7 * respix;
psfsize_um = psfsize_pix * pw;

//Find beads
//print(slices);
//print(midSlice);
setSlice(midSlice);
run("Set Measurements...", "mean  redirect=None decimal=2");
run("Find Maxima...", "noise=100 output=[Point Selection] exclude ");
run("Measure");
numMax = nResults;

//Print some inforamtion
print("The theoretical lateral resolution of this imaging system is: " + res + "nm.");
print("The image height is: " + height + "pixels, " + ph * height + " " + unit);
print("The image width is: " + width + "pixels, " + pw * width + " " + unit);
print("The final PSF image will be: " + psfsize_um + "um^2");
print(numMax + " beads were found.");

/*
setBatchMode(true);
//For each bead more than psfsize_um/2 from edge: 1) draw square centered at bead 2) duplicate square to new image 3) convert to 32bit 4) number sequentially
for (i = 0; i < numMax; i++) {
    x = getResult("X", i);
	y = getResult("Y", i);
	//print("Found maxima at " + x + ", " + y);
	if ((x > (psfsize_um /2)) && (y > (psfsize_um /2)) && (x < (width_um - (psfsize_um /2))) && (y < (height_um - (psfsize_um /2)))) {
			selectWindow("PSF");
	        makeRectangle((x/pw - (psfsize_pix /2)), (y/pw - (psfsize_pix /2)), toString(psfsize_pix), toString(psfsize_pix));
	        //print("Made rectangle: " + (x/pw - psfsize_pix /2) + ", " + (y/pw - psfsize_pix /2) + ", " + psfsize_pix + ", " + psfsize_pix);
	        run("Duplicate...", "duplicate");
	        run("32-bit");
	        rename(count);
	        count = count + 1;
		}
}
close("PSF");


// Add all bead images together
for (i = 2; i < count; i++) {
	imageCalculator("Add 32-bit stack", "1", toString(i));
	close(toString(i));
}
//Divide summed image by total count
run("Divide...", "value=" + toString(count-1) + " stack");

setBatchMode(false);

//Save PSF file
run("Enhance Contrast", "saturated=0.001");
run("16-bit");
saveAs("Tiff", outputDir + File.separator + "PSF.tif");



//Get metadata from PSF image
selectWindow("PSF.tif");
PSFheight = getHeight();
PSFwidth = getWidth();
PSFslices = nSlices;
PSFmidSlice = round(PSFslices / 2);

//Do Gaussian Fit
setSlice(PSFmidSlice);
makeLine(0, round(PSFheight/2), PSFwidth, round(PSFheight/2));
run("Plot Profile");
Plot.getValues(x, y);
Fit.doFit("Gaussian", x, y);
Fit.plot;
Fit.logResults;
print ("FWHM="+(Fit.p(3)*2.35));

//Save Gaussian Plot
selectWindow("y = a + (b-a)*exp(-(x-c)*(x-c)/(2*d*d))");
saveAs("Tiff", outputDir + File.separator + "Gaussian_Plot.tif");
