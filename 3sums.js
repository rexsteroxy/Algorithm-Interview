/**
 * @param {number[]} nums
 * @return {number[][]}
 */
var threeSum = function(nums) {
    
    // sort the array of nums
   nums.sort((a, b) => a - b);

  //initialize array output
  let output = [];

  // create looping array length

  for (let i = 0; i < nums.length - 1; i++) {
    if (nums[i] > 0 || nums[nums.length] < 0) {
     break;
    }

    if (i > 0  &&  nums[i] === nums[i - 1]) {
      continue;
    }

    let leftPointer = i + 1;
    let rightPointer = nums.length - 1;


    while (leftPointer < rightPointer) {
      let sum = nums[i] + nums[leftPointer] + nums[rightPointer];

      if (sum > 0) {
        rightPointer -= 1;
      } else if (sum < 0) {
        leftPointer += 1;
      } else{
        output.push([nums[i], nums[leftPointer], nums[rightPointer]]);


        while (
          leftPointer < rightPointer &&
          nums[leftPointer] === nums[leftPointer + 1]
        ) {
          leftPointer += 1;
        }


        while (
          leftPointer < rightPointer &&
          nums[rightPointer] === nums[rightPointer - 1]
        ) {
            rightPointer -= 1;
        }
        leftPointer += 1;
        rightPointer -= 1;
      }
    }
  }
  return output;
    
};