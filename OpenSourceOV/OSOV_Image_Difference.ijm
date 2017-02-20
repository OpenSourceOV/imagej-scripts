
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
//
// macro "Image difference 8-bit" {
//
// 	setBatchMode(true);
//
// 	originalImage = getImageID();
//
// 	Stack.getDimensions(ww, hh, channels, slices, frames);
//
// 	run("Make Substack..."," slices=1-"+ slices-1);
// 	imgID1 = getImageID();
//
// 	selectImage(originalImage);
//
// 	run("Make Substack...", " slices=2-"+ slices);
// 	imgID2 = getImageID();
//
// 	imageCalculator("Subtract create stack", imgID2, imgID1);
//
// 	selectImage(imgID1);
// 	close();
//
// 	selectImage(imgID2);
// 	close();
//
// 	setBatchMode("exit and display");
// }
