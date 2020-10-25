/**
 * @param {number[][]} matrix
 * @return {number[]}
 * [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]
 *  cs        ce
 * rs1  2  3  4
    5  6  7  8
    9 10 11  12 
    re13,14,15,16
 */
var spiralOrder = function(matrix) {
   
//check if the matrix lenght is less than 1 or is index array is 1 and return empty array
if(matrix.length < 1 || matrix[0].length < 1) return [];

let output = [];

let rs=0; let re=matrix.length - 1; let cs = 0; let ce = matrix.length ;
 

    for (let i = rs; i < ce; i++) {
        output.push(matrix[0][i])   
    }

    for (let index = 0; index < array.length; index++) {
        const element = array[index];
        
    }


console.log(output)

    
};

spiralOrder([[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]])