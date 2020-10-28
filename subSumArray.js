//sliding window function

function subSumarray(nums, k) {
  //console.log(nums.sort((a, b) => a - b));
  if (k > nums.length) {
    return null;
  }
  let maxkber = -Infinity;
  for (let i = 0; i < nums.length - k + 1; i++) {
    let temp = 0;
    for (let j = 0; j < k; j++) {
     // console.log(`${nums[i]} + ${nums[j]}`);
      temp += nums[i + j];
    }
    if (temp > maxkber) {
      maxkber = temp;
    }
  }
  return maxkber;
  //console.log(nums.length - k + 1);
}
subSumarray([8, 12, 3, 4, 5, 6, 9, 7, 8], 3);
