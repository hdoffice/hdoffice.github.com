spawn	= require('child_process').spawn
xmpp	= require 'simple-xmpp'
im		= require 'imagemagick'
fs		= require 'fs'
tpl		= require 'mustache'

ready = 'off'
sitepath = "../"
lp = "large/"
ls = 600
sp = "small/"
ss = 240
pp = "preview/"

image_tpl = fs.readFileSync "./#{sitepath}gralley.tpl", 'utf8'

image_html_tpl =
"""
---
title: {{title}}
layout: image
imgurl: {{url}}
---
"""

#one by one
obo = (jobs,func,next)->
	if jobs.length < 1
		next()
	else
		job = jobs.pop()
		func job, ()->
			obo jobs,func,next


imresize = (dir,tdir,width,files,next)->
	obo files
		,(job,goin)->
			fs.stat "#{dir}#{tdir}#{job}" ,(err,stat)->
				if err && err.code == 'ENOENT'
					console.log err
					im.resize
						srcPath	: "#{dir}#{job}"
						dstPath	: "#{dir}#{tdir}#{job}"
						width	: width
						,(err,stdout,stderr)->
							if err
								console.error err
							else
								console.log "resized #{tdir}#{job}"
							goin()
				else
					console.log "#{tdir}#{job} already exist"
					goin()
		,next

imwork = (dir,next)->
	fs.readdir dir, (err,files)->
		files2 = files.concat()
		files3 = files.concat()
		if err
			console.error err
		imresize dir,lp,ls,files,()->
			imresize dir,sp,ss,files2,()->
				obo files3
					,(job,goin)->
						if /\.jpg$/.test(job)
							fs.writeFile "./#{sitepath}images/#{job}.html"
								,tpl.render image_html_tpl
									,"title":job
										,"url":job
								,"utf8"
								,()->
									null
						goin()
					,()->
						fs.readdir "#{dir}#{lp}",(err,files)->
							list = {}
							list.list =[]
							obo files
								,(job,goin)->
									fs.stat "#{dir}#{pp}#{job}" ,(err,stat)->
										if err && err.code == 'ENOENT'
											console.log err
											list.list.push src:"#{lp}#{job}",pre:"#{sp}#{job}"
										else
											list.list.push src:"#{lp}#{job}",pre:"#{pp}#{job}"
										goin()
								,()->
									fs.writeFile "./#{sitepath}_includes/subpages/image"
										,tpl.render image_tpl ,list
										,"utf8"
										,next

start = ()->
	console.log 'git pull start'
	ready = 'on'
	gitpull = spawn "./#{sitepath}gitpull.sh"
	gitpull.on 'exit' , (code,signal)->
		console.log 'git pull finish'
		imwork "./#{sitepath}images/",()->
			console.log 'git push start'
			gitpush = spawn './#{sitepath}gitpush.sh'
			gitpush.on 'exit' , (code,signal)->
				console.log 'git push finish'
				if ready == 'ready'
					start()
				else
					ready = 'off'

xmpp.on 'online',()->
	console.log 'Yes, I\'m connected!'
	

xmpp.on 'chat', (from,message)->
	#xmpp.send from, "echo:" + message
	if from == "github-services@jabber.org" && message.indexOf('autoupdate') < 0
		if ready == 'on'
			ready = 'ready'
		else if ready == 'ready'
			console.log 'already'
		else
			start()

xmpp.on 'error', (err)->
	console.error err

xmpp.connect
	jid		: "hi.makiss@gmail.com"
	password: "123makiss"
	host	: "talk.google.com"
	port	: "5222"

start()
