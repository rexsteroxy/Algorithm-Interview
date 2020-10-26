// input = a#bc#data

// output = bd

function backspace(string) {
  let stringToArray = string.split("");
  for (let i = 0; i < stringToArray.length; i++) {
    if (stringToArray[i + 1] == "#") {
      delete stringToArray[i];
      delete stringToArray[i + 1];
    }
  }
  console.log(stringToArray.join(""));
}

backspace("########");
