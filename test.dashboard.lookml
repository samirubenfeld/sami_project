- dashboard: test
  title: LOOKML DASH
  layout: newspaper
  elements:
  - title: New Tile
    name: New Tile
    model: trees
    explore: tree_census_2015_bigquery
    type: looker_grid
    fields: [tree_census_2015_bigquery.boroname, tree_census_2015_bigquery.health,
      tree_census_2015_bigquery.count]
    filters:
      tree_census_2015_bigquery.health: "-EMPTY"
    sorts: [tree_census_2015_bigquery.boroname, tree_census_2015_bigquery.count desc]
    limit: 500
    query_timezone: America/Los_Angeles
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: positron
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: true
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    series_types: {}
    row: 0
    col: 0
    width: 8
    height: 6
