//sliding window function

function subSumarray(sortedArray, num) {
  console.log(sortedArray.sort((a,b)=> a - b ))
  if (num > sortedArray.length) {
    return null;
  }
let maxNumber = -Infinity;
  for (let i = 0; i < sortedArray.length - num + 1; i++) {
   let temp = 0;
   for (let j = 0; j < num; j++) {
     console.log(`${sortedArray[i]} + ${sortedArray[j]}`)
    temp += sortedArray[i + j]
   }
   if (temp > maxNumber) {
     maxNumber = temp;
   }
  }
  console.log(maxNumber)
  console.log(sortedArray.length - num + 1);

}
subSumarray([8,12,3,4,5,6,9,7,8],3)