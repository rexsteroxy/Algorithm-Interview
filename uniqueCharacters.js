function uniqueCharacter(s){
    if(s.length == 0){
        return -1
    }
    
    let storage = new Map();
    
    for(let i=0; i<s.length; i++){
        let ele = s[i];
        
        if(storage[ele]){
            storage[ele] += 1;
        }else{
            storage[ele] = 1;
        }
        
    }
    
     for(let i=0; i< s.length; i++){
        let ele = s[i];
        
        if(storage[ele] == 1){
            return i;
        }
        
    }
    
         return -1;
    
    
}

console.log(uniqueCharacter("leetcodel"));