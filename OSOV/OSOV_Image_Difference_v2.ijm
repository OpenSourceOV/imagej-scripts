var SAMPLE_TYPE_STEM = "Stem";
var SAMPLE_TYPE_LEAF = "Leaf";

var sampleType;

macro "OSOV Image Difference v2" {

	getSettings();

	setBatchMode(true);

	originalImage = getImageID();

	Stack.getDimensions(ww, hh, channels, slices, frames);

	run("Make Substack..."," slices=1-"+ slices-1);
	imgID1 = getImageID();

	selectImage(originalImage);

	run("Make Substack...", " slices=2-"+ slices);
	imgID2 = getImageID();

	if(sampleType == SAMPLE_TYPE_STEM) {
		imageCalculator("Subtract create stack", imgID2, imgID1);
	} else {
		imageCalculator("Subtract create stack", imgID1, imgID2);
	}
	selectImage(imgID1);
	close();

	selectImage(imgID2);
	close();

	setBatchMode("exit and display");
}



function getSettings() {
	Dialog.create("Difference Settings");
	Dialog.addChoice("Sample:", newArray(SAMPLE_TYPE_STEM, SAMPLE_TYPE_LEAF));
	Dialog.show();
	sampleType = Dialog.getChoice();
}