function rob(houses){
    let totalAmount1= 0
    let totalAmount2 = 0;
    
   
        for(let i=0; i < houses.length; i++){
            
            if(i % 2 == 0){
                totalAmount1 += houses[i];
            }else{
                totalAmount2 += houses[i];
            }
            
        }
       
    
    
    
    
    
    
    
    return Math.max(totalAmount1,totalAmount2);
}

console.log(rob([1,2,5,4,7]))














