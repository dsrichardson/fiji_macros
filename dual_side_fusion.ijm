//This macro is used for dual side fusion (maximum intensity projection) of large TILED files from a Zeiss Lightsheet Z1.
//If ZEN produces a "Out of Memory Error" this macro can be used instead.
//The file must be collected using the "Split view" function so that every tile has it's own .CZI file
//The index file (.CZI file that represents the 1st tile - no number in brackets after it) must be placed in it own folder or else macro runs very slowly
//All other .CZI files should be together in a single folder
//Currently only works with a two channel image - email drichardson@fas.harvard.edu for other options
//Requires Bioformats version 5.7.2 or higher


//Written by D Richardson 12/15/2017



indexDir = getDirectory("Which folder contains the index file? (Must be in seperate folder from all other views)");
indexDir_array = getFileList(indexDir);
indexDir_length = indexDir_array.length;

inputDir = getDirectory("Which folder contains all other files?");
inputDir_array = getFileList(inputDir);
inputDir_length = inputDir_array.length;


setBatchMode (true);

max project all files in INDEX directory (should only be one file)
for (i=0; i < indexDir_array.length; i++) {
    //get number of Z-sices
    run("Bio-Formats Macro Extensions");
    path = indexDir + File.separator + indexDir_array[i];
    print(path);
    Ext.setId(path);
    Ext.getCurrentFile(file);
    Ext.getSizeZ(sizeZ);
    //each Z plane has 4 color channels: Ch1=green from left, Ch2=red from left, Ch3=green from right, Ch4=red from right
    //Max project green images from first Z-plane
    run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=1 c_end=3 c_step=2 z_begin=1 z_end=1 z_step=1");
    rename("new");
    run("Z Project...", "projection=[Max Intensity]");
    rename("MAX");
    close("new");
    print("First Z-plane, green channel (index), projected.");
    //Max project and concatinate green images from all other Z-planes
    for (z =2; z <= sizeZ; z++) {
        run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=1 c_end=3 c_step=2 z_begin=" + z + " z_end=" + z + " z_step=1");
        rename("new");
        run("Z Project...", "projection=[Max Intensity]");
        rename("new1");
        close("new");
        run("Concatenate...", "vtitle=[Concatenated Stacks]vimage1=MAX image2=new1");
        rename("MAX");
        call("java.lang.System.gc");
    }
    //Save Max-projected Z-stack
    print("All Z-planes, green channel (index), projected.");
    saveAs("Tiff", indexDir + File.separator + "scene_index_green");
    run("Close All");
    call("java.lang.System.gc");
    
    //Max project red images from first Z-plane
    run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=2 c_end=4 c_step=2 z_begin=1 z_end=1 z_step=1");
    rename("new");
    run("Z Project...", "projection=[Max Intensity]");
    rename("MAX");
    close("new");
    print("First Z-plane, red channel (index), projected.");
    //Max project and concatinate red images from all other Z-planes
    for (z =2; z <= sizeZ; z++) {
        run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=2 c_end=4 c_step=2 z_begin=" + z + " z_end=" + z + " z_step=1");
        rename("new");
        run("Z Project...", "projection=[Max Intensity]");
        rename("new1");
        close("new");
        run("Concatenate...", "vtitle=[Concatenated Stacks]vimage1=MAX image2=new1");
        rename("MAX");
        call("java.lang.System.gc");
    }
    //Save Max-projected Z-stack
    print("All Z-planes, red channel (index), projected.");
    saveAs("Tiff", indexDir + File.separator + "scene_index_red");
    run("Close All");
    call("java.lang.System.gc");
}

//max project all files (files=tiles=scenes) in INPUT directory
for (j=0; j < indexDir_array.length; j++) {
    //get number of Z-sices
    run("Bio-Formats Macro Extensions");
    path = inputDir + File.separator + inputDir_array[j];
    print(path);
    Ext.setId(path);
    Ext.getCurrentFile(file);
    Ext.getSizeZ(sizeZ);
    //each Z plane has 4 color channels: Ch1=green from left, Ch2=red from left, Ch3=green from right, Ch4=red from right
    //Max project green images from first Z-plane
    run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=1 c_end=3 c_step=2 z_begin=1 z_end=1 z_step=1");
    rename("new");
    run("Z Project...", "projection=[Max Intensity]");
    rename("MAX");
    close("new");
    print("First Z-plane, green channel (scene " + j + "), projected.");
    //Max project and concatinate green images from all other Z-planes
    for (z =2; z <= sizeZ; z++) {
        run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=1 c_end=3 c_step=2 z_begin=" + z + " z_end=" + z + " z_step=1");
        rename("new");
        run("Z Project...", "projection=[Max Intensity]");
        rename("new1");
        close("new");
        run("Concatenate...", "vtitle=[Concatenated Stacks]vimage1=MAX image2=new1");
        rename("MAX");
        call("java.lang.System.gc");
    }
    //Save Max-projected Z-stack
    print("All Z-planes, green channel (scene " + j + "), projected.");
    saveAs("Tiff", inputDir + File.separator + "scene_" + j + "_green");
    run("Close All");
    call("java.lang.System.gc");
    
    //Max project red images from first Z-plane
    run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=2 c_end=4 c_step=2 z_begin=1 z_end=1 z_step=1");
    rename("new");
    run("Z Project...", "projection=[Max Intensity]");
    rename("MAX");
    close("new");
    print("First Z-plane, red channel (scene " + j + "), projected.");
    //Max project and concatinate red images from all other Z-planes
    for (z =2; z <= sizeZ; z++) {
        run("Bio-Formats Importer", "open=" + path + " color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=2 c_end=4 c_step=2 z_begin=" + z + " z_end=" + z + " z_step=1");
        rename("new");
        run("Z Project...", "projection=[Max Intensity]");
        rename("new1");
        close("new");
        run("Concatenate...", "vtitle=[Concatenated Stacks]vimage1=MAX image2=new1");
        rename("MAX");
        call("java.lang.System.gc");
    }
    //Save Max-projected Z-stack
    print("All Z-planes, red channel (scene " + j + "), projected.");
    saveAs("Tiff", inputDir + File.separator + "scene_" + j + "_red");
    run("Close All");
    call("java.lang.System.gc");
}