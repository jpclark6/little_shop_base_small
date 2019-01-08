var loadSoldItemDataMerchants = function(){
                $.ajax({
                  type: 'GET',
                  contentType: 'application/json; charset=utf-8',
                  url: '/merchants',
                  dataType: 'json',
                  success: function(data){
                    drawPieMerchantRevenue(data);
                  },
                  failure: function(result){
                    error();
                  }
                });
              };

function error() {
    console.log("Something went wrong!");
}

function drawPieMerchantRevenue(data) {
  data = data[1];
  console.log(data);
  console.log('loaded pie');

  var width = 800;
      height = 400;
      radius = Math.min(width, height) / 2;

  var color = d3.scaleLinear()
                .domain([0, data.length * .33, data.length * .66, data.length])
                .range(['#39a342', '#CBDAE5', '#BBAFAD', '#E89B40'])

  var pie = d3.pie()
              .value(function(d) { return d[1]; })(data);

  var arc = d3.arc()
            .outerRadius(radius - 10)
            .innerRadius(0);

  var dynamicColor;
  var dynamicText;

  var svg = d3.select("#merchant-pie")
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
    .style("fill", function(d, i) { return color(i);})
    .style("stroke", '#406F8C')
    .style("stroke-width", "2");


  g.append("text")
      .attr("transform", function(d) {
        return "translate(" + ( (radius - 12) * Math.sin( ((d.endAngle - d.startAngle) / 2) + d.startAngle ) ) + "," + ( -1 * (radius - 12) * Math.cos( ((d.endAngle - d.startAngle) / 2) + d.startAngle ) )  + ")"; })
      .attr("dy", ".35em")
      .style("text-anchor", function(d) {
        var rads = ((d.endAngle - d.startAngle) / 2) + d.startAngle;
        if ( (rads > 7 * Math.PI / 4 && rads < Math.PI / 4) || (rads > 3 * Math.PI / 4 && rads < 5 * Math.PI / 4) ) {
          return "end";
        } else if (rads >= Math.PI / 4 && rads <= 3 * Math.PI / 4) {
          return "end";
        } else if (rads >= 5 * Math.PI / 4 && rads <= 7 * Math.PI / 4) {
          return "end";
        } else {
          return "end";
        }
      })
      .style("font", "18px times")
      .style("text-shadow", "3px 3px 4px white")
      .text(function(d) {
        return d.data[0] + " at $" + parseInt(d.data[1], 10); });
}

$(document).ready(function(){
  loadSoldItemDataMerchants();
});
