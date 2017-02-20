// This script processes all the images in a folder and any subfolders.

importClass(Packages.ij.IJ);
importClass(Packages.ij.ImageStack);
importClass(Packages.ij.ImagePlus);
importClass(Packages.ij.plugin.ImageCalculator);
importClass(Packages.java.io.File);
importClass(Packages.ij.io.FileSaver);

extension = ".tif";
inputDir = IJ.getDir("Choose Source DirectoryxX ");
outputDir = IJ.getDir("Choose Destination Directory ");
// inputDir = 'C:\\Data\\Trans_euc\\Scanner_1\\Leaf_8bit\\Trans\\1200\\'
// outputDir = 'C:\\Data\\Trans_euc\\Scanner_1\\Leaf_8bit\\Trans\\1200\\Diff\\'

f = new File(inputDir);
ic = new ImageCalculator();
diffStack = null; // we'll create it using the first image dimensions

list = f.list();

var listLength = list.length
var step = 3
// var listLength = 6;

for (i=0; i < (listLength - step); i=i+step) {
  if (list[i].endsWith(extension))
    if (!diffStack) {
      firstImage = IJ.openImage(inputDir + list[i]);
      diffStack = new ImageStack(firstImage.getWidth(), firstImage.getHeight());
    }
   imageDiff(inputDir + list[i + 1], inputDir + list[i], outputDir + list[i]);
}

ipDiffStack = new ImagePlus("Image difference", diffStack)
ipDiffStack.show();

outFile = new FileSaver(ipDiffStack);
// outFile.saveAsTiff(outputDir + "/diff.tiff");

function imageDiff(imageOne, imageTwo, diffFile) {
  print(imageOne + ":" + imageTwo + ":" + diffFile + "\n");
  imp1 = IJ.openImage(imageOne);
  imp2 = IJ.openImage(imageTwo);
  imp3 = ic.run("Subtract 32-bit create", imp1, imp2);
  //imp3.show();
  //imp3.show();
  diffStack.addSlice(imp3.getProcessor());
  //outFile = new FileSaver(imp3)
  //outFile.saveAsTiff(diffFile);
  imp1.close();
  imp2.close();
  imp3.close();
}
