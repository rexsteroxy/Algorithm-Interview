/**
 * @param {number[][]} intervals
 * @return {number}
 */
var minMeetingRooms = function (intervals) {

  // takes in an array and converts to an object with keys of start and end times
  function takeArrayReturnObj(intervals) {
    let obj = {};
      obj["start"] = intervals[0];
      obj["end"] = intervals[1];
    return obj;
  }

  let result = [];

  // pushes the objects to  the result array
  for (let i = 0; i < intervals.length; i++) {
    let temp = intervals[i];
    result.push(takeArrayReturnObj(temp));
  }

  let start = [];
  let end = [];

  console.log(result);


// seperates the result array into start array and end array
  result.forEach((result) => {
    start.push(result.start);
    end.push(result.end);
  });

  console.log("before sort");
  console.log(start);
  console.log(end);

  start.sort((a, b) => a - b);
  end.sort((a, b) => a - b);

  console.log("after sort");
  console.log(start);
  console.log(end);

  let rooms = 0;
  let endpoint = 0;

  for (var i = 0; i < result.length; i++) {
    if (start[i] < end[endpoint]) {
      rooms++;
    } else {
      endpoint++;
    }
  }

  return rooms;
};

console.log(
  minMeetingRooms([
    [7, 10],
    [2, 4],
  ])
);
