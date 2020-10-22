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