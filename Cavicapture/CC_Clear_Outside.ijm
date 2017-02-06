macro "CC Clear Outside" {
  run("Make Inverse");
  setForegroundColor(255, 255, 255);
  run("Fill", "slice");
  run("Select None");
}
