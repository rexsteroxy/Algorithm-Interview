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

let row_start=0; let row_end = matrix.length - 1; 
let column_start = 0; let column_end = matrix[0].length-1 ;
 
while (row_start <= row_end && column_start <= column_end) {
    for (let i = column_start; i <= column_end; i++) {
        output.push(matrix[row_start][i])   
    }

    for (let i = row_start + 1; i <= row_end; i++) {
        output.push(matrix[i][column_end])   
    }

    if (row_start < row_end) {
        for (let i = column_end - 1; i>= column_start; i--) {
            output.push(matrix[row_end][i])  
        }
    }

    if (column_start < column_end) {
        
        for (let i = row_end - 1; i>row_start; i--)  {
           output.push(matrix[i][row_start]) 
        }
    }

    row_end--;
    column_end--;
    row_start++;
    column_start++;
}


    

console.log(output)

    
};

spiralOrder([[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]])