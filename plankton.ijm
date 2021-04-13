
run("Auto Threshold", "method=MaxEntropy white");
run("Invert LUT");
run("Close-");
run("Fill Holes");
setOption("BlackBackground", false);

run("Set Measurements...", "area feret's redirect=None decimal=2");

run("Analyze Particles...", "size=25000-Infinity pixel circularity=0.35-1.00 show=[Overlay Masks] display exclude");

