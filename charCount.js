function charCount(str){
 let result = {};

 for (let i = 0; i < str.length; i++) {

     const char = str[i];

     if (result[char] > 0) {
         console.log(result[char])
         result[char]++;
     } else {
         result[char] = 1;
     }

 }

    console.log(result);
}
charCount("helllo");