var optSavedSlices;
var optClearColour = "white";
var bClear;

macro "OSOV Save Slices" {

	// Get the details of the current stack
	Stack.getDimensions(ww, hh, channels, slices, frames);

	getSettings();

	optSavedSlices = replace(optSavedSlices, " ", "");
	savedSlices = split(optSavedSlices, ',');

	if(optClearColour == "white") {
		setForegroundColor(255, 255, 255);
	} else {
		setForegroundColor(0, 0, 0);
	}

	for (n=1; n<=nSlices; n++) {
		bClear = true;
		for(i=0; i<savedSlices.length; i++) {
			if(n == savedSlices[i]) {
				bClear = false;
			}
		}
		print("Clear slice " + n + '? ' + bClear);
		if(bClear) {
			clearSlice(n);
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
	Dialog.addString("Save slices:", optSavedSlices);
	Dialog.addChoice("Clear Colour:", newArray("white", "black"));
	Dialog.show();
 	optSavedSlices = Dialog.getString();
	optClearColour = Dialog.getChoice();
}
