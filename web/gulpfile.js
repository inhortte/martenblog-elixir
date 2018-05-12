'use strict';

require('babel-core/register');

const gulp = require('gulp');
const sourcemaps = require('gulp-sourcemaps');
const babel = require('gulp-babel');
const browserify = require('gulp-browserify');
const del = require('del');
const uglify = require('gulp-uglify');
const streamify = require('gulp-streamify');
const wrap = require('gulp-wrap');

const path = require('path');
const srcDir = 'src';

const paths = {
  jsSrc: 'src/js/**/*.js',
  jsDest: 'public/js',
  cssSrc: 'src/css/**/*.css',
  cssDest: 'public/css'
};

/*
 * CLIENT
 */

const clean = cb => {
  console.log('starting clean');
  const subDirs = ['external', 'watches', 'config', 'components', 'containers', 'actions', 'reducers', 'utils', 'json', 'bundle', 'middleware'];
  const expunge = [path.join(paths.jsDest, '**/*.js'), path.join(paths.jsDest, '**/*.map'), path.join(paths.cssDest, '**/*.css')];
  const toBeExpunged = expunge;
  del(toBeExpunged).then(ps => {
    console.log(`Expunged: ${ps.length} files`);
    cb();
  }).catch(err => {
    console.log(`del error: ${err}`);
  });
};

const babelify = () => {
  return gulp.src(paths.jsSrc)
    .pipe(sourcemaps.init())
    .pipe(babel({
      presets: ['env', 'react'],
      plugins: ['transform-object-assign']
    }))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.jsDest));
};
const css = () => {
  return gulp.src(paths.cssSrc).pipe(gulp.dest(paths.cssDest));
};
const browserifyDev = () => {
  return gulp.src(path.join(paths.jsDest, 'mbClient.js'))
    .pipe(browserify({
      "browserify-css": {
        autoInject: true
      },
      insertGlobals: true,
      debug: true
    }))
    .pipe(wrap('(function (){ var define = undefined; <%=contents%> })()'))
    .pipe(gulp.dest(path.join(paths.jsDest, 'bundle')));
};
const browserifyProd = () => {
  return gulp.src(path.join(paths.jsDest, 'mbClient.js'))
    .pipe(browserify({
      global: true,
      transform: ['uglifyify']
    }))
    .pipe(streamify(uglify()))
    .pipe(wrap('(function (){ var define = undefined; <%=contents%> })();'))
    .pipe(gulp.dest(path.join(paths.clientDest, 'bundle')));
};

const buildDev = gulp.series(clean, gulp.parallel(babelify, css), browserifyDev);
const buildProd = gulp.series(clean, gulp.parallel(babelify, css), browserifyProd);
const cwatch = () => {
  gulp.watch([paths.jsSrc, paths.cssSrc], buildDev);
};

/*
 * TASKS
 */

gulp.task('cclean', clean);
gulp.task('buildClient', buildDev);
gulp.task('buildClientProd', buildProd);
gulp.task('cwatch', cwatch);

gulp.task('default', cwatch);
