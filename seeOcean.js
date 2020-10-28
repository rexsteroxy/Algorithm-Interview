 
 // [1,3,2,5,7,5,4]
 function seeOcean(houses){
     
    if(houses.length == 0){
        return [];
    }
    
let output = [];
let count = 0;


for(let i=houses.length - 1; i >= 0; i--){
   
  
   if(houses[i] == houses[houses.length - 1]) {
       
       output.push(houses[i]);
   }
   else if(houses[i] > output[count]){
       output.push(houses[i]);
       count++;
   }
   
       
}

return output;
    
     
 }
 
 
 console.log(seeOcean([1,3,2,5,7,5,4]))