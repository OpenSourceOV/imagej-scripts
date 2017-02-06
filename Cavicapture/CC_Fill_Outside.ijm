macro "CC Fill Outside" {
  run("Make Inverse");
  run("Fill", "slice");
  run("Select None");
}
