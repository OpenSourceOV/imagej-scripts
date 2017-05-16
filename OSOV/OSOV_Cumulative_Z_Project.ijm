macro "OSOV Cumulative Z Project" {

    var originalStack = getImageID()
    var nOriginalStackSlices = nSlices;

    run("Duplicate...", "duplicate");

    var outputStack = getImageID();
    
    for (n=2; n <= nOriginalStackSlices; n++) {
        copySlice(outputStack, n-1);
        pasteSlice(outputStack, n);

        copySlice(originalStack, n);
        pasteSlice(outputStack, n);
    }
}

function copySlice(stack, slice) {
    selectImage(outputStack);
    setSlice(slice);
    run("Select All");
    run("Copy");
}

function pasteSlice(stack, slice) {
    selectImage(stack);
    setSlice(slice);
    setPasteMode("Transparent-zero");
    run("Paste");
}