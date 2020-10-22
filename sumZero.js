function sumZero(sortedArray) {
    // sort the arrays
    // let sortedArray = arrayOfNumbers.sort();
    console.log(sortedArray);
    let result = [];
    //loop through the sorted array
    for (let i = 0; i < sortedArray.length; i++) {
      // add the first and second index in the array counter
      if (sortedArray[i] + sortedArray[i + 1] === 0) {
        //if the sum is equal to zero push them to a new arrays
        result.push(sortedArray[i]);
        result.push(sortedArray[i + 1]);
      }else{
        console.log('hello');
      }
    }
    //return new array
  
    return result;
  }
  
  console.log(sumZero([-4,4,5,6,-6,8,9,-9]))