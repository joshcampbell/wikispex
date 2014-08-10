var gulp       = require("gulp");
var coffee     = require("gulp-coffee");
var gutil      = require("gulp-util");
var connect    = require("gulp-connect");
var browserify = require("gulp-browserify");
var mocha      = require("gulp-mocha");
require("coffee-script/register")

var SPEC_FILES = "./spec/**/*.coffee"
var SRC_FILES = "./src/**/*.coffee"

gulp.task("tdd", function(){
  var retest = ["test"]
  gulp.watch(SRC_FILES, retest);
  gulp.watch(SPEC_FILES, retest);
});

gulp.task("test", function(){
  return gulp.src(SPEC_FILES)
    .pipe(mocha({reporter: 'nyan'}))
})

gulp.task('serve', ['build', 'start-server', 'watch'])
gulp.task('build', ['copy-pages', 'copy-libs', 'coffee'])


gulp.task("coffee", function(){
  gulp.src('./src/**/*.coffee')
    .pipe(coffee({ bare: true }).on("error", gutil.log))
    .pipe(gulp.dest('./js/'))

  gulp.src('./js/app.js')
    .pipe(browserify({ insertGlobals: true }))
    .pipe(gulp.dest('./build/'))
})

gulp.task("copy-pages", function(){
  gulp.src('./pages/*.html')
    .pipe(gulp.dest('./build'))
})

gulp.task("copy-libs", function(){
  gulp.src('./lib/**')
    .pipe(gulp.dest('./build/lib'))
})

gulp.task("start-server", function(){
  connect.server({ livereload: true, root: "build" });
})

gulp.task("reload-server", ["build"], function(){
  gulp.src("./build/*")
    .pipe(connect.reload())
})

gulp.task("watch", function(){
  var rebuild = ["reload-server"]
  gulp.watch("./src/*.coffee", rebuild);
  gulp.watch("./pages/*.html", rebuild);
  gulp.watch("./lib/*", rebuild);
})
