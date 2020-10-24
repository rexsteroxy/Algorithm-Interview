function lengthOfLongestSubString(s){
    let set = new Set();
    let rightPointer = 0;
    let leftPointer = 0;
    let maxSubStringLength = 0;

    while (rightPointer < s.length) {
        if(!set.has(s.charAt(rightPointer))) {

            set.add(s.charAt(rightPointer));
           
            maxSubStringLength = Math.max(maxSubStringLength, set.size);
            rightPointer++;
            
        }else{
            set.delete(s.charAt(leftPointer));
            leftPointer++;

        }
    }

    console.log(maxSubStringLength)
}


lengthOfLongestSubString("abcduthddecf");

