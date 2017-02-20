var originalStack = "";
var maskStack = "";
var colourStack = "";
var overlayOpacity = 50;

macro "OSOV Apply Mask To Stack" {

	getSettings();

	setBatchMode(true);

	// Duplicate the original stack (this will be the output stack)
	selectWindow(originalStack);
	run("Duplicate...", "duplicate");
	outputStack = getImageID();
	run("RGB Color");

	// Back to the original stack...
	selectWindow(originalStack);

	for (n=1; n<=nSlices; n++) {
		selectWindow(originalStack); setSlice(n);
		selectWindow(maskStack); setSlice(n);
		selectImage(outputStack); setSlice(n);
		imageCalculator("Multiply create 32-bit", originalStack, maskStack);
		multipliedImage = getImageID();

		// Get the colour slice
		selectImage(colourStack); setSlice(n);
		run("Duplicate...", " ");
		colourSlice = getTitle();

		// Add to the multiplied image, flatten and copy to the output stack
		selectImage(multipliedImage);
		run("Add Image...", "image=[" + colourSlice + "] x=0 y=0 opacity=&overlayOpacity");
		run("Flatten");
		flattenedImage = getImageID();
		run("Copy");
		selectImage(outputStack);
		run("Paste");

		// Close the multiplied and colouredSlice images
		selectImage(multipliedImage);
		run("Close");
		selectImage(flattenedImage);
		run("Close");
		selectWindow(colourSlice);
		run("Close");
	}

	setBatchMode("exit and display");

}

function getSettings() {
  allStackTitles = newArray(nImages);
  nStacks=0;
  for (i=1; i<=nImages; i++) {
    selectImage(i);
    if (nSlices>1) {
      allStackTitles[nStacks]=getTitle();
      nStacks++;
    }
  }
  if (nStacks <1) exit("No Stack Window Open");

	Dialog.create("Setup");
	Dialog.addChoice("Original Stack", allStackTitles);
  Dialog.addChoice("Mask Stack", allStackTitles);
	Dialog.addChoice("Colour Stack", allStackTitles);
	Dialog.addNumber("Opacity", overlayOpacity);
  Dialog.show();

	originalStack = Dialog.getChoice();
	maskStack = Dialog.getChoice();
	colourStack = Dialog.getChoice();
	overlayOpacity = Dialog.getNumber();
}
