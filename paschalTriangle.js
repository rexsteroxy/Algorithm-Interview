function paschalTriangle(numRows){

// initialize empty triangle
    let triangle = [];

    // check if numrows is == 0
    if (numRows === 0) {
        return triangle;
    }

    // push [1] manually
    triangle.push([1]);

// creation of new rows from previous rows
 for (let i = 1; i < numRows; i++) {
     // creating previous row
     let prevRow = triangle[i - 1];
     let newRow = [];


     // manually push one to  the beginning of the new row
     newRow.push(1);

     for (let j = 1; j < prevRow.length; j++) {
         //substrats 1 from the current value of j in prevRow and adds it to
         //current value of j in prevRow 
         newRow.push(prevRow[j - 1] + prevRow[j]);
         
     }

     //manually push another one to the end of the new row
     newRow.push(1);

     //finally push the new created row to the 2d triangle
     triangle.push(newRow);
     
 }
  return triangle;

}


console.log(paschalTriangle(5));