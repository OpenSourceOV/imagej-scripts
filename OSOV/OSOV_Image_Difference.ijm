
macro "OSOV Image Difference" {

	setBatchMode(true);

	originalImage = getImageID();

	Stack.getDimensions(ww, hh, channels, slices, frames);

	run("Make Substack..."," slices=1-"+ slices-1);
	imgID1 = getImageID();

	selectImage(originalImage);

	run("Make Substack...", " slices=2-"+ slices);
	imgID2 = getImageID();

	imageCalculator("Subtract 32-bit create stack", imgID2, imgID1);

	selectImage(imgID1);
	close();

	selectImage(imgID2);
	close();

	setBatchMode("exit and display");
}
updateResults()

sample_dir = getDirectory('Select the sample directory');

list = getFileList(sample_dir);

setBatchMode(true);

results_row = 0;

for(i=0; i < list.length; i++) {
	file_name = sample_dir + list[i];
	if(endsWith(file_name, "tif")) {
	
		open(file_name);
	
		img_width = getWidth();
		img_height = getHeight();
		img_name = getTitle();
	
		setResult("Image", results_row, img_name);
		setResult("Height", results_row, img_height);
		setResult("Width", results_row, img_width);
		results_row++;
    close();
	}
}
updateResults()

setBatchMode("exit and display");
