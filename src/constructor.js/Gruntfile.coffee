module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    watch:
      options:
        livereload: true
      script:
        files: ["src/*.coffee"]
        tasks: ['default']

    copy:
      main:
        files: [{expand:true, cwd:"dist/",src:"*", dest:"../constructor/static/js/sop/"}]
    coffee:
      compile:
        options:
          sourceMap: true
          join: true
        files:
          "dist/constructor.js":["src/main.coffee", "src/builder.coffee", "src/utils.coffee", "src/geometry.coffee", "src/admin.coffee"]



  #grunt.loadNpmTasks('grunt-contrib-uglify');
  #grunt.loadNpmTasks('grunt-contrib-jshint');
  #grunt.loadNpmTasks('grunt-contrib-qunit');
  grunt.loadNpmTasks('grunt-contrib-watch');
  #grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-copy');


  #grunt.registerTask('test', ['jshint', 'qunit']);

  grunt.registerTask('default', [ 'coffee', 'copy']);
  grunt.registerTask('compile', [ 'coffee']);



  grunt.event.on 'watch', (action, filepath) =>
    grunt.config(['jshint', 'all'], filepath)

