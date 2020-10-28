/**
 * @param {number[]} nums
 * @return {void} Do not return anything, modify nums in-place instead.
 * Input: [0,1,0,3,12]
Output: [1,3,12,0,0]
 */
var moveZeroes = function(nums) {
    let holdPointer = 0;

    for (let pointer = 0; pointer < nums.length; i++) {
       
        if (nums[pointer] !== 0) {
            // swap pointers
            let temp = nums[holdPointer];
            nums[holdPointer] = nums[pointer];
            nums[pointer] = temp;

            holdPointer ++
        }
        
    }
    return nums

};