

function countingValleys(steps, path) {
    // Write your code here

    //wow this algorithm is somehow 
    let ar = path.split('')
    if (steps !== ar.length) {
        return 0;
      }
    
      let level = 0;
      let numberOfValleys = 0;
      
    
      for (let i = 0; i < ar.length; i++) {
          let ele = ar[i];
    
          if (ele == "U") {
              level += 1;
              if (level == 0) {
                numberOfValleys += 1;
              }
          }else{
              level -= 1;
          }
          
       
      }
   
 

      return numberOfValleys;
    
 

}


console.log(countingValleys(8, "UDDDUDUU"));
