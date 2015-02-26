var gulp = require('gulp'),
    vulcanize = require('gulp-vulcanize'),
    compass = require('gulp-compass'),
    plumber = require('gulp-plumber'),
    path = require('path'),
    concat = require('gulp-concat'),
    coffee = require('gulp-coffee'),
    sourcemaps = require('gulp-sourcemaps'),
    runSequence = require('run-sequence'),
    browserSync = require('browser-sync'),
    del = require('del'),
    zip = require('gulp-zip');

gulp.task('default', ['html', 'compass', 'coffee', 'libs', 'copy'])
gulp.task('package', function() {
    return runSequence('html', 'compass', 'coffee', 'libs', 'copy', 'zip');
})

gulp.task('html', function() {
    return runSequence('columns', 'vulcanize', function() {
        del('src/columns/compiled')
    });
})

gulp.task('columns', function() {
    return gulp.src('src/columns/**/*.html')
        .pipe(plumber())
        .pipe(concat('columns.html'))
        .pipe(gulp.dest('src/columns/compiled'))
})

gulp.task('libs', function() {
    return gulp.src([
        'bower_components/web-animations-js/web-animations-next-lite.min.js',
        'bower_components/polymer/polymer.js',
        'bower_components/core-focusable/core-focusable.js',
        'bower_components/core-focusable/polymer-mixin.js',

        'bower_components/packery/dist/packery.pkgd.js',
        'bower_components/store.js/store.js',
        'bower_components/color-thief/src/color-thief.js',
        'bower_components/draggabilly/dist/draggabilly.pkgd.js',
        'bower_components/fetch/fetch.js',
        'bower_components/momentjs/moment.js',
        'bower_components/pleasejs/src/Please.js'
    ])
        .pipe(concat('libs.js'))
        .pipe(gulp.dest('dist/js'))
})

gulp.task('copy', function() {
    //for files that don't need to be compiled. but just copied
    gulp.src('src/font/*')
        .pipe(gulp.dest("dist/font"));
    gulp.src('src/img/*')
        .pipe(gulp.dest("dist/img"));
    return gulp.src('src/manifest.json')
        .pipe(gulp.dest('dist'))
})

gulp.task('zip', function() {
    return gulp.src("dist/**")
        .pipe(zip('tabbie.zip'))
        .pipe(gulp.dest('./'))
});

gulp.task('vulcanize', function () {
    return gulp.src('src/**.html')
        .pipe(plumber())
        .pipe(vulcanize({
            dest: 'dist',
            strip: false,
            csp: true, // chrome does not approve of inline scripts
            excludes: {
                imports: [
                    //do not use roboto import because it requires external server (imported trough screen.scss)
                    'roboto.html',

                    //do not use the following imports as they try to import scripts from it's bower location, which we don't package.
                    //(these get packaged in libs.js)
                    'core-focusable.html',
                    'polymer.html',
                    'web-animations.html'
                ]
            }
        }))
        .pipe(gulp.dest('dist'))
});

gulp.task('coffee', function() {
    return gulp.src('src/**/*.coffee')
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(coffee({
            bare: true
        }))
        .pipe(concat('main.js'))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('dist/js'))
});

gulp.task('compass', function() {
    return gulp.src('src/sass/*.scss')
       .pipe(plumber())
       .pipe(compass({
           project: path.join(__dirname, 'src'),
           css: path.join(__dirname, 'dist/css'),
           sourcemap: true
       }))
       .pipe(gulp.dest('dist/css'));
});

gulp.task('serve', ['default'], function () {
    browserSync({
        server: {
            baseDir: '.'
        },
        startPath: 'dist/tab.html',
        reloadDelay: 1500
    });
});

gulp.task('reload', function () {
    return browserSync.reload();
});

gulp.task('watch', ['serve'], function () {
    gulp.watch('src/**/*.scss', ['compass', 'reload']);

    gulp.watch('src/**/*.html', ['html', 'reload']);

    gulp.watch('src/**/*.coffee', ['coffee', 'reload']);

    gulp.watch('src/manifest.json', ['copy']);
});