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

  console.log(chartdata)

  var margin = {
    top: 50,
    right: 10,
    bottom: 30,
    left: 70
  }

  var height = 400 - margin.top - margin.bottom,
    width = 720 - margin.left - margin.right,
    barWidth = 40,
    barOffset = 20;

  var dynamicColor;
  var dynamicText;

  chartdata = chartdata.map(x => +x)

  var yScale = d3.scaleLinear()
    .domain([0, d3.max(chartdata)])
    .range([0, height])

    console.log(d3.max(chartdata))

  var xScale = d3.scaleBand()
    .domain(d3.range(1, chartdata.length + 1))
    .range([0, width])

  var colors = d3.scaleLinear()
    .domain([0, chartdata.length * .33, chartdata.length * .66, chartdata.length])
    .range(['#d6e9c6', '#bce8f1', '#faebcc', '#ebccd1'])

  var canvas = d3.select('#monthly-sales').append('svg')
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
                    'stroke-width': 2
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
                      .style('fill', function() {
                        return "hsl(" + Math.random() * 360 + ",80%,65%)";
                      });
                      dynamicText = d3.select('svg').append("text")
                            .attr("x", d3.mouse(this)[0])
                            .attr("y", d3.mouse(this)[1] + margin.top)
                            .attr("text-anchor", "middle")
                            .style("font", "24px times")
                            .style("text-shadow", "3px 3px 4px white")
                            .text('$' + data);
                  })
                  .on('mouseout', function(data) {
                    d3.select(this)
                      .style('fill', dynamicColor);
                    dynamicText.remove();
                  })



  canvas.transition()
    .attr('height', function(data) {
      return yScale(data);
    })
    .attr('y', function(data) {
      return height - yScale(data);
    })
    .delay(function(data, i) {
      return i * 20;
    })
    .duration(2000)
    .ease(d3.easeElastic)

  var verticalGuideScale = d3.scaleLinear()
    .domain([0, d3.max(chartdata)])
    .range([height, 0])

  var vAxis = d3.axisLeft(verticalGuideScale)
    .ticks(10)
    .tickFormat(d3.format("($.0f"));

  var verticalGuide = d3.select('svg').append('g').style("font", "18px times")
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

  var month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

  var hAxis = d3.axisBottom(xScale)
                .tickFormat(function(d, i) { return month_names[i]; })

  var horizontalGuide = d3.select('svg').append('g').style("font", "18px times")
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

  d3.select('svg').append("text")
        .attr("x", (width/2))
        .attr("y", margin.top / 2)
        .attr("text-anchor", "middle")
        .style("font-size", "26px")
        .style("text-decoration", "underline")
        .text("Total Sales By Month");
}

// load data on page load
$(document).ready(function(){
  loadSoldMonthlyData();
});
