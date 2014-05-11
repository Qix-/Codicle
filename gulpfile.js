var gulp = require('gulp');
var peg = require('gulp-peg');
var uglify = require('gulp-uglify');
var coffee = require('gulp-coffee');
var clean = require('gulp-clean');

gulp.task('common-grammar', function()
{
	gulp.src('./src/common/TickScript-v1-Parser.peg')
		.pipe(peg({
				exportVar: 'TSParser'
			}))
		.pipe(gulp.dest('./build/common/js'));

	gulp.src('./src/common/Cmd-Parser.peg')
		.pipe(peg({
				exportVar: 'CLIParser'
			}))
		.pipe(gulp.dest('./build/common/js'));
});

gulp.task('common-coffee', function()
{
	gulp.src('./src/common/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./build/common/js'));
});

gulp.task('common-pkg', ['common-coffee', 'common-grammar'], function()
{
	gulp.src('./build/common/js/**/*.js')
		//.pipe(uglify())
		.pipe(gulp.dest('./pkg/static/js'));
});

gulp.task('default', ['common-pkg']);

gulp.task('clean', function()
{
	gulp.src(['./pkg', './build'], {read: false})
		.pipe(clean());
});