// Example 1:

// Input: [[0, 30],[5, 10],[15, 20]]
// Output: 2
// Example 2:

// Input: [[7,10],[2,4]]
// Output: 1


// /**
// Given an array of meeting time intervals consisting of start and end times [[s1,e1],[s2,e2],...] (si < ei), find the minimum number of conference rooms required.
// For example,
// Given [[0, 30],[5, 10],[15, 20]],
// return 2. 


const minMeetingRooms = intervals => {
    let start = [],
      end = []
  
      console.log(intervals)


    intervals.forEach(interval => {
      start.push(interval.start)
      end.push(interval.end)
    })
    console.log(start);
    console.log(end);
    console.log("before sort");

    start.sort((a, b) => a - b)
    end.sort((a, b) => a - b)
    console.log(start);
    console.log(end);
    console.log("after sort");

    let rooms = 0
    let endpoint = 0
  
   console.log(intervals.length)
  
    for (var i = 0; i < intervals.length; i++) {
      if (start[i] < end[endpoint]) {
        rooms++
      } else {
        endpoint++
      }
    }
    
    return rooms
  }
  [[7,10],[2,4]]
  var data = [
    {start: 7, end: 10},
    {start: 2, end: 4},
     
  ]
  
  console.log(minMeetingRooms(data));

  
  
  //console.log(minMeetingRooms( [[0, 30],[5, 10],[15, 20]] ))