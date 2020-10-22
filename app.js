// function checknumber(num) {
//   if (num % 2 == 0) {
//     return true;
//   } else {
//     return false;
//   }
// }

// function charCount(str){
//  let result = {};

//  for (let i = 0; i < str.length; i++) {

//      const char = str[i];

//      if (result[char] > 0) {
//          console.log(result[char])
//          result[char]++;
//      } else {
//          result[char] = 1;
//      }

//  }

//     console.log(result);
// }

// //charCount("helllo");

// let me = {
//     a:"meem",
//     b:5
// }
// console.log(me["a"])

// function compare(arr1, sqrArr) {
//   let result;
//   let count = 0;

//   for (let i = 0; i < arr1.length; i++) {
//     result = sqrArr.includes(arr1[i] * arr1[i]);
//     if (result) {
//       count++;
//     }
//   }
//   if (count == sqrArr.length) {
//     result = true;
//   } else {
//     result = false;
//   }

//   console.log(result);
// }

// compare([1, 3, 5, 6], [25, 1, 9, 36]);

// using frequency counter to implement Anagrams

function anagram(word1, word2){

  if (word1.length !== word2.length) {
     return false;
  }
  console.log("hello");

  let lookup = {};

  for (let i = 0; i < word1.length; i++) {
    const element = word1[i];
    if (lookup[element]) {
      lookup[element] += 1;
    } else {
      lookup[element] = 1
    }
  }
console.log(lookup);

  for (let index = 0; index < word2.length; index++) {

    if(!lookup[word2[index]]){
      console.log(lookup);
      return false;
    }else{
      lookup[word2[index]] -= 1;
      console.log(lookup);
    }

  }

  return true;

}

console.log(anagram('anagram','nagaram'));

//function that will take in array of unsorted numbers return two pair number if the sum is zero

// function sumZero(sortedArray) {
//   // sort the arrays
//   // let sortedArray = arrayOfNumbers.sort();
//   console.log(sortedArray);
//   let result = [];
//   //loop through the sorted array
//   for (let i = 0; i < sortedArray.length; i++) {
//     // add the first and second index in the array counter
//     if (sortedArray[i] + sortedArray[i + 1] === 0) {
//       //if the sum is equal to zero push them to a new arrays
//       result.push(sortedArray[i]);
//       result.push(sortedArray[i + 1]);
//     }else{
//       console.log('hello');
//     }
//   }
//   //return new array

//   return result;
// }

// console.log(sumZero([-4,4,5,6,-6,8,9,-9]))

// function subSumarray

//sliding window function

// function subSumarray(sortedArray, num) {
//   console.log(sortedArray.sort((a,b)=> a - b ))
//   if (num > sortedArray.length) {
//     return null;
//   }
// let maxNumber = -Infinity;
//   for (let i = 0; i < sortedArray.length - num + 1; i++) {
//    let temp = 0;
//    for (let j = 0; j < num; j++) {
//      console.log(`${sortedArray[i]} + ${sortedArray[j]}`)
//     temp += sortedArray[i + j]
//    }
//    if (temp > maxNumber) {
//      maxNumber = temp;
//    }
//   }
//   console.log(maxNumber)
//   console.log(sortedArray.length - num + 1);

// }
// subSumarray([8,12,3,4,5,6,9,7,8],3)

// var twoSum = function (nums, target) {
//   let output = [];

//   for (let i = 0; i < nums.length; i++) {
//     for (let j = i + 1; j < nums.length; j++) {
//         if (nums[j] == target - nums[i]) {
//             output.push(i,j);
//         }
//     }
// }
// console.log(output);
  
// };

// twoSum([1, 3, 15, 6, 5, 8], 8);





// var twoSum = function(nums, target) {
//   let storage = new Map;
//   for (var i = 0; i < nums.length; i++) {
//       let complement = target - nums[i];
//       if (storage.has(complement)) {
//           return [storage.get(complement), i]
//       }
//       storage.set(nums[i], i);

      
//   }
// }

// console.log(twoSum([1, 3, 5, 6, 5, 8], 11));





var lengthOfLongestSubstring = function(s) {
    
};

















































