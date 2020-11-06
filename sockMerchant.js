function sockMerchant(n, ar) {
    if (n !== ar.length) {
      return 0;
    }
  
    let sockLookUp = {};
    let sockMarchCount = 0;
    
  
    for (let i = 0; i < ar.length; i++) {
        let ele = ar[i];
  
        if (sockLookUp[ele]) {
            sockLookUp[ele] += 1;
        }else{
            sockLookUp[ele] = 1;
        }
        
        if (sockLookUp[ele] % 2 == 0) {
            sockMarchCount++
        }
    }
  console.log("hello")
  
    return sockMarchCount;
  }

console.log(sockMerchant(10, [10, 20, 20, 10, 10, 30, 30, 50, 10, 20]));
