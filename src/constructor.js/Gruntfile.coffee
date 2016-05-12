module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')


		copy:
			main:
				files: [{expand:true, cwd:"dist/",src:"*", dest:"../constructor/static/js/sop/"}]
		'closure-compiler':
			displayer:
				closurePath: '/Users/azl/Documents/workspace/be-web.ru/src/constructor.js/bin'
				js: ["dist/displayer.js"]
				jsOutputFile: "dist/displayer.min.js"
				noreport:true
				options:
					compilation_level: 'SIMPLE_OPTIMIZATIONS'
					warning_level:'DEFAULT'
				
			
		
	
		coffee:
			compile:
				options:
					sourceMap: true
					join: true
				files:
					"dist/constructor.js":["src/main.coffee", "src/builder.coffee", "src/utils.coffee", "src/geometry.coffee", "src/admin.coffee"]
					"dist/displayer.js":["src/main.coffee", "src/builder.coffee", "src/utils.coffee", "src/geometry.coffee"]



	#grunt.loadNpmTasks('grunt-contrib-uglify');
	#grunt.loadNpmTasks('grunt-contrib-jshint');
	#grunt.loadNpmTasks('grunt-contrib-qunit');
	grunt.loadNpmTasks('grunt-contrib-watch');
	#grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-closure-compiler');


	#grunt.registerTask('test', ['jshint', 'qunit']);

	grunt.registerTask('default', [ 'coffee','closure-compiler', 'copy']);
	grunt.registerTask('compile', [ 'coffee']);



	grunt.event.on 'watch', (action, filepath) =>
		grunt.config(['jshint', 'all'], filepath)

