// Tooltips for the Metrics page charts: one per mark on the weekly chart and
// the payments timeline, and a crosshair on the running totals chart. Both also work from the keyboard.
// Every value they show is also in the tables below the charts.

$(function() {
  function buildTooltip(chart) {
    var tip = document.createElement('div');
    tip.className = 'chart-tooltip';
    tip.setAttribute('aria-hidden', 'true');
    chart.appendChild(tip);
    return tip;
  }

  // data: { title: "...", rows: [{ key: "won", label: "...", value: "..." }] }
  function fill(tip, data) {
    tip.textContent = '';
    var title = document.createElement('div');
    title.className = 'chart-tooltip-title';
    title.textContent = data.title;
    tip.appendChild(title);

    data.rows.forEach(function(row) {
      var line = document.createElement('div');
      line.className = 'chart-tooltip-row';
      var key = document.createElement('i');
      key.className = 'chart-key chart-key-line' + (row.key ? ' chart-key-' + row.key : '');
      var value = document.createElement('strong');
      value.textContent = row.value;
      var label = document.createElement('span');
      label.textContent = row.label;
      line.appendChild(key);
      line.appendChild(value);
      line.appendChild(label);
      tip.appendChild(line);
    });
  }

  // Shows the tooltip beside x (pixels from the chart's left edge), flipping
  // to the left side when it would run off the chart.
  function place(tip, chart, x, y) {
    tip.style.display = 'block';
    var left = x + 12;
    if (left + tip.offsetWidth > chart.clientWidth) {
      left = x - 12 - tip.offsetWidth;
    }
    tip.style.left = Math.max(0, left) + 'px';
    tip.style.top = y + 'px';
  }

  // Charts where each mark (a week's column, a payment's dot) has its own tooltip.
  $('[data-chart="marks"]').each(function() {
    var chart = this;
    var tip = buildTooltip(chart);

    $(chart).find('[data-tip]').on('mouseenter focus', function() {
      var chartBox = chart.getBoundingClientRect();
      var markBox = this.getBoundingClientRect();
      fill(tip, $(this).data('tip'));
      place(tip, chart, markBox.right - chartBox.left, Math.max(0, markBox.top - chartBox.top - 8));
    }).on('mouseleave blur', function() {
      tip.style.display = 'none';
    });
  });

  $('[data-chart="line"]').each(function() {
    var chart = this;
    var plot = $(chart).find('.chart-plot')[0];
    var points = $(chart).data('points');
    var tip = buildTooltip(chart);
    var crosshair = document.createElement('div');
    crosshair.className = 'chart-crosshair';
    plot.appendChild(crosshair);
    var current = null;

    function show(index) {
      current = index;
      var ratio = points.length > 1 ? index / (points.length - 1) : 0.5;
      crosshair.style.left = (ratio * 100) + '%';
      crosshair.style.display = 'block';
      fill(tip, points[index]);
      var chartBox = chart.getBoundingClientRect();
      var plotBox = plot.getBoundingClientRect();
      place(tip, chart, plotBox.left - chartBox.left + ratio * plotBox.width, plotBox.top - chartBox.top + 8);
    }

    function hide() {
      current = null;
      crosshair.style.display = 'none';
      tip.style.display = 'none';
    }

    $(plot).on('pointermove', function(e) {
      var box = plot.getBoundingClientRect();
      var ratio = Math.min(Math.max((e.clientX - box.left) / box.width, 0), 1);
      show(Math.round(ratio * (points.length - 1)));
    }).on('pointerleave blur', hide)
      .on('focus', function() { show(points.length - 1); })
      .on('keydown', function(e) {
        if (current === null) { return; }
        if (e.key === 'ArrowLeft') {
          show(Math.max(0, current - 1));
          e.preventDefault();
        } else if (e.key === 'ArrowRight') {
          show(Math.min(points.length - 1, current + 1));
          e.preventDefault();
        }
      });
  });
});
