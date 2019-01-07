var loadSoldItemData = function(){
                $.ajax({
                  type: 'GET',
                  contentType: 'application/json; charset=utf-8',
                  url: '/dashboard',
                  dataType: 'json',
                  success: function(data){
                    drawPieSoldItems(data);
                  },
                  failure: function(result){
                    error();
                  }
                });
              };

function error() {
    console.log("Something went wrong!");
}

function drawPieSoldItems(data) {
  console.log(data);
  var width = 400,
  height = 400,
  radius = Math.min(width, height) / 2;
  var color = d3.scaleOrdinal().range(['#0099ff',"#ff704d"]);
  var pie = d3.pie().value(function(d) { return d.quantity; })(data);
  var arc = d3.arc()
    .outerRadius(radius - 10)
    .innerRadius(0);

  var svg = d3.select("#sold-pie")
    .append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + width/2 + "," + height/2 +")");

  var g = svg.selectAll("arc")
    .data(pie)
    .enter().append("g")
    .attr("class", "arc");

  g.append("path")
    .attr("d", arc)
    .style("fill", function(d) { return color(d.data.status);});

}

// load data on page load
$(document).ready(function(){
  loadSoldItemData();
});
