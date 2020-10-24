function compare(arr1, sqrArr) {
  let result;
  let count = 0;

  for (let i = 0; i < arr1.length; i++) {
    result = sqrArr.includes(arr1[i] * arr1[i]);
    if (result) {
      count++;
    }
  }
  if (count == sqrArr.length) {
    result = true;
  } else {
    result = false;
  }

  console.log(result);
}

compare([1, 3, 5, 6], [25, 1, 9, 36]);
