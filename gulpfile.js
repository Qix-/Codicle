var gulp = require('gulp');
var peg = require('gulp-peg');
var uglify = require('gulp-uglify');
var coffee = require('gulp-coffee');

gulp.task('common-grammar', function()
{
	gulp.src('./src/common/*.peg')
		.pipe(peg())
		.pipe(gulp.dest('./build/common/js/grammar'));
});

gulp.task('common-coffee', function()
{
	gulp.src('./src/common/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./build/common/js'));
});

gulp.task('common-pkg', ['common-coffee', 'common-grammar'], function()
{
	gulp.src('./build/common/js/**/*.js')
		.pipe(uglify())
		.pipe(gulp.dest('./pkg/client/js'))
		.pipe(gulp.dest('./pkg/server/js'));
});

gulp.task('default', ['common-pkg']);