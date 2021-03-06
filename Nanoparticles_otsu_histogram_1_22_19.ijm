rename("Original");
run("Duplicate...", "title=red duplicate channels=2");
run("Add Slice");
run("Add Slice");
run("Slice Remover", "first=1 last=1 increment=1");
setSlice(nSlices);
run("Add Slice");
run("Add Slice");
run("Despeckle", "stack");
run("Mean...", "radius=35 stack");
run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
run("Invert", "stack");
run("Dilate", "stack");
run("Close-", "stack");
run("Fill Holes", "stack");
run("Invert", "stack");
run("Subtract...", "value=254 stack");
selectImage("Original");
run("Duplicate...", "title=green duplicate channels=1");
run("Add Slice");
run("Add Slice");
run("Slice Remover", "first=1 last=1 increment=1");
setSlice(nSlices);
run("Add Slice");
run("Add Slice");
imageCalculator("Multiply stack", "green","red");
selectWindow("red");
close();
selectImage("green");
run("Set 3D Measurements", "volume nb_of_obj._voxels integrated_density mean_gray_value centroid dots_size=10 font_size=40 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
run("3D object counter...", "threshold=14 slice=20 min.=20 max.=159509504 exclude_objects_on_edges objects statistics summary");
close("green");