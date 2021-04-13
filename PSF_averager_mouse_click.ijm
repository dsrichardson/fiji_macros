//Get user defined variables
Dialog.create("Parameters of your acquisiton");
	Dialog.addMessage("First, define here the imaging parameters:");
	Dialog.addNumber("NA of imaging objective?",1.4);
	Dialog.addMessage("What is the maximum emission wavelegnth?");
	Dialog.addNumber("in nm",605);

	Dialog.show();
	NA = Dialog.getNumber();
	emWl = Dialog.getNumber();

// Get the path to each file and the output directory.
	filePath=File.openDialog("Locate bead image file");
	fileName=File.getName(filePath);
	outputDir=getDirectory("Choose an output location");

//Open File

run("Bio-Formats Importer", "open=" + filePath + " color_mode=Default view=Hyperstack stack_order=XYCZT");
myImageID = getInfo("image.filename"); 
rename("PSF");

//Get metadata from file
height = getHeight(); //this is in pixels
width = getWidth();  //this ins in pixels
getVoxelSize(pw, ph, pd, unit); //these are in um
height_um = height * ph; //this is total height in um
width_um = width * pw; //this is total height in um
count = 1;

//Calculate theoretical resolution
res = (0.61*emWl)/NA; //in nm
respix = res/1000/pw; // resolution in pixel units


//Expand theoretical resolution 7 times ..... this forms bounding box of each PSF
psfsize_pix = 7 * respix; //bounding box in pixel units
psfsize_um = psfsize_pix * pw; //bounding box in um

//find bead locations via mouse clicks
setOption("DisablePopupMenu", true);
setTool("rectangle");
leftButton=16;
rightButton=4;
circleHeight = psfsize_pix;
circleWidth = psfsize_pix;
print("circle height/width = " + circleHeight + " pixels.");
x2=-1; y2=-1; z2=-1; flags2=-1;
getCursorLoc(x, y, z, flags);
	wasLeftPressed = false;
    while (flags&rightButton==0){
    	getCursorLoc(x, y, z, flags);
        if (flags&leftButton!=0) {
        // Wait for it to be released
        	wasLeftPressed = true;
        } 
        else if (wasLeftPressed) {
        	wasLeftPressed = false;
            if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
                                x = x - circleWidth/2;
                                y = y - circleHeight/2;
                                makeOval(x, y, circleWidth, circleHeight);
                                roiManager("Add");     
			}
		}
	}
setOption("DisablePopupMenu", false);
numMax = roiManager("count");

//Print some inforamtion
print("The theoretical lateral resolution of this imaging system is: " + res + "nm.");
print("The image height is: " + height + "pixels, " + ph * height + " " + unit);
print("The image width is: " + width + "pixels, " + pw * width + " " + unit);
print("The final PSF image will be: " + psfsize_um + "um^2");
print(numMax + " beads will be averaged.");


setBatchMode(true);
//For each bead 1) draw circle centered at bead 2) duplicate square to new image 3) convert to 32bit 4) number sequentially
for (i = 0; i < numMax; i++) {
    roiManager("select", i);
	run("Duplicate...", "duplicate");
	run("32-bit");
	rename(count);
	count = count + 1;
}

close("PSF");


// Add all bead images together
for (j = 2; j < count; j++) {
	imageCalculator("Add 32-bit stack", "1", toString(j));
	close(toString(j));
}
//Divide summed image by total count
run("Divide...", "value=" + toString(count-1) + " stack");
//Save PSF file
run("Enhance Contrast", "saturated=0.001");
run("16-bit");
Dir=outputDir + File.separator + myImageID;
File.makeDirectory(Dir);
saveAs("Tiff", Dir + File.separator + "PSF.tif");

selectWindow("Log");
saveAs("text", Dir + File.separator + "Log.txt");

setBatchMode(false);
/*
 

//Calculate FWHM
psfheight = getHeight();
psfwidth = getWidth();
psfslices = nSlices;
psfmidSlice = round(psfslices / 2);

setSlice(psfmidSlice);
makeLine(0, (psfheight/2), psfwidth, (psfheight/2));
run("Plot Profile");

Plot.getValues(xpoints, ypoints);
Fit.doFit("Gaussian", xpoints, ypoints);
print("FWHM="+ (Fit.p(3) * 2.35482)); //p(3) = parameter 3 = "d" in log window
selectWindow("Log");
saveAs("text", Dir + File.separator + "Log.txt");
selectWindow("Plot of PSF");
saveAs("Tiff", Dir + File.separator + "Plot of PSF.tif");

setBatchMode(false);
