
  
// This macro will export the label and preview image from a series of Axioscan .CZI files contained in the same directory
//Tested with Bioformats version 5.7.2
//Written by D Richardson 11/22/2017

//All .CZI files should be placed in a single folder.  A second empty "output" folder also needs to be created. 
//The macro will initialize by asking you for the location of these folders.

inputDir = getDirectory("Choose input Directory");
dir_array = getFileList(inputDir);
dir_length = dir_array.length;
outputDir= getDirectory("Choose an output Directory");


setBatchMode (true);

//iterate through all files in input directory

for (i=0; i < dir_array.length; i++) {
	//create folder for each file in the output directory
	file_Dir = outputDir + File.separator + dir_array[i];
    File.makeDirectory(file_Dir);

    //determine number of "scenes" (sections on a single slide)
    run("Bio-Formats Macro Extensions");
    path = inputDir + File.separator + dir_array[i];
    //print(path);
    Ext.setId(path);
    Ext.getCurrentFile(file);
    Ext.getSeriesCount(seriesCount);
    //print("This file (" + dir_array[i] +") contains " + seriesCount + " series.");
    sceneNum = (seriesCount - 2) / 6;
    print("There is/are " + sceneNum + " scene(s) in the file: " + dir_array[i]);

    //determine which scene is the label
    label = seriesCount - 1;

    //save image of slide label in same folder
    run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+ label);
    out_path = file_Dir + File.separator + "Label.tif";
    saveAs("tiff", out_path);
    close();
    //save preview image of slide in same folder
    run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+ seriesCount);
    out_path = file_Dir + File.separator + "Preview.tif";
    saveAs("tiff", out_path);
    close();
    call("java.lang.System.gc");
}


