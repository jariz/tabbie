var gulp = require('gulp'),
    vulcanize = require('gulp-vulcanize'),
    compass = require('gulp-compass'),
    plumber = require('gulp-plumber'),
    path = require("path"),
    concat = require("gulp-concat"),
    coffee = require("gulp-coffee"),
    sourcemaps = require("gulp-sourcemaps"),
    runSequence = require('run-sequence'),
    del = require("del")

gulp.task('default', ['html', 'compass', 'coffee'])

gulp.task("html", function() {
    runSequence('columns', 'vulcanize', function() {
        del("src/columns/compiled")
    });
})

gulp.task("columns", function() {
    return gulp.src("src/columns/**/*.html")
        .pipe(plumber())
        .pipe(concat("columns.html"))
        .pipe(gulp.dest("src/columns/compiled"))
})

gulp.task('vulcanize', function () {
    return gulp.src('src/**.html')
        .pipe(plumber())
        .pipe(vulcanize({
            dest: "dist",
            strip: false,
            csp: true, // chrome does not approve of inline scripts
        }))
        .pipe(gulp.dest("dist"))
});

gulp.task('coffee', function() {
    gulp.src('src/**/*.coffee')
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(coffee({
            bare: true
        }))
        .pipe(concat("main.js"))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('dist/js'))
});

gulp.task("compass", function() {
   gulp.src("src/sass/*.scss")
       .pipe(plumber())
       .pipe(compass({
           project: path.join(__dirname, "src"),
           css: path.join(__dirname, "dist/css"),
           sourcemap: true
       }))
       .pipe(gulp.dest('dist/css'));
});

gulp.task('watch', function () {
    gulp.watch("src/**/*.scss", ["compass"]);

    gulp.watch("src/**/*.html", ["html"]);

    gulp.watch("src/**/*.coffee", ["coffee"]);
});