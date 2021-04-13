run("Set Measurements...", "area mean integrated redirect=None decimal=2");
rename("orig");
run("Duplicate...", "title=orig_dup");
run("Auto Threshold", "method=Otsu white");
run("Invert LUT");
setOption("BlackBackground", false);
run("Erode");
run("Erode");
run("Watershed");
run("Analyze Particles...", "size=100-Infinity pixel show=[Count Masks] display exclude clear");
run("Gamma...", "value=0.05");
run("Green");
run("8-bit");
selectWindow("orig");
run("Red");
run("Merge Channels...", "c1=orig c2=[Count Masks of orig_dup] create keep");
