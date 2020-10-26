/**
 * @param {number[][]} intervals
 * @return {number}
 */
var minMeetingRooms = function(intervals) {
// map the array to and o
const arr = [[35, "Bill"], [20, "Nancy"], [27, "Joan"]];

let obj = {};

for (let item of arr) {
  obj[item[1]] = item[0];
}

console.log(obj);

    
};

var data = [
    {start: 7, end: 10},
    {start: 2, end: 4},
     
  ]

console.log(minMeetingRooms([[7,10],[2,4]]));