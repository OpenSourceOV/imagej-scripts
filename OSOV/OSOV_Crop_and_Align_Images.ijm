macro "OSOV Crop and Align Images" {

	//======Crop and align a sequence of images one by one (rather than in a huge image stack)
	//======Script by Markus Nolf, m.nolf@westernsydney.edu.au, https://bitbucket.org/ponycopter/leafsubtract
	//======Image alignment requires plugin: https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin

	dir = getDirectory("Choose Source Directory");	
	list = getFileList(dir);
	nfiles = list.length;
	
	dir2 = getDirectory("Choose Output directory");
	
	Dialog.create("Please confirm...");
	Dialog.addMessage(nfiles+" files found.");
	Dialog.addCheckbox("crop?",true);
	Dialog.addCheckbox("auto-align?*",true);
	Dialog.addCheckbox("8-bit output?",false);
	Dialog.addMessage("\n* alignment requires additional plugin:\n   \"Template Matching and Slice Alignment\" \n   http://bit.ly/2vENvxu\n   click the \"Help\" button to open plugin website.");
	Dialog.addHelp("https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin");
	Dialog.show();

	docrop = Dialog.getCheckbox();
	doalign = Dialog.getCheckbox();
	doeightbit = Dialog.getCheckbox();		

	//Clean up: close all open ImageJ windows	
	print("...");
	run("Close All");
	IJ.deleteRows(0, 99999);
	selectWindow("Log");
	run("Close");
	setResult(0,0,1);
	selectWindow("Results");
	run("Close");

	
	//Set timestamp for output of log files
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	function filler(j) {
		if(j<10) { string="0" + toString(j,0); } else { string="" + toString(j,0); }
		return string;
	}
	tmpyear = substring(year,2,4); tmpmonth = filler(month+1);tmpday = filler(dayOfMonth);tmphour = filler(hour);tmpminute = filler(minute);tmpsecond = filler(second);
	tmptimestamp = tmpyear+tmpmonth+tmpday+"-"+tmphour+tmpminute+tmpsecond;

	//Get template file (for user input) from the middle of the image sequence
	z=round(nfiles/2);
	templatefile = list[z];
	while(!endsWith(templatefile,".jpg") & !endsWith(templatefile,".tif") & !endsWith(templatefile,".png")) {
		z=z+1;
		templatefile = list[z];
	}

	//Log output
	print("input dir: "+dir);
	print("output dir: "+dir2);

	print("first image: "+list[0]);
	print("last image: "+list[(nfiles-1)]);
	print("number of files: "+nfiles);
	print("\n");	
		
	if(docrop==1) { 
		print("crop: yes\n");
	} else {
			print("crop: no\n");
	}
	if(docrop==1) {
		open(dir+File.separator+templatefile);
		setTool("rectangle");
		waitForUser("Select CROP area","Please select region of interest for cropping.");

		roiType = selectionType();
		getSelectionBounds(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);

		//fix for: when user selects full width in templatefile, but image dimensions in next images may be smaller dimension (scanner problem)
		ImageWidth = getWidth(); 
		ImageHeight = getHeight();
		if(cropSelectionX<=10) {
			cropSelectionX = 10;
			print("adjusting ROI:x to 10");
		}
		if(cropSelectionX+cropSelectionWidth>=ImageWidth-10) {
			cropSelectionWidth=ImageWidth-cropSelectionX-10;
			print("adjusting ROI:width to image-width minus 10");
		}
		if(cropSelectionY<=10) {
			cropSelectionY = 10;
			print("adjusting ROI:y to 10");
		}
		if(cropSelectionY+cropSelectionHeight>=ImageHeight-10) {
			cropSelectionHeight=ImageHeight-cropSelectionY-10;
			print("adjusting ROI:height to image-height minus 10");
		}
		makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
		run("Crop");
	}
	if(docrop!=1) {
		print("   setting crop area to full image dimensions.");
		open(dir+File.separator+templatefile);
		cropSelectionX = 0;
		cropSelectionY = 0;
		cropSelectionWidth=getWidth();
		cropSelectionHeight=getHeight();
		run("Close");		
	}
	
	if(doalign==1) {
		if(docrop!=1) {		
			open(dir+File.separator+templatefile);
		}
		autoalignx1 = round(cropSelectionWidth/2-cropSelectionWidth/5);
		autoaligny1 = round(cropSelectionHeight/2-cropSelectionHeight/5);
		autoalignw = round(cropSelectionWidth/5*2);
		autoalignh = round(cropSelectionHeight/5*2);
		makeRectangle(autoalignx1, autoaligny1, autoalignw, autoalignh);
		setTool("rectangle");
		waitForUser("Select ROI","Please select region of interest for image alignment.");

		roiType = selectionType();
		getSelectionBounds(roiSelectionX, roiSelectionY, roiSelectionWidth, roiSelectionHeight);

		//if roiSelection is biger than cropSelection, auto-align will fail. in this case, reduce roi boundary here: 
		if(roiSelectionWidth-cropSelectionWidth>20) { roiSelectionWidth = cropSelectionWidth-20; }
		if(roiSelectionHeight-cropSelectionHeight>20) { roiSelectionHeight = cropSelectionHeight-20; }

		run("Set Measurements...", "decimal=9");
	}

	print("   x: "+cropSelectionX+"\n   width: "+cropSelectionWidth+"\n   y: "+cropSelectionY+"\n   height: "+cropSelectionHeight+"\n ");
	if(doalign==1) {
		print("auto-align: yes \n");
		print("   x: "+roiSelectionX+"\n   width: "+roiSelectionWidth+"\n   y: "+roiSelectionY+"\n   height: "+roiSelectionHeight+"\n ");
	} else {
		print("auto-align: no\n");
	}

	if(doeightbit==1) {
		print("8-bit output: yes\n");
	} else {
		print("8-bit output: no\n");
	}

	if(docrop+doalign>0) {	run("Close"); }
	print("\n");

	//Save settings to file, in case of errors or user aborting
	selectWindow("Log");  
	logfilename=dir2+"00-log-"+tmptimestamp+".txt";
	saveAs("Text", logfilename); 	
	
	//Process images
	setBatchMode(true);
	if (docrop+doalign+doeightbit>0) {
		setBatchMode(true);
		print("\n Processing images now. \n");
		for (i=0; i<(nfiles); i++) {
			showProgress(i+1, nfiles);
			j = i+1;
			currentfile = list[i];
	
			if(endsWith(list[i],".jpg") | endsWith(list[i],".tif") | endsWith(list[i],".png")) {
				print("\n"+j+" / "+(nfiles)+": processing "+currentfile);

				//If auto-align is on: Get x- and y-shift between template file and the two cropped images
				if(doalign==1){
					//Pre-crop template file
					open(dir+templatefile);
					if(docrop==1) {
						makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
						run("Crop");
					}				
					
					//Pre-crop current image
					open(dir+currentfile);
					if(docrop==1) {
						makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
						run("Crop");
					}			

					//Align pre-cropped template and current images to get x- and y-shift
					print("  aligning...");
					run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
					run("8-bit"); 
					setBackgroundColor(122,122,122);
					run("Align slices in stack...", "method=5 windowsizex="+roiSelectionWidth+" windowsizey="+roiSelectionHeight+" x0="+roiSelectionX+" y0="+ roiSelectionY+" swindow=20 subpixel=true itpmethod=1 ref.slice=1 show=TRUE");
					xshift = getResult("dX",0); 
					yshift = getResult("dY",0); 
					selectWindow("Stack");
					run("Close");
	
				}
	
				//Reopen the original current image, first align and then crop.
				open(dir+currentfile);
				filename1 = replace(currentfile,".jpg","");
				filename1 = replace(filename1,".tif","");
				filename1 = replace(filename1,".png","");
				rename(filename1);
				if(doalign==1) { 
					setBackgroundColor(122, 122, 122);
					run("Translate...", "x="+xshift+" y="+yshift+" interpolation=Bilinear");
				}
				if(docrop==1) {
					print("  cropping...");
					makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
					run("Crop");
				}

				//Modify output filename depending on the processing steps chosen.
				selectWindow(filename1);
				outputname = filename1;
				if(docrop==1) { outputname = outputname+"-crop"; }
				if(doalign==1) { outputname = outputname+"-align"; }
				if(doeightbit==1) { outputname = outputname+"-8bit"; }
				rename(outputname);
				finalname=dir2+outputname;
	
				//If selected, convert image to 8-bit (reduces file size) 
				if(doeightbit==1) {
					print("  converting to 8-bit...");
					run("8-bit");
				}
				print("  saving...");
				saveAs("Tiff", finalname);
				run("Close All");
			} else { //End of if endswith .jpg
				print(j+": skipping "+currentfile);
			}
		} //End of for-loop
		
		//Clean up: close all windows (open them first if they're not open) 
		open(dir+templatefile);
		run("Measure");		
		run("Close");
		selectWindow("Results");
		run("Close");
		
		//update log-file after completion of macro
		print("\n All done.");
		selectWindow("Log");
		logfilename=dir2+"00-log-"+tmptimestamp+".txt";
		saveAs("Text", logfilename); 
	} //end if(docrop+doalign>0)
	
	setBatchMode(false);

} //end of macro
