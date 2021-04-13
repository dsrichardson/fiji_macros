rename("orig");
count=1

// crop all tiles to seperate files
for (i=1; i < 6; i++) {
	for (j=1; j < 10; j++) {
		print("Drawing rectangle " + (933*i) + ", " + (933*j) + ".");
		selectWindow("orig");
		makeRectangle((933*i), (933*j), 933, 933);
		run("Duplicate...", "duplicate channels=1");
		print("Renaming rectangle " + count + ".");
		rename(count);
		count = count +1;
	}
}
print("The count is: " + count);
// Add all tiled images together
imageCalculator("Add create 32-bit", "1","2");
selectWindow("Result of 1");
rename("Result")
close("1");
close("2");
for (k = 3; k < count; k++) {
	imageCalculator("Add create 32-bit", "Result", toString(k));
	close("Result");
	selectWindow("Result of Result");
	rename("Result");
	close(toString(k));
}
//Divide summed image by total count
run("Divide...", "value=" + toString(count-1));
