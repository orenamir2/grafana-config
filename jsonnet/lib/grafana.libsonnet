{
  datasource(uid='$datasource'):: {
    uid: uid,
  },

  grid(x, y, w, h):: {
    h: h,
    w: w,
    x: x,
    y: y,
  },

  thresholds: {
    single(color='green'):: {
      mode: 'absolute',
      steps: [
        {
          color: color,
        },
      ],
    },

    greenRed(value=1):: {
      mode: 'absolute',
      steps: [
        {
          color: 'green',
        },
        {
          color: 'red',
          value: value,
        },
      ],
    },

    greenOrangeRed(warn=1, critical=5):: {
      mode: 'absolute',
      steps: [
        {
          color: 'green',
        },
        {
          color: 'orange',
          value: warn,
        },
        {
          color: 'red',
          value: critical,
        },
      ],
    },
  },

  fieldConfig(unit='none', thresholds=null, custom={})::
    local resolvedThresholds = if thresholds == null then $.thresholds.single() else thresholds;
    {
    defaults: {
      mappings: [],
      thresholds: resolvedThresholds,
      unit: unit,
    } + (if std.length(std.objectFields(custom)) == 0 then {} else {
      custom: custom,
    }),
    overrides: [],
  },

  target(expr, refId='A', legend='value', instant=false, format=null):: {
    datasource: $.datasource(),
    editorMode: 'code',
    expr: expr,
    legendFormat: legend,
    refId: refId,
  } + (if instant then {
    instant: true,
  } else {}) + (if format == null then {} else {
    format: format,
  }),

  statPanel(
    id,
    title,
    expr,
    grid,
    unit='none',
    legend='value',
    instant=true,
    thresholds=null,
    options={}
  )::
    local resolvedThresholds = if thresholds == null then $.thresholds.single() else thresholds;
    {
    datasource: $.datasource(),
    fieldConfig: $.fieldConfig(unit=unit, thresholds=resolvedThresholds),
    gridPos: grid,
    id: id,
    options: {
      colorMode: 'value',
      graphMode: 'area',
      justifyMode: 'auto',
      orientation: 'auto',
      reduceOptions: {
        calcs: [
          'lastNotNull',
        ],
        fields: '',
        values: false,
      },
      textMode: 'auto',
    } + options,
    targets: [
      $.target(expr=expr, legend=legend, instant=instant),
    ],
    title: title,
    type: 'stat',
  },

  timeSeriesPanel(
    id,
    title,
    targets,
    grid,
    unit='none',
    thresholds=null,
    custom={}
  )::
    local resolvedThresholds = if thresholds == null then $.thresholds.single() else thresholds;
    {
    datasource: $.datasource(),
    fieldConfig: $.fieldConfig(
      unit=unit,
      thresholds=resolvedThresholds,
      custom={
        axisBorderShow: false,
        axisCenteredZero: false,
        axisColorMode: 'text',
        axisLabel: '',
        axisPlacement: 'auto',
        barAlignment: 0,
        drawStyle: 'line',
        fillOpacity: 10,
        gradientMode: 'none',
        hideFrom: {
          legend: false,
          tooltip: false,
          viz: false,
        },
        lineInterpolation: 'linear',
        lineWidth: 1,
        pointSize: 5,
        scaleDistribution: {
          type: 'linear',
        },
        showPoints: 'never',
        spanNulls: false,
        stacking: {
          group: 'A',
          mode: 'none',
        },
        thresholdsStyle: {
          mode: 'off',
        },
      } + custom
    ),
    gridPos: grid,
    id: id,
    options: {
      legend: {
        calcs: [],
        displayMode: 'list',
        placement: 'bottom',
        showLegend: true,
      },
      tooltip: {
        mode: 'single',
        sort: 'none',
      },
    },
    targets: targets,
    title: title,
    type: 'timeseries',
  },

  tablePanel(id, title, expr, grid, legend='value'):: {
    datasource: $.datasource(),
    fieldConfig: $.fieldConfig(
      thresholds=$.thresholds.greenRed(),
      custom={
        cellOptions: {
          type: 'auto',
        },
        inspect: false,
      }
    ),
    gridPos: grid,
    id: id,
    options: {
      cellHeight: 'sm',
      footer: {
        countRows: false,
        fields: '',
        reducer: [
          'sum',
        ],
        show: false,
      },
      showHeader: true,
    },
    targets: [
      $.target(
        expr=expr,
        legend=legend,
        instant=true,
        format='table'
      ),
    ],
    title: title,
    type: 'table',
  },

  variables: {
    datasource(name='datasource', query='prometheus', currentText='Prometheus', currentValue='prometheus'):: {
      current: {
        text: currentText,
        value: currentValue,
      },
      includeAll: false,
      name: name,
      options: [],
      query: query,
      refresh: 1,
      regex: '',
      type: 'datasource',
    },

    query(name, expr, refId, includeAll=true, multi=true, allValue='.*'):: {
      allValue: allValue,
      current: {
        selected: true,
        text: 'All',
        value: '$__all',
      },
      datasource: $.datasource(),
      definition: expr,
      includeAll: includeAll,
      multi: multi,
      name: name,
      options: [],
      query: {
        query: expr,
        refId: refId,
      },
      refresh: 1,
      regex: '',
      type: 'query',
    },
  },

  dashboard(
    title,
    uid,
    panels,
    variables=[],
    tags=[
      'managed-by-git',
      'jsonnet',
    ],
    refresh='30s',
    timeFrom='now-6h',
    timeTo='now'
  ):: {
    annotations: {
      list: [
        {
          builtIn: 1,
          datasource: {
            type: 'datasource',
            uid: 'grafana',
          },
          enable: true,
          hide: true,
          iconColor: 'rgba(0, 211, 255, 1)',
          name: 'Annotations & Alerts',
          type: 'dashboard',
        },
      ],
    },
    editable: false,
    fiscalYearStartMonth: 0,
    graphTooltip: 0,
    links: [],
    panels: panels,
    preload: false,
    refresh: refresh,
    schemaVersion: 41,
    tags: tags,
    templating: {
      list: variables,
    },
    time: {
      from: timeFrom,
      to: timeTo,
    },
    timepicker: {},
    timezone: 'browser',
    title: title,
    uid: uid,
    version: 1,
    weekStart: '',
  },
}
