var SCALE_SLICE = "Slice";
var SCALE_CAV_EVENTS = "Cavitation Events";
var SCALE_TOTAL_AREA = "Total Area";
var SCALE_LARGEST_AREA = "Largest Area";

var optLut = "Grays";
var optScale = SCALE_SLICE;
var optLUTRangeFrom = 0;
var optLUTRangeTo = 255;

macro "CC Colour Slices" {

	// Get the details of the current stack
	Stack.getDimensions(ww, hh, channels, slices, frames);

	getSettings();

	print("LUT: " + optLut + ", Scale: " + optScale + ", LUT Range: " + optLUTRangeFrom + "-" + optLUTRangeTo);

	// Clear any existing results
	run("Clear Results");

	// Ensure the area is included in the measurements
	run("Set Measurements...", "area limit redirect=None decimal=3");

	// Measure the areas
	for (n=1; n<=nSlices; n++) {
		setSlice(n);
		run("Measure");
	}

	// Add up the areas
	var totalArea;
	var largestArea = 0;
	var areas = newArray(nResults);
	var totalCavEvents = 0;

	for (n=0; n < nResults; n++) {
		areas[n] = getResult('Area', n);
		if(areas[n] > 0) {
			totalCavEvents = totalCavEvents + 1;
		}
		totalArea = totalArea + areas[n];
		if(areas[n] > largestArea) {
			largestArea = areas[n];
		}
	}

	print("Largest area = " + largestArea + ", Total area = " + totalArea);

	// Send the thresholded areas to a new stack
	run("Analyze Particles...", "size=0-Infinity show=Masks stack");

	// Select the new stack (should be selected anyway but just in case...)
	thresholdedAreas = getImageID();
	selectImage(thresholdedAreas);
	setAutoThreshold("Default ignore_white");

	var LUTRange = optLUTRangeTo - optLUTRangeFrom;

	var curCavEvent = 0;

	// Loop through our stack and set the intensity values based on the scale option
	for (n=1; n <= nSlices; n++) {
		setSlice(n);
		if(areas[n-1] > 0) {
			curCavEvent = curCavEvent + 1;
		}
		if(optScale == SCALE_SLICE) {
			percArea = n / nSlices;
			// print("Scaling by slice " + n + " of " + nSlices + " perc: " + percArea + " area:" + areas[n-1]);
		} else if(optScale == SCALE_TOTAL_AREA) {
			percArea = areas[n - 1] / totalArea;
		} else if(optScale == SCALE_LARGEST_AREA) {
			percArea = areas[n - 1] / largestArea;
		} else if(optScale == SCALE_CAV_EVENTS) {
			percArea = curCavEvent / totalCavEvents;
		}
		intensity = optLUTRangeFrom + floor(LUTRange * percArea);
		setColor(intensity);
		if(areas[n-1] > 0) {
			run("Create Selection"); fill(); run("Select None");
		}
	}
	resetThreshold();
	run(optLut);

	if(optScale == SCALE_SLICE) {
		CreateScale("Slice", optLut, 1, nSlices);
	} else if(optScale == SCALE_TOTAL_AREA) {
		CreateScale("Area", optLut, 1, totalArea);
	} else if(optScale == SCALE_LARGEST_AREA) {
		CreateScale("Area", optLut, 1, largestArea);
	} else if(optScale == SCALE_CAV_EVENTS) {
		CreateScale("Events", optLut, 1, totalCavEvents);
	}
}


function getSettings() {
	luts = getList("LUTs");
 	Dialog.create("Color Settings");
	Dialog.addChoice("LUT", luts);
	Dialog.addChoice("Scale:", newArray(SCALE_TOTAL_AREA, SCALE_LARGEST_AREA, SCALE_SLICE, SCALE_CAV_EVENTS));
	Dialog.addNumber("LUT Range From", optLUTRangeFrom);
	Dialog.addNumber("LUT Range To", optLUTRangeTo);
	Dialog.show();
 	optLut = Dialog.getChoice();
	optScale = Dialog.getChoice();
	optLUTRangeFrom = Dialog.getNumber();
	optLUTRangeTo = Dialog.getNumber();
}

function CreateScale(desc, lutstr, beginf, endf){
	setColor("white");
	ww = optLUTRangeTo;
	hh = 32;
	newImage("color time scale", "8-bit White", ww, hh, 1);
	for (j = 0; j < hh; j++) {
		for (i = optLUTRangeFrom; i < optLUTRangeTo; i++) {
			setPixel(i, j, i);
		}
	}
	run(lutstr);
	run("RGB Color");
	op = "width=" + ww + " height=" + (hh + 16) + " position=Top-Center zero";
	run("Canvas Size...", op);
	setFont("SansSerif", 12, "antiliased");
	run("Colors...", "foreground=white background=black selection=yellow");
	drawString(desc, round(ww / 2) - 12, hh + 16);
	drawString(beginf, 0, hh + 16);
	drawString(endf, ww - 30, hh + 16);
}
