var gulp = require('gulp'),
    vulcanize = require('gulp-vulcanize'),
    compass = require('gulp-compass'),
    plumber = require('gulp-plumber'),
    path = require("path"),
    concat = require("gulp-concat")
    coffee = require("gulp-coffee");

gulp.task('default', ['vulcanize', 'compass'])

gulp.task('vulcanize', function () {
    gulp.src('src/*.html')
        .pipe(plumber())
        .pipe(vulcanize({
            dest: "dist",
            strip: true,
            csp: true, // chrome does not approve of inline scripts
            //verbose: true
        }))
        .pipe(gulp.dest('dist'));
});

gulp.task('coffee', function() {
    gulp.src('src/coffee/**/*.coffee')
        .pipe(plumber())
        .pipe(coffee({bare: true}))
        .pipe(concat("main.js"))
        .pipe(gulp.dest('dist/js'))
});

gulp.task("compass", function() {
   gulp.src("src/sass/*.scss")
       .pipe(plumber())
       .pipe(compass({
           project: path.join(__dirname, "src"),
           css: path.join(__dirname, "dist/css")
       }))
       .pipe(gulp.dest('dist/css'));
});

gulp.task('watch', function () {
    gulp.watch("src/**/*.scss", ["compass"]);

    gulp.watch("src/**/*.html", ["vulcanize"]);

    gulp.watch("src/coffee/*.coffee", ["coffee"]);
});