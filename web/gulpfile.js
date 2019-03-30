require('@babel/register');

const gulp = require('gulp');
const sourcemaps = require('gulp-sourcemaps');
const babel = require('gulp-babel');
const browserify = require('gulp-browserify');
// const buffer = require('vinyl-buffer');
const del = require('del');
const uglify = require('gulp-uglify');
const streamify = require('gulp-streamify');
const wrap = require('gulp-wrap');
const browserify2 = require('browserify');
const vueify = require('vueify');
const uglifyify = require('uglifyify');
const source = require('vinyl-source-stream');
const babelify = require('babelify');
const envify = require('envify/custom');
const path = require('path');

const paths = {
  serverSrc: 'src/server/**/*.js',
  serverDest: 'dist',
  jsSrc: 'src/js/**/*.js',
  vueSrc: 'src/js/**/*.vue',
  cssSrc: 'src/css/**/*.css',
  jsDest: 'dist',
  bundleDest: 'public/js/bundle',
  cssDest: 'public/css',
  fontAwesomeSrc: 'src/font-awesome/**',
  fontAwesomeDest: 'public/font-awesome'
};

const clean = cb => {
  console.log('starting clean');
  const subDirs = ['external', 'watches', 'components', 'store'];
  const expunge = [path.join(paths.jsDest, '**/*.js'), path.join(paths.jsDest, '**/*.map'),
		   path.join(paths.jsDest, '**/*.vue'),
		   path.join(paths.bundleDest, 'vdna-menu.js'), path.join(paths.cssDest, '**/**.css')];
  const keep = [`!${path.join(paths.cssDest, 'font-awesome')}`,
                `!${path.join(paths.cssDest, 'font-awesome/**/*.css')}`,
		`!${path.join(paths.cssDest, 'bootstrap.min.css')}`,
		`!${path.join(paths.cssDest, 'bootstrap-vue.min.css')}`];
  const toBeExpunged = expunge.concat(subDirs.map(sd => {
    return path.join(paths.jsDest, sd);
  })).concat(keep);
  del(toBeExpunged).then(ps => {
    console.log(`Expunged: ${ps.length} files`);
    cb();
  }).catch(err => {
    console.log(`del error: ${err}`);
  });
};

const vueifyDev = () => {
  let b = browserify2({
    entries: 'src/js/celestialGoat.js',
    debug: true,
    transform: [babelify, vueify]
  });
  return b.bundle()
    .pipe(source('celestialGoat.js'))
    .pipe(gulp.dest(paths.bundleDest));
};
const vueifyProd = () => {
  let b = browserify2({
    entries: 'src/js/celestialGoat.js',
  })
      .transform(vueify)
      .transform(babelify)
      .transform(uglifyify, { global: true })
      .transform(
	{ global: true },
	envify({ NODE_ENV: 'production' })
      );
  return b.bundle()
    .pipe(source('celestialGoat.js'))
    .pipe(streamify(uglify()))
    .pipe(wrap('(function (){ var define = undefined; window.PRODUCTION = 0;<%=contents%> })();'))
    .pipe(gulp.dest(paths.bundleDest));
};
const cssDev = () => {
  return gulp.src(paths.cssSrc)
    .pipe(gulp.dest(paths.cssDest));
};
const fontAwesome = () => {
  return gulp.src(paths.fontAwesomeSrc)
    .pipe(gulp.dest(paths.fontAwesomeDest));
};

const buildDev = gulp.series(clean, gulp.parallel(vueifyDev, cssDev, fontAwesome));
const buildProd = gulp.series(clean, gulp.parallel(vueifyProd, cssDev, fontAwesome));

const watchVue = () => {
  gulp.watch([paths.jsSrc, paths.vueSrc, paths.cssSrc], buildDev);
};

const server = () => {
  return gulp.src(paths.serverSrc)
    .pipe(babel({
      presets: ['@babel/preset-env'],
    }))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.serverDest));
};

gulp.task('server', server);
gulp.task('clean', clean);
gulp.task('buildDev', buildDev);
gulp.task('buildProd', buildProd);
gulp.task('watch', watchVue);
gulp.task('default', watchVue);
