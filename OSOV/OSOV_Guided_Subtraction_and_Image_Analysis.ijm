macro "OSOV Guided Subtraction and Image Analysis" {

//====== Import and subtract a sequence of images
//====== Script by Markus Nolf, m.nolf@westernsydney.edu.au, 
//====== original script at https://bitbucket.org/ponycopter/leafsubtract (moved to OSOV)
//====== uses this plugin: https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin

	Dialog.create("LeafSubtract");
	Dialog.addMessage("What would you like to do?");
	tmpactions = newArray("Process images","Analyse subtractions");
	Dialog.addChoice("Action",tmpactions,"Process images");
	Dialog.show();

	dowhat = Dialog.getChoice();
	
	
	dir = getDirectory("Choose Source Directory");	
	
	list = getFileList(dir);
	nfiles = list.length;
	
	if(dowhat=="Process images") {
		dir2 = getDirectory("Choose Output directory");
	} else {
		dir2 = dir;
	}
	
	Dialog.create("Please confirm...");
	Dialog.addMessage(nfiles+" files found.");
	
	if(dowhat=="Process images") {
		//Dialog.addCheckbox("auto create output folder?",true); 
		Dialog.addCheckbox("auto-crop?",true);
		Dialog.addCheckbox("auto-align?*",true);
		Dialog.addCheckbox("subtract images?",true);
		Dialog.addCheckbox("  subtract all at once (image stack)?",false);
		Dialog.addCheckbox("  auto-level (deflicker)?",true);
		Dialog.addCheckbox("save video clip?",false);

		Dialog.addMessage("reduce computer workload:");
		Dialog.addCheckbox("downscale output?",false);
		Dialog.addCheckbox("8-bit import?",true);
		Dialog.addCheckbox("8-bit output?",false);
		Dialog.addMessage("\n* alignment requires additional plugin:\n   \"Template Matching and Slice Alignment\" \n   http://bit.ly/2vENvxu\n   click the \"Help\" button to open plugin website.");
		Dialog.addHelp("https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin");

	}
	if(dowhat=="Analyse subtractions") {
		Dialog.addCheckbox("image analysis?",true);
		Dialog.addCheckbox("  skip to pre-threshold stack?",false);
		Dialog.addCheckbox("    save new pre-threshold edits?",true);
		Dialog.addCheckbox("  limit to embolism phase?",true);
		Dialog.addCheckbox("8-bit import?",false);
		Dialog.addCheckbox("8-bit output?",false);
	}

		
	Dialog.show();

	if(dowhat=="Process images") {
		docrop = Dialog.getCheckbox();
		doalign = Dialog.getCheckbox();
		dosubtract = Dialog.getCheckbox();
		doallatonce = Dialog.getCheckbox();
		doautolevel = Dialog.getCheckbox();
		domakeclip = Dialog.getCheckbox();
		dodownscaleoutput = Dialog.getCheckbox();
		doeightbitimport = Dialog.getCheckbox();		
		doeightbit = Dialog.getCheckbox();		
		doanalyze = 0;
		doskiptoprethresh = 0;
		dolimitanalysis = 0;
		dooverwriteprethresh = 1;
	}
	if(dowhat=="Analyse subtractions") {
		doanalyze = Dialog.getCheckbox();
		doskiptoprethresh = Dialog.getCheckbox();
		dooverwriteprethresh = Dialog.getCheckbox();
		dolimitanalysis = Dialog.getCheckbox();
		doallatonce = 0;
		docrop = 0;
		doalign = 0;
		dosubtract = 0;
		doautolevel = 0;
		domakeclip = 0;
		dodownscaleoutput = 0;
		doeightbitimport = Dialog.getCheckbox();		
		doeightbit = Dialog.getCheckbox();		
		if(doskiptoprethresh==0) { dooverwriteprethresh = 1; print("not skipping to pre-thresholded images >> forcing pre-threshold images to be saved/overwritten."); }
	}

	//if(docreatefolder==1) {
		//dir2 = "output "+dir; //do when there's enough time sometime: automatically create folder "output [source directory name]"
		//File.makeDirectory(dir2);
	//} else {
		//dir2 = getDirectory("Choose Output directory"); //double: remove lines 20-22 if this is part activated
	//}

	//clean up: close all windows	
	print("...");
	run("Close All");
	IJ.deleteRows(0, 99999);
	selectWindow("Log");
	run("Close");
	setResult(0,0,1);
	selectWindow("Results");
	run("Close");

	//set timestamp for output of log files
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	function filler(j) {
		if(j<10) { string="0" + toString(j,0); } else { string="" + toString(j,0); }
		return string;
	}
	tmpyear = substring(year,2,4); tmpmonth = filler(month+1);tmpday = filler(dayOfMonth);tmphour = filler(hour);tmpminute = filler(minute);tmpsecond = filler(second);
	tmptimestamp = tmpyear+tmpmonth+tmpday+"-"+tmphour+tmpminute+tmpsecond;
	//print(tmptimestamp);

	z=round(nfiles/2);
	templatefile = list[z];
	while(!endsWith(templatefile,".jpg") & !endsWith(templatefile,".tif") & !endsWith(templatefile,".png")) {
		z=z+1;
		templatefile = list[z];
	}

	print("input dir: "+dir);
	print("output dir: "+dir2);

	print("first image: "+list[0]);
	print("last image: "+list[(nfiles-1)]);
	print("number of files: "+nfiles);
	print("\n");	
		
	print("auto-crop: "+docrop+"\n");
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
	print("auto-align: "+doalign);
	if(doalign==1) {
		print("   x: "+roiSelectionX+"\n   width: "+roiSelectionWidth+"\n   y: "+roiSelectionY+"\n   height: "+roiSelectionHeight+"\n ");
	}
	if(docrop+doalign>0) {	run("Close"); }
	print("\n");
		
	print("subtract: "+dosubtract+"\n");
	if(doallatonce==0) { print("subtract: two-by-two");  }
	if(doallatonce==1) { print("subtract: all at once");  }	
	if(doallatonce==1) { print("  forcing subtract on due to \"all at once\" subraction"); dosubtract = 1;  }		
	if(doallatonce==1) { print("  forcing auto-level (deflicker) off due to \"all at once\" subraction"); doautolevel = 0;  }		
	print("auto-level (deflicker): "+doautolevel+"\n");
	print("create video: "+domakeclip+"\n");	
	print("auto-resize output: "+dodownscaleoutput+"\n");

	selectWindow("Log");  
	logfilename=dir2+"00-log-"+tmptimestamp+".txt";
	saveAs("Text", logfilename); 	
	
	setBatchMode(true);
	
	if(doautolevel==1) {
		print("\n loading extra images for advanced deflicker");
			extrafile = 50;
			if(nfiles>50) { extrafile = 50; } 
			if(nfiles<=50) { extrafile = nfiles/3; }
			print(extrafile);
			open(dir+list[extrafile]);
			rename("level1");
			makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
			run("Crop");

			run("Select All");
			getRawStatistics(nPixels, mean, leveldark1, levelbright1);
			print("  darkest value #"+extrafile+": "+leveldark1);
			print("  brightest value #"+extrafile+": "+levelbright1);

			if(nfiles>50) { extrafile = (nfiles-50); } 
			if(nfiles<=50) { extrafile = (nfiles-nfiles/3); }
			print(extrafile);
			open(dir+list[extrafile]);
			rename("level2");
			makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
			run("Crop");

			run("Select All");
			getRawStatistics(nPixels, mean, leveldark2, levelbright2);
			print("  darkest value #"+extrafile+": "+leveldark2);
			print("  brightest value #"+extrafile+": "+levelbright2);
			levelbright = maxOf(levelbright1,levelbright2);
			leveldark = minOf(leveldark1,leveldark2);
			print("  darkest value overall: "+leveldark);
			print("  brightest value overall: "+levelbright);
			
			selectWindow("level1"); 
			run("Close");
			selectWindow("level2"); 
			run("Close");
			setBatchMode(false);
	}
	if
(dosubtract+docrop+doalign>0) {
		if((dosubtract+docrop+doalign>0) & (doallatonce==0)) {
			setBatchMode(true);
			print("\n Processing images now. \n");
			for (i=0; i<(nfiles-1); i++) {
				showProgress(i+1, nfiles);
				j=i+1;
				firstfile = list[i];
				secondfile = list[j];
		
				if((endsWith(list[i],".jpg") & endsWith(list[j],".jpg")) | (endsWith(list[i],".tif") & endsWith(list[j],".tif")) | (endsWith(list[i],".png") & endsWith(list[j],".png"))) {
					print(j+" / "+(nfiles-1)+": processing "+secondfile+" and "+firstfile);
					open(dir+firstfile);
					filename1 = replace(firstfile,".jpg","");
					filename1 = replace(filename1,".tif","");
					rename(filename1);
					if(docrop==1) {
						makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
						run("Crop");
					}
				
					open(dir+secondfile);
					filename2 = replace(secondfile,".jpg","");
					filename2 = replace(filename2,".tif","");
					rename(filename2);
					if(docrop==1) {
						makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
						print("  cropping...");
						run("Crop");
					}			
	
					if(doalign==true){
						run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
						run("8-bit"); 
						print("  aligning slices...");
						setBackgroundColor(122,122,122);
						run("Align slices in stack...", "method=5 windowsizex="+roiSelectionWidth+" windowsizey="+roiSelectionHeight+" x0="+roiSelectionX+" y0="+ roiSelectionY+" swindow=20 subpixel=true itpmethod=1 ref.slice=1 show=TRUE");
						
						xshift = getResult("dX",0); 
						yshift = getResult("dY",0); 
						selectWindow("Stack");
						run("Close");
		
					}
					//the actual subtraction comes here
		
					open(dir+firstfile);
					rename(filename1);
					makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
					run("Crop");
		
					if(doautolevel==1) {
						print("  deflickering...");
						makeRectangle(0, 0, 10, 10);
						setBackgroundColor(levelbright, levelbright, levelbright);
						run("Clear", "slice");
						makeRectangle(0, 10, 10, 10);				
						setBackgroundColor(leveldark, leveldark, leveldark);
						run("Clear", "slice");
					}
				
					open(dir+secondfile);
					rename(filename2);
					if(doalign==1) { 
						setBackgroundColor(122, 122, 122);
						run("Translate...", "x="+xshift+" y="+yshift+" interpolation=Bilinear");
					}
					makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
					run("Crop");
		
					if(doautolevel==1) {
						makeRectangle(0, 0, 10, 10);
						setBackgroundColor(leveldark, leveldark, leveldark);
						run("Clear", "slice");
						makeRectangle(0, 10, 10, 10);				
						setBackgroundColor(levelbright, levelbright, levelbright);
						run("Clear", "slice");
					}
		
					if(dosubtract==1) {
						print("  subtracting images..."); 
						imageCalculator("Subtract create 32-bit", filename1,filename2);
						windowchooser="Result of "+filename1;
						selectWindow(windowchooser);
						outputname="s-"+j+"-"+filename2+"-"+firstfile;
					}
					if(dosubtract!=1) {
						windowchooser = filename2;
						selectWindow(windowchooser);
						if(docrop==1 && doalign!=1) { outputname = filename2+"-crop.jpg"; }
						if(docrop!=1 && doalign==1) { outputname = filename2+"-align.jpg"; }
						if(docrop==1 && doalign==1) { outputname = filename2+"-crop-align.jpg"; }
					}
					
					rename(outputname);
					finalname=dir2+outputname;
		
					if(dodownscaleoutput==1) {
						autoresize = 0;
						if(cropSelectionWidth*cropSelectionHeight>3000000) { resizefactor=0.5; autoresize = 1; }
						if(cropSelectionWidth*cropSelectionHeight>9000000) { resizefactor=0.33; autoresize = 1; }
						if(cropSelectionWidth*cropSelectionHeight>15000000) { resizefactor=0.25; autoresize = 1; }
						if(autoresize==1) {
							newwidth=round(cropSelectionWidth*resizefactor);
							newheight=round(cropSelectionHeight*resizefactor);
							run("Size...", "height="+newheight+" width="+newwidth+" constrain average interpolation=Bilinear");
						}
					}
					if(doeightbit==1) {
						run("8-bit");
					}
					saveAs("Tiff", finalname);
					run("Close All");
				} else { // end of if endswith .jpg
					print(j+": skipping "+secondfile+" - "+firstfile);
				}
			}
					
			setBatchMode(false);
		}
	
		if((dosubtract+docrop+doalign>0) & (doallatonce==1)) {
			setBatchMode(true);
			//debug here
			/* dosubtract=1;
			docrop=1;
			doalign=1;
			doallatonce=1;
			dir="c:\\mn\\tmp\\";
			firstfile="0124191254.jpg";
			cropSelectionX=600;
			cropSelectionY=600;
			cropSelectionWidth=3000;
			cropSelectionHeight=2500;
			roiSelectionX=1000;
			roiSelectionY=1000;
			roiSelectionWidth=700;
			roiSelectionHeight=700;
			*/

			firstfile = list[0];

			Dialog.create("Set image scaling (%)");
	    	Dialog.addMessage(nfiles+" files found.");		
			Dialog.addMessage("Set image scaling (0-100%)");
			Dialog.addNumber("%", 100)
			Dialog.show();
			loadresize = Dialog.getNumber();
			print("   image import: scaling images at "+loadresize+"%");
			if(loadresize!=100) {
				if(docrop==1) {
					cropSelectionX = floor(cropSelectionX * loadresize/100);
					cropSelectionY = floor(cropSelectionY * loadresize/100);
					cropSelectionWidth = floor(cropSelectionWidth * loadresize/100);
					cropSelectionHeight = floor(cropSelectionHeight * loadresize/100);
					print("   adjusting auto-crop values:\n   x: "+cropSelectionX+"\n   width: "+cropSelectionWidth+"\n   y: "+cropSelectionY+"\n   height: "+cropSelectionHeight+"\n ");
				}
				if(doalign==1) {
					roiSelectionX = floor(roiSelectionX * loadresize/100);
					roiSelectionY = floor(roiSelectionY * loadresize/100);
					roiSelectionWidth = floor(roiSelectionWidth * loadresize/100);
					roiSelectionHeight = floor(roiSelectionHeight * loadresize/100);
					print("   adjusting auto-align values:\n   x: "+roiSelectionX+"\n   width: "+roiSelectionWidth+"\n   y: "+roiSelectionY+"\n   height: "+roiSelectionHeight+"\n ");
				}
			}
				
			print("   reading image stack. this may take a while.");
			showProgress(10, 100);
			
			//clear memory before a big import
			run("Collect Garbage");

			if(doeightbitimport!=1) { 
				run("Image Sequence...", "open=["+dir+firstfile+"] increment=1 scale=[loadresize] sort");
			}
			if(doeightbitimport==1) {
				//run("8-bit");
				run("Image Sequence...", "open=["+dir+firstfile+"] increment=1 scale=[loadresize] convert sort"); 
			}

			showProgress(35, 100);
			rename("fullstack");
			if(docrop==1) {
				makeRectangle(cropSelectionX, cropSelectionY, cropSelectionWidth, cropSelectionHeight);
				print("  cropping...");
				run("Crop");
			}
	
			if(doalign==1) {
				setBatchMode(true);
				run("Make Substack...", "  slices=1-"+nSlices);
				rename("fullstackcopy");
				run("8-bit");
				print("  aligning slices...");
				setBackgroundColor(122,122,122);
				run("Align slices in stack...", "method=5 windowsizex="+roiSelectionWidth+" windowsizey="+roiSelectionHeight+" x0="+roiSelectionX+" y0="+ roiSelectionY+" swindow=20 subpixel=true itpmethod=1 ref.slice=1 show=TRUE");
				selectWindow("fullstackcopy");
				run("Close");
				selectWindow("fullstack");			
	
				setBackgroundColor(122, 122, 122);

				for (m=0; m<(nResults); m++) {
					sliceshift = getResult("Slice",m);
					setSlice(sliceshift);
					xshift = getResult("dX",m);
					yshift = getResult("dY",m);
					run("Translate...", "x="+xshift+" y="+yshift+" interpolation=Bilinear slice");
					print("  aligning slice "+sliceshift+" ("+xshift+", "+yshift+")");
				}
				setBatchMode(false);
			} //end if doalign==1
	
			setBatchMode(true);
			showProgress(50, 100);
			if(dosubtract==1) {
				setBatchMode(false);
				selectWindow("fullstack"); 
				run("Make Substack...", "  slices=1-"+(nSlices-1));
				rename("stack1");
				selectWindow("fullstack");
				run("Make Substack...", "  slices=2-"+(nSlices));
				rename("stack2");

				print("  subtracting images..."); 
				imageCalculator("Subtract create 32-bit stack", "stack1","stack2");
				selectWindow("Result of stack1");
				
				setBatchMode(true);
	
				if(dodownscaleoutput==1) {
					autoresize = 0;
					if(cropSelectionWidth*cropSelectionHeight>3000000) { resizefactor=0.5; autoresize = 1; }
					if(cropSelectionWidth*cropSelectionHeight>9000000) { resizefactor=0.33; autoresize = 1; }
					if(cropSelectionWidth*cropSelectionHeight>15000000) { resizefactor=0.25; autoresize = 1; }
					if(autoresize==1) {
						newwidth=round(cropSelectionWidth*resizefactor);
						newheight=round(cropSelectionHeight*resizefactor);
						run("Size...", "height="+newheight+" width="+newwidth+" constrain average interpolation=Bilinear");
					}
				}
				showProgress(75, 100);
				print("   saving processed files.");
				for(n=1; n<=nSlices; n++) {
					selectWindow("stack1");
					setSlice(n);
					firstfile=getInfo("slice.label");
					selectWindow("stack2");
					setSlice(n);
					filename2=getInfo("slice.label");
	
					selectWindow("Result of stack1");
					setSlice(n);
					run("Make Substack...", "  slices="+n);
					outputname="s-"+n+"-"+filename2+"-"+firstfile;
					finalname=dir2+outputname;
					if(doeightbit==1) {
						run("8-bit");
					}
					saveAs("Tiff", finalname);
					//selectWindow(outputname); 
					print("  img "+n+" saved.");
					run("Close");
				}
				showProgress(95, 100);
				
			}
			if(dosubtract!=1) {
	
				showProgress(75, 100);
				for(n=1; n<=nSlices; n++) {
					selectWindow("stack2"); 
					setSlice(n);
					filename2=getInfo("slice.label");
	
					run("Make Substack...", "  slices="+n);		
					if(docrop==1 && doalign!=1) { outputname = filename2+"-crop.jpg"; }
					if(docrop!=1 && doalign==1) { outputname = filename2+"-align.jpg"; }
					if(docrop==1 && doalign==1) { outputname = filename2+"-crop-align.jpg"; }
					finalname=dir2+outputname;
					if(doeightbit==1) {
						run("8-bit");
					}
					saveAs("Tiff", finalname);
					print("img "+n+" saved.");
					run("Close");
				}
				showProgress(95, 100);
	
			}
	
			selectWindow("stack1");
			run("Close");
			selectWindow("stack2");
			run("Close");			
			selectWindow("fullstack");
			run("Close");

			if(dosubtract==1) {
				print("\nDone. Leaving stack window open for checking.");
				selectWindow("Result of stack1");
			}

			
		}
	
		if(dosubtract+docrop+doalign+domakeclip>0) {
			setBatchMode(true);
			print("\n \n Image processing complete."); 
			showProgress(100, 100);
		}
		if(domakeclip==1) {
			print("\n Now creating avi clip.");
			newlist = getFileList(dir2);
			nnewfiles = newlist.length;
				z=0;
				newtemplatefile = newlist[0];
				while(!endsWith(newtemplatefile,".jpg") & !endsWith(newtemplatefile,".tif") & !endsWith(newtemplatefile,".png")) {
					z=z+1;
					newtemplatefile = newlist[z];
				}
				loadsequence = dir2+newtemplatefile;

				saveavi = dir2+"/video/0-videoclip.avi";
				
				//clear memory before a big import
				run("Collect Garbage");
				
				run("Image Sequence...", "open=[loadsequence] scale=50 sort use");
				run("Enhance Contrast...", "saturated=0.5 process_all use");
				newvidwidth=cropSelectionWidth*1080/cropSelectionWidth;
				run("Animation Options...", "speed=10");
				run("Size...", "height="+1080+" width="+newvidwidth+" constrain average interpolation=Bilinear");
				
				createdir = dir2+"/video"+File.separator;
				File.makeDirectory(createdir);
				
				run("AVI... ", "frame=5 save=[saveavi]");
				run("Close");
		}
	
		if(dosubtract+docrop+doalign+domakeclip>0) {
			selectWindow("Log");
			logfilename=dir2+"00-log1-"+tmptimestamp+".txt";
			saveAs("Text", logfilename); 
		}
	} //end if(dosubtract+docrop+doalign>0)
	
	setBatchMode(false);


	if(doanalyze==1) {
		print("\n \nStarting image analysis."); 

		newlist = getFileList(dir2);
		if(doskiptoprethresh==1) {
			dir3 = dir2+"/results/01-pre-threshold/";
			newlist = getFileList(dir3);	
			loadresize = 100;
		}	
		nnewfiles = newlist.length;


		if(doskiptoprethresh!=1) {
			Dialog.create("Set image scaling (%)");
	    	Dialog.addMessage(nfiles+" files found.");		
			Dialog.addMessage("Set image scaling (0-100%)");
			Dialog.addNumber("%", 50)
			Dialog.show();
		
			loadresize = Dialog.getNumber();
		}
		
		print(" Scaling images at "+loadresize+"%");
		print(" (Loading up to "+nnewfiles+" images, please be patient)."); 
			z=0;
			newtemplatefile = newlist[z];
			while(!endsWith(newtemplatefile,".jpg") & !endsWith(newtemplatefile,".tif")) {
				z=z+1;
				newtemplatefile = newlist[z];
			}
			if(doskiptoprethresh!=1) {
				loadsequence = dir2+newtemplatefile;
			}
			if(doskiptoprethresh==1) {
				loadsequence = dir3+newtemplatefile;
			}
			
			//clear memory before a big import
			run("Collect Garbage");
			
			run("Image Sequence...", "open=[loadsequence] increment=1 scale=[loadresize] sort"); 
			//add file=s-6 to only load specific files
			print(" (Stack loaded.)"); 

			//save slice names to first output file
			createdir = dir2+"/results"+File.separator;
			File.makeDirectory(createdir);
			stacklist = "";
			for(i=1; i<=nSlices; i++) { 
				setSlice(i);
				stacklist = stacklist +getInfo("slice.label")+ ";";
			}
			if(doskiptoprethresh!=1) {
				print("Saving list of slice names...");
				File.saveString(stacklist, createdir+"slicenames.txt");

				//mn160926 test: run median filter and convolve instead of repeated smoothing
				run("Median...", "radius=3 stack");
				run("Convolve...", "text1=[1 1 1 1 1 1 1\n1 2 2 2 2 2 1\n1 2 2 2 2 2 1\n1 2 2 2 2 2 1\n1 2 2 2 2 2 1\n1 2 2 2 2 2 1\n1 1 1 1 1 1 1\n] normalize stack");
				
				//run("Enhance Contrast...", "saturated=0.5 process_all use");
				waitForUser("Smooth and Enhance contrast","The image HAS BEEN PRE-SMOOTHED (median filter + convolve). \n If desired, press [CTRL][SHIFT][S] (repeat depending on image size) to smooth the image further.");
			}
			
			run("Window/Level...");
			waitForUser("Adjust Window/Level","Find a slice with minor embolism. Adjust Window/Level so that you can clearly see it. \nDON'T Apply. (This step is just for visual control)");
			
			// routine to manually draw embolism
			setForegroundColor(255, 255, 255);
			setBackgroundColor(0, 0, 0);
			//run("Colors...", "foreground=white background=black");
			setTool(19); 
			call("ij.Prefs.set", "startup.brush", 5);
			//brush size adjustment only works when adding this line to the Paintbrush Tool Macro in StartupMacros (but without the comment sign).
			waitForUser("Retrace embolism","If desired, use the white brush to retrace weak embolism signals.\nDouble-click the brush symbol to change brush width."); //\n[ALT] + draw for black colour. 
			

			
setThreshold(1, 255);
			run("Threshold...");
			waitForUser("Adjust Threshold","Adjust Threshold so that Embolism events are well selected. \nDON'T Apply.");
			

			//remove slices outside of when embolism happens
			if(dolimitanalysis==1) {

				/* NOT WORKING YET >> make sure thresholding values stay the same.
				print("finding brightest and darkest values in entire stack");
				for (i=1; i<=nSlices; i++) {
          			setSlice(i);
          			if(i==1) { getStatistics(nPixels, mean, prevdark, prevbright); }
          			getStatistics(nPixels, mean, leveldark2, levelbright2);
          			if(prevdark>leveldark2) { prevdark = leveldark2; }
          			if(prevbright<levelbright2) { prevbright = levelbright2; }
					//brightest = maximum(prevbright,levelbright2);
					//prevdark = darkest;
					//prevbright = brightest;
					print(prevdark+"  "+prevbright);
      			}				

				makeRectangle(0, 0, 10, 10);
				setBackgroundColor(prevbright, prevbright, prevbright);
				run("Clear", "slice");
				makeRectangle(0, 10, 10, 10);				
				setBackgroundColor(prevdark, prevdark, prevdark);
				run("Clear", "slice");
				*/
				
				
/* working, but manual selection by navigating to slices 
				print("Limiting analysis to slice range where embolism happens.");
				waitForUser("Limit Analysis to embolism phase - FIRST","Find the slice that shows your FIRST embolism signal\n(or just select the first slice in the stack).");
				firstembol = getSliceNumber();
				print("  first embolism in slice: "+firstembol);
				
				waitForUser("Limit Analysis to embolism phase - LAST","Find the slice that shows your LAST embolism signal\n(or just select the last slice in the stack).");
				lastembol = getSliceNumber();
				print("  last embolism in slice: "+lastembol);
*/

			Dialog.create("Limiting analysis to embolism phase.");
			Dialog.addMessage("Find the slices that show your FIRST and LAST embolism signal");
			Dialog.addNumber("First slice:", 1)
			Dialog.addNumber("Last slice:", nSlices)
			Dialog.show();
			firstembol = Dialog.getNumber();
			lastembol = Dialog.getNumber();

			print("  first embolism in slice: "+firstembol);
			print("  last embolism in slice: "+lastembol);
				
				//deactivated here, moved down 
				//todo instead: black out non-interesting slices? or write in big text to the limiting ones? or at least specify which range in "correct bad frames or sections".
				/*if(lastembol>firstembol) {
					 
					 
					print("  removing slices before/after embolism phase...");
				  	if(lastembol<nSlices()) {
						print("    removing slices "+(lastembol+1)+" to "+nSlices()+".");
						run("Slice Remover", "first="+(lastembol+1)+" last="+nSlices()+" increment=1");
					}
					if(firstembol>1) {
						print("    removing slices 1 to "+(firstembol-1)+".");
						run("Slice Remover", "first=1 last="+(firstembol-1)+" increment=1");
					}
					
				} else {
					waitForUser("Selection invalid","First and last embolism position not properly selected. \nAnalysis will be done on the entire stack.");
					print("  not removing any slices because of invalid slice selection");
				}
				*/
			}
			
			
			// routine to edit/delete bad slices
			setForegroundColor(0, 0, 0);
			setBackgroundColor(255, 255, 255);
			setTool(19); 
			call("ij.Prefs.set", "startup.brush", 50);
			//brush size adjustment only works when adding this line to the Paintbrush Tool Macro in StartupMacros (but without the comment sign).
			waitForUser("Check stack","Please go through the stack with your left- and right arrow keys \nand correct bad frames or sections using the brush. \nDouble-click the brush symbol to change brush width. \nAlternatively, press [CRTL][A], [CTRL][F], [CTRL][SHIFT][A] \nand use arrow keys to black-out entire frames.");
			
			setTool(8); 
			waitForUser("Select minimum particle size.","Find a slice with the smallest particle you want to include in analysis \nand select that particle (or draw a selection manually).");
			run("Set Measurements...", "area redirect=None decimal=3");
			run("Measure");
			minarea=getResult("Area");
			print("Minimum area: "+minarea+" px^2");

				if(minarea>5000) {
					waitForUser("Check minimum particle size.","OH OH! \nIt looks like you either didn't select anything or used a very large area. \nPlease double-check your selection, then press OK.");
					run("Set Measurements...", "area redirect=None decimal=3");
					run("Measure");
					minarea=getResult("Area");
					print("Minimum area corrected: "+minarea+" px^2");
				}

			
			run("Select None");
			
			if(doskiptoprethresh!=1) {
				createdir2 = dir2+"/results/01-pre-threshold"+File.separator;
				File.makeDirectory(createdir2);
			}

			if(dooverwriteprethresh==1) {
				run("Image Sequence... ", "format=TIFF use save=["+createdir+"\\pre-threshold\\stack.tif]");
			}
			
			if(dolimitanalysis==1) {
				if(lastembol>firstembol) {
					 
					run("Threshold...");
					waitForUser("Adjust Threshold","Double-check threshold, then APPLY. \nUncheck \"set background pixels to NaN\", process entire stack.");
					 
					print("  removing slices before/after embolism phase...");
				  	if(lastembol<nSlices()) {
						print("    removing slices "+(lastembol+1)+" to "+nSlices()+".");
						run("Slice Remover", "first="+(lastembol+1)+" last="+nSlices()+" increment=1");
					}
					if(firstembol>1) {
						print("    removing slices 1 to "+(firstembol-1)+".");
						run("Slice Remover", "first=1 last="+(firstembol-1)+" increment=1");
					}
					
				} else {
					waitForUser("Selection invalid","First and last embolism position not properly selected. \nAnalysis will be done on the entire stack.");
					print("  not removing any slices because of invalid slice selection");
				}
			}

			origwindow = getTitle();
			
			run("Analyze Particles...", "size="+minarea+"-Infinity circularity=0.00-0.5 show=Masks clear include stack");
			stackwindow = getTitle();
			selectWindow(origwindow);
			close();			
			
			selectWindow(stackwindow);
			createdir2 = dir2+"/results/02-post-analyzeparticles"+File.separator;
			File.makeDirectory(createdir2);
			run("Image Sequence... ", "format=TIFF use save=["+createdir+"\\post-analyzeparticles\\stack.tif]");
			
			run("Z Project...", "projection=[Max Intensity]");
			saveAs("Tiff", createdir+"/zstack.tif");			
			setTool("freehand");
			//run("In [+]");
			roiManager("Reset");
			
			waitForUser("Select relevant leaf area","Select relevant leaf area. \nHold shift-key to select multiple areas. \nMake sure at least 1 px is not selected!");
			roiManager("Add"); 
			roiManager("Select", 0);
			roiManager("Rename", "entireleaf");
			run("Add Selection...", "stroke=#00aa00 width=5");

			run("Select None");
			waitForUser("Select first-order vein(s)","Select first-order vein(s). \nHold shift-key to select multiple areas.");
			roiManager("Add"); 
			
			roiManager("Select", 1);
			roiManager("Rename", "1st order");
			run("Add Selection...", "stroke=#990000 fill=#66990000 width=10");
		
			run("Select None");
			waitForUser("Select second-order veins","Select second-order veins. \nHold shift-key to select multiple areas.");
			roiManager("Add"); 
			roiManager("Select", 2);
			roiManager("Rename", "2nd order");
			run("Add Selection...", "stroke=#ff0000 fill=#66ff0000 width=10");

			run("Select None");

			//automatic attempt: subtract first and second order ROIs from entireleaf ROI
			roiManager("Select", 0);
			run("Make Inverse");
			roiManager("Add");
			roiManager("Select", 3);
			roiManager("Rename", "inverse-of-entireleaf");

			roiManager("Select", newArray(1,2));
			roiManager("Combine");
			roiManager("Add");
			roiManager("Select", 4);
			roiManager("Rename", "combined-firstandsecond");
			roiManager("Select", newArray(3,4));
			roiManager("Combine");
			run("Make Inverse");
			waitForUser("Confirm third-order veins","Confirm third-order veins. \nHold alt-key to remove from suggested selection.");
			//end automatic
			//waitForUser("Select third-order veins","Select third-order veins. \nHold shift-key to select multiple areas");

			roiManager("Add"); 
			roiManager("Select", 5);
			roiManager("Rename", "3rd order");
			
			//automatic 
			roiManager("Select", newArray(3,4));
			roiManager("Delete");
			roiManager("Select", 3);
			//end automatic
			
			run("Add Selection...", "stroke=#ff9900 fill=#66ff9900 width=10");

			run("Select None");
			run("Flatten");
			saveAs("Tiff", createdir+"/ordervenation-roi.tif");
			close();
			roiManager("Save", createdir+"/ordervenation-roi.zip");

			selectWindow(stackwindow);
			saveresults = createdir+"/output-0entireleaf.txt";
			roiManager("Select", 0);
			setThreshold(255, 255);
			run("Analyze Particles...", "  circularity=0.00-0.50 show=Masks clear include summarize stack");
			rename("mask-0allcombined");
			//close();
			summarytitle = "Summary of "+stackwindow;
			selectWindow(summarytitle);
			saveAs("Results", saveresults);
			
			selectWindow(stackwindow);
			saveresults = createdir+"/output-1storder.txt";
			roiManager("Select", 1);
			setThreshold(255, 255);
			run("Analyze Particles...", "  circularity=0.00-0.50 show=Masks clear include summarize stack");
			rename("mask-1storder");
			//close();
			summarytitle = "Summary of "+stackwindow;
			selectWindow(summarytitle);
			saveAs("Results", saveresults);
			
			selectWindow(stackwindow);
			saveresults = createdir+"/output-2ndorder.txt";
			roiManager("Select", 2);
			setThreshold(255, 255);
			run("Analyze Particles...", "  circularity=0.00-0.50 show=Masks clear include summarize stack");
			rename("mask-2ndorder");
			//close();
			summarytitle = "Summary of "+stackwindow;
			selectWindow(summarytitle);
			saveAs("Results", saveresults);
			
			selectWindow(stackwindow);
			saveresults = createdir+"/output-3rdorder.txt";
			roiManager("Select", 3);
			setThreshold(255, 255);
			run("Analyze Particles...", "  circularity=0.00-0.50 show=Masks clear include summarize stack");
			rename("mask-3rdorder");			
			close();
			summarytitle = "Summary of "+stackwindow;
			selectWindow(summarytitle);
			saveAs("Results", saveresults);
	}

//close results window
setResult(0,0,1);
selectWindow("Results");
run("Close");


print("\n All done.");

if(doanalyze>0) {
	print("\n \n Image analysis complete."); 
	print("\n  Next, use imagingvulcurve.r in R to curve-fit generated output.");
	selectWindow("Log"); 
	logfilename=dir2+"00-log-"+tmptimestamp+".txt";
	saveAs("Text", logfilename); 
}


if(doanalyze>0) {
	Dialog.create("Done.");
	if(dosubtract+docrop+doalign+domakeclip>0) { Dialog.addMessage("Image analysis complete."); }
	if(doanalyze>0) { Dialog.addMessage("Image analysis complete."); }
	Dialog.addCheckbox("Close all windows?",true);
	Dialog.show();
	
	doclose = Dialog.getCheckbox();
	
	if(doclose==1) {
		for(i=0;i<=6;i++) {
	 		run("Close");
	 	}
	 	selectWindow("output-0entireleaf.txt"); 
	 	run("Close");
	 	selectWindow("output-1storder.txt"); 
	 	run("Close");
	 	selectWindow("output-2ndorder.txt");
	 	run("Close");
	 	//selectWindow("output-3rdorder.txt");
	 	//run("Close");
	 	setResult(0,0,1);
	 	selectWindow("Results");
	 	run("Close");
	}
}


} //end of macro
