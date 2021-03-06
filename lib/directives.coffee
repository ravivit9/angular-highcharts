app = angular.module 'angular-highcharts.directives', []

app.directive 'chart', ['IdGenerator', '$timeout', (idGenerator, timeout) ->
	restrict: 'AEC'
	transclude: yes
	template: '<div style="with:100%; height: 100%;"></div><div style="display:none;" ng-transclude>'
	link: (scope, element, attrs) ->
		console.log 'chart'
		id = idGenerator.getID()
		element.children()[0].setAttribute 'id', id
		
		config =
			chart:
				renderTo: id
		throw "No type defined" unless attrs.type?
		config.chart.type = attrs.type unless attrs.type is "stock"
		if attrs.title?
			config.title =
				text: attrs.title

		chart = null
		timer = null
		active = if attrs.active? then scope.$eval attrs.active else yes

		scope.$watch attrs.active, (newActive) ->
			active = newActive

		# in case of cleanup
		scope.$on 'destroy', () ->
			chart.destroy()

		scope.$on 'chartElement', (event, elementType, callback) ->
			callback config

		scope.$on 'chartElementDone', (event) ->
			console.log "chartElementDone", active
			if active
			 	# reschedule?
				timeout.cancel timer if timer?
				
				# redraw on next tick, do this outside of angulars scope checks
				timer = timeout () ->
					console.log "redraw", config
					if attrs.type is "stock"
						chart = new Highcharts.StockChart config
					else
						chart = new Highcharts.Chart config
					timer = null
				, 2, no

		scope.$broadcast 'chartReady', config

		if active
			if attrs.type is "stock"
				chart = new Highcharts.StockChart config
			else
				chart = new Highcharts.Chart config
		
]

app.directive 'serie', [() ->
	restrict: 'AEC'
	scope:
		config: "="
		name: "="
		data: "="
	link: (scope, element) ->
		console.log 'serie'

		config = if scope.config? then scope.config else {}

		config.name = scope.name if scope.name?
		config.data = scope.data if scope.data?

		done = no

		configureSerie = (chartConfig, emit) ->
			if not done
				chartConfig.series = [] unless chartConfig.series?
				chartConfig.series.push config
				scope.$emit 'chartElementDone' if emit is yes
				done = yes
		
		scope.$emit 'chartElement', 'serie' , (chartConfig) ->
			configureSerie chartConfig, yes
			
		
		scope.$on 'chartReady', (event, chartConfig) ->
			configureSerie chartConfig, no
]

app.directive 'axisX', [() ->
	restrict: 'AEC'
	scope:
		config: "="
		title: "@"
	link: (scope) ->
		console.log "xAxis"
		
		config = if scope.config? then scope.config else {}
		
		if scope.title
			config.title =
				text: scope.title

		done = no

		configureAxis = (chartConfig, emit) ->
			if not done
				chartConfig.xAxis = {} unless chartConfig.xAxis?
				chartConfig.xAxis = config
				scope.$emit "chartElementDone" if emit is yes
				done = yes


		scope.$emit 'chartElement', 'xAxis', (chartConfig) ->
			configureAxis chartConfig, yes

		scope.$on 'chartReady', (event, chartConfig) ->
			configureAxis chartConfig, no

]

app.directive 'axisY', [() ->
	restrict: 'AEC'
	scope:
		config: "="
		title: "@"
	link: (scope) ->
		console.log "yAxis"

		config = if scope.config? then scope.config else {}
		
		if scope.title
			config.title =
				text: scope.title

		done = no
		configureAxis = (chartConfig, emit) ->
			if not done
				chartConfig.yAxis = {} unless chartConfig.yAxis?
				chartConfig.yAxis = config
				scope.$emit "chartElementDone" if emit is yes
				done = yes

		scope.$emit 'chartElement', 'yAxis', (chartConfig) ->
			configureAxis chartConfig, yes

		scope.$on 'chartReady', (event, chartConfig) ->
			configureAxis chartConfig, no
]