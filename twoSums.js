var twoSum = function (nums, target) {
  let output = [];

  for (let i = 0; i < nums.length; i++) {
    for (let j = i + 1; j < nums.length; j++) {
        if (nums[j] == target - nums[i]) {
            output.push(i,j);
        }
    }
}
console.log(output);
  
};

twoSum([1, 3, 15, 6, 5, 8], 8);


var twoSum2 = function(nums, target) {
  let storage = new Map;
  for (var i = 0; i < nums.length; i++) {
      let complement = target - nums[i];
      if (storage.has(complement)) {
          return [storage.get(complement), i]
      }
      storage.set(nums[i], i);

      
  }
}

console.log(twoSum2([1, 3, 5, 6, 5, 8], 11));



