libsUrl = "/home/hata/F/"

config =
	js:
		dir:"./libs"
		main:"F"
		output:"../assets/scripts/o.js"
	css:
		dir:"./libs/"
		main:"custom.less"
		output:"../assets/stylesheets/o.css"

requirejs = require "#{libsUrl}r.js"
fs = require 'fs'
less = require "#{libsUrl}less"

jsoc =
	baseUrl: config.js.dir
	paths:jquery: "empty:"
	name: config.js.main
	out:config.js.output

cssc =
	input:config.css.dir+config.css.main
	paths: [config.css.dir,"#{libsUrl}libs"]
	output:config.css.output

parser = new less.Parser
	paths: cssc.paths

cssdata =
	"""
	@import "normalize_legacy";
	@import "F";
	@import "custom";
	"""

lessToCss = ()->
	parser.parse cssdata, (e,tree)->
		if e
			console.log "err:#{e}"
		else
			try
				css = tree.toCSS compress:true
				fd = fs.openSync cssc.output, 'w'
				fs.writeSync fd,css,0,"utf-8"
			catch error
				console.log error

jsoptimze = ()->
	requirejs.optimize jsoc

jsoptimze()
lessToCss()


if config.js.dir !=config.css.dir
	fs.watch config.js.dir,(event,filename) ->
		console.log "event is: #{event}"
		if filename
			console.log "filename provided: #{filename}"
			if /\.js$/.test(filename)
				console.log ".js"
				if not /^o\.js$/.test(filename)
					requirejs.optimize config
		else
			console.log 'filename not provided'
	fs.watch config.css.dir,(event,filename) ->
		console.log "event is: #{event}"
		if filename
			console.log "filename provided: #{filename}"
			if /\.less$/.test(filename)
				console.log ".less"
				lessToCss()
		else
			console.log 'filename not provided'
else
	fs.watch config.js.dir,(event,filename) ->
		console.log "event is: #{event}"
		if filename
			console.log "filename provided: #{filename}"
			if /\.js$/.test(filename)
				console.log ".js"
				if not /^o\.js$/.test(filename)
					requirejs.optimize config
			if /\.less$/.test(filename)
				console.log ".less"
				lessToCss()
		else
			console.log 'filename not provided'
