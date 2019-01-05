var loadSoldMonthlyData = function(){
                $.ajax({
                  type: 'GET',
                  contentType: 'application/json; charset=utf-8',
                  url: '/merchants',
                  dataType: 'json',
                  success: function(data){
                    drawBarMonthlySales(data);
                  },
                  failure: function(result){
                    error();
                  }
                });
              };

function error() {
    console.log("Something went wrong!");
}

function drawBarMonthlySales(data) {
  var chartdata = data;
  // var chartdata = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120,
  //         135, 150, 165, 180, 200, 220, 240, 270, 300, 330, 370, 410
  //       ];

  var margin = {
    top: 30,
    right: 10,
    bottom: 30,
    left: 50
  }

  var height = 400 - margin.top - margin.bottom,
    width = 720 - margin.left - margin.right,
    barWidth = 40,
    barOffset = 20;

  var dynamicColor;

  var yScale = d3.scaleLinear()
    .domain([0, d3.max(chartdata)])
    .range([0, height])

  var xScale = d3.scaleBand()
    .domain(d3.range(1, chartdata.length + 1))
    .range([0, width])

  var colors = d3.scaleLinear()
    .domain([0, chartdata.length * .33, chartdata.length * .66, chartdata.length])
    .range(['#d6e9c6', '#bce8f1', '#faebcc', '#ebccd1'])

  var awesome = d3.select('#monthly-sales').append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .style('background', '#ffffff')
    .append('g')
    .attr('transform', 'translate(' + margin.left + ', ' + margin.top + ')')
    .selectAll('rect').data(chartdata)
    .enter().append('rect')
    .styles({
      'fill': function(data, i) {
        return colors(i);
      },
      'stroke': '#31708f',
      'stroke-width': '1'
    })
    .attr('width', xScale.bandwidth())
    .attr('x', function(data, i) {
      return xScale(i);
    })
    .attr('height', 0)
    .attr('y', height)
    .on('mouseover', function(data) {
      dynamicColor = this.style.fill;
      d3.select(this)
        .style('fill', '#3c763d')
    })

  .on('mouseout', function(data) {
    d3.select(this)
      .style('fill', dynamicColor)
  })

  awesome.transition()
    .attr('height', function(data) {
      return yScale(data);
    })
    .attr('y', function(data) {
      return height - yScale(data);
    })
    .delay(function(data, i) {
      return i * 20;
    })
    .duration(5000)
    .ease(d3.easeElastic)

  var verticalGuideScale = d3.scaleLinear()
    .domain([0, d3.max(chartdata)])
    .range([height, 0])

  var vAxis = d3.axisLeft(verticalGuideScale)
    .ticks(10)

  var verticalGuide = d3.select('svg').append('g')
  vAxis(verticalGuide)
  verticalGuide.attr('transform', 'translate(' + margin.left + ', ' + margin.top + ')')
  verticalGuide.selectAll('path')
    .styles({
      fill: 'none',
      stroke: "#3c763d"
    })
  verticalGuide.selectAll('line')
    .styles({
      stroke: "#3c763d"
    })

  var hAxis = d3.axisBottom(xScale)
    .ticks(chartdata.size)

  var horizontalGuide = d3.select('svg').append('g')
  hAxis(horizontalGuide)
  horizontalGuide.attr('transform', 'translate(' + margin.left + ', ' + (height + margin.top) + ')')
  horizontalGuide.selectAll('path')
    .styles({
      fill: 'none',
      stroke: "#3c763d"
    })
  horizontalGuide.selectAll('line')
    .styles({
      stroke: "#3c763d"
    });
}

// function drawBarMonthlySales(data) {
//   console.log(data);
//
//   var margin = {top: 20, right: 20, bottom: 70, left: 40},
//     width = 600 - margin.left - margin.right,
//     height = 300 - margin.top - margin.bottom;
//
//   // Parse the date / time
//   // var	parseDate = d3.time.format("%Y-%m").parse;
//
//   var x = d3.scaleBand().rangeRound([0, width]);
//   // var x = d3.scaleOrdinal().rangeRound([0, width]);
//
//   var y = d3.scaleLinear().range([height, 0]);
//
//   var xAxis = d3.axisBottom(x)
//       .ticks(10);
//
//   var yAxis = d3.axisLeft(y)
//       .ticks(10);
//
//   var svg = d3.select("#monthly-sales")
//               .append("svg")
//               .attr("width", width + margin.left + margin.right)
//               .attr("height", height + margin.top + margin.bottom)
//               .append("g")
//               .attr("transform",
//                 "translate(" + margin.left + "," + margin.top + ")");
//
//     x.domain(data.map(function(d) { return d.date; }));
//     y.domain([0, d3.max(data, function(d) { return d.value; })]);
//
//     svg.append("g")
//         .attr("class", "x axis")
//         .attr("transform", "translate(0," + height + ")")
//         .call(xAxis)
//         .selectAll("text")
//         .style("text-anchor", "end")
//         .attr("dx", "-.8em")
//         .attr("dy", "-.55em")
//         .attr("transform", "rotate(-90)" );
//
//     svg.append("g")
//         .attr("class", "y axis")
//         .call(yAxis)
//         .append("text")
//         .attr("transform", "rotate(-90)")
//         .attr("y", 6)
//         .attr("dy", ".71em")
//         .style("text-anchor", "end")
//         .text("Value ($)");
//
//   var xScale = d3.scaleBand()
//     .domain(d3.range(0, data.length))
//     .range([0, width])
//
//     svg.selectAll("bar")
//         .data(data)
//         .enter().append("rect")
//         .style("fill", "steelblue")
//         .attr("x", function(d) { return x(d.date); })
//         .attr('width', xScale.bandwidth())
//         .attr("y", function(d) { return y(d.value); })
//         .attr("height", function(d) { return height - y(d.value); });
//
// };

  // console.log(data);
  // var width = 400,
  // height = 400,
  // radius = Math.min(width, height) / 2;
  // var color = d3.scaleOrdinal().range(['#0099ff',"#ff704d"]);
  // var pie = d3.pie().value(function(d) { return d.quantity; })(data);
  // var arc = d3.arc()
  //   .outerRadius(radius - 10)
  //   .innerRadius(0);
  //
  // // var labelArc = d3.arc()
  // //   .outerRadius(radius - 40)
  // //   .innerRadius(radius - 40);
  //
  // var svg = d3.select("#sold-pie")
  //   .append("svg")
  //   .attr("width", width)
  //   .attr("height", height)
  //   .append("g")
  //   .attr("transform", "translate(" + width/2 + "," + height/2 +")");
  //
  // var g = svg.selectAll("arc")
  //   .data(pie)
  //   .enter().append("g")
  //   .attr("class", "arc");
  //
  // g.append("path")
  //   .attr("d", arc)
  //   .style("fill", function(d) { return color(d.data.status);});
  //
  // // g.append("text")
  // //   .attr("transform", function(d) { return "translate(" + labelArc.centroid(d) + ")"; })
  // //   .text(function(d) { return d.data.letter;})
  // //   .style("fill", "#111");
// }

// load data on page load
$(document).ready(function(){
  loadSoldMonthlyData();
});
