
fs = require('fs')
path = require('path')

gulp = require('gulp')
clean = require('gulp-clean')
sass = require('gulp-sass')
browserSync = require('browser-sync')
autoprefixer = require('gulp-autoprefixer')
uglify = require('gulp-uglify')
jshint = require('gulp-jshint')
header  = require('gulp-header')
footer = require('gulp-footer')
rename = require('gulp-rename')
minifycss = require('gulp-minify-css')

pkg = require('./package.json')

# Source and build paths.
paths=
  sass: 'sass/**/*.scss'
  js: 'js/**/*.js'
  vendorjs: 'vendor/**/*.js'
  html: 'html/**/*.html'
  assets: 'assets'
  build: 'build'
paths.dest=
  css: path.join(paths.build, 'css')
  js: path.join(paths.build, 'js')
  vendorjs: path.join(paths.build, 'js', 'vendor')
  
# Banner
banner = """/*!
 * <%= pkg.name %>
 * <%= pkg.url %>
 * Copyright #{new Date().getFullYear()} <%= pkg.author %>.
 */
"""
# HTML5 Boilerplate header and footer
htmlHeader = fs.readFileSync('h5bp-header.html').toString('utf8')
htmlFooter = fs.readFileSync('h5bp-footer.html').toString('utf8')

gulp.task 'copy', ->
  gulp.src(paths.assets+'/**/*', base: paths.assets)
  .pipe gulp.dest(paths.build)
  .pipe browserSync.reload({stream: true})
  
gulp.task 'clean', ->
  gulp.src(paths.build, {read: false})
  .pipe clean()
  
# Wrap each html file with HTML5 Boilerplate.
gulp.task 'html', ->
  gulp.src(paths.html)
  .pipe header(htmlHeader, {pkg: pkg, now: new Date()})
  .pipe footer(htmlFooter, {pkg: pkg})
  .pipe gulp.dest(paths.build)
  .pipe browserSync.reload({stream: true})

gulp.task 'sass', ->
  gulp.src(paths.sass)
  .pipe sass(errLogToConsole: true)
  .pipe autoprefixer(['> 1%', 'last 2 versions', 'IE 8'])
  .pipe gulp.dest(paths.dest.css)
  .pipe minifycss()
  .pipe rename({ suffix: '.min' })
  .pipe header(banner, {pkg: pkg})
  .pipe gulp.dest(paths.dest.css)
  .pipe browserSync.reload({stream: true})
  
gulp.task 'js', ->
  gulp.src(paths.vendorjs)
  .pipe gulp.dest(paths.dest.vendorjs)
  
  gulp.src(paths.js)
  .pipe jshint('.jshintrc')
  .pipe jshint.reporter('default')
  .pipe header(banner, {pkg: pkg})
  .pipe gulp.dest(paths.dest.js)
  .pipe uglify()
  .pipe header(banner, {pkg: pkg})
  .pipe rename(suffix: '.min')
  .pipe gulp.dest(paths.dest.js)
  .pipe browserSync.reload({stream: true, once: true})
  
gulp.task 'bs-init', ->
  browserSync.init null,
    server:
      baseDir: paths.build
  
gulp.task('default', ['sass', 'js', 'html', 'copy', 'bs-init'], ->
  gulp.watch(paths.sass, ['css'])
  gulp.watch(paths.js, ['js'])
  gulp.watch(paths.html, ['html'])
  gulp.watch(paths.assets+'**/*', ['copy'])
)
  
  
