run("Select All");
run("Copy");
newImage("Untitled", "RGB white", 440, 1000, 1);
run("Paste");

count = 0
for (x=0; x<440; x+=20) {
	for (y=0; y<1000; y+=20) {
		makeRectangle(x, y, 20, 20);
		print ("x=" + x + " y=" + y);
		run("Duplicate...", " ");
		saveAs("Tiff", "C:\\Users\\drichardson\\Desktop\\boxes\\box" + count + ".tif");
		close();
		count = count + 1;
	}
} 
run("Close All");
