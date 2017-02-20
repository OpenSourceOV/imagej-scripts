macro "OSOV Clear Slice" {
  run("Select All");
  setForegroundColor(255, 255, 255);
  run("Fill", "slice");
  run("Select None");
}
