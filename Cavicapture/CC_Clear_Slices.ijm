var optSliceFrom;
var optSliceTo;
var optClearColour = "white";

macro "CC Clear Slices" {

	// Get the details of the current stack
	Stack.getDimensions(ww, hh, channels, slices, frames);

	getSettings();

	if(optClearColour == "white") {
		setForegroundColor(255, 255, 255);
	} else {
		setForegroundColor(0, 0, 0);
	}

	if(optSliceFrom > 0 && optSliceTo > 0) {
		if(optSliceTo > nSlices) {
			optSliceTo = nSlices;
		}
		for (n=optSliceFrom; n<=optSliceTo; n++) {
			clearSlice(n);
		}
	} else {
		if(optSliceFrom > 0) {
			clearSlice(optSliceFrom);
		}
		if(optSliceTo > 0) {
			clearSlice(optSliceTo);
		}
	}
	run("Select None");
}

function clearSlice(sliceN) {
	setSlice(sliceN);
	run("Select All");
	run("Fill", "slice");
}

function getSettings() {
 	Dialog.create("Clear Settings");
	Dialog.addNumber("Slice From", optSliceFrom);
	Dialog.addNumber("Slice To", optSliceTo);
	Dialog.addChoice("Clear Colour:", newArray("white", "black"));
	Dialog.show();
 	optSliceFrom = Dialog.getNumber();
	optSliceTo = Dialog.getNumber();
	optClearColour = Dialog.getChoice();
}
