// Generated by CoffeeScript 1.3.3
(function() {
  var fs, im, image_html_tpl, image_tpl, imresize, imwork, lp, ls, obo, pp, ready, sitepath, sp, spawn, ss, start, tpl, xmpp;

  spawn = require('child_process').spawn;

  xmpp = require('simple-xmpp');

  im = require('imagemagick');

  fs = require('fs');

  tpl = require('mustache');

  ready = 'off';

  sitepath = "../";

  lp = "large/";

  ls = 600;

  sp = "small/";

  ss = 240;

  pp = "preview/";

  image_tpl = fs.readFileSync("./" + sitepath + "gralley.tpl", 'utf8');

  image_html_tpl = "---\ntitle: {{title}}\nlayout: image\nimgurl: {{url}}\n---";

  obo = function(jobs, func, next) {
    var job;
    if (jobs.length < 1) {
      return next();
    } else {
      job = jobs.pop();
      return func(job, function() {
        return obo(jobs, func, next);
      });
    }
  };

  imresize = function(dir, tdir, width, files, next) {
    return obo(files, function(job, goin) {
      return fs.stat("" + dir + tdir + job, function(err, stat) {
        if (err && err.code === 'ENOENT') {
          console.log(err);
          return im.resize({
            srcPath: "" + dir + job,
            dstPath: "" + dir + tdir + job,
            width: width
          }, function(err, stdout, stderr) {
            if (err) {
              console.error(err);
            } else {
              console.log("resized " + tdir + job);
            }
            return goin();
          });
        } else {
          console.log("" + tdir + job + " already exist");
          return goin();
        }
      });
    }, next);
  };

  imwork = function(dir, next) {
    return fs.readdir(dir, function(err, files) {
      var files2, files3;
      files2 = files.concat();
      files3 = files.concat();
      if (err) {
        console.error(err);
      }
      return imresize(dir, lp, ls, files, function() {
        return imresize(dir, sp, ss, files2, function() {
          return obo(files3, function(job, goin) {
            if (/\.jpg$/.test(job)) {
              fs.writeFile("./" + sitepath + "images/" + job + ".html", tpl.render(image_html_tpl, {
                "title": job,
                "url": job
              }, "utf8", function() {
                return null;
              }));
            }
            return goin();
          }, function() {
            return fs.readdir("" + dir + lp, function(err, files) {
              var list;
              list = {};
              list.list = [];
              return obo(files, function(job, goin) {
                return fs.stat("" + dir + pp + job, function(err, stat) {
                  if (err && err.code === 'ENOENT') {
                    console.log(err);
                    list.list.push({
                      src: "" + lp + job,
                      pre: "" + sp + job
                    });
                  } else {
                    list.list.push({
                      src: "" + lp + job,
                      pre: "" + pp + job
                    });
                  }
                  return goin();
                });
              }, function() {
                return fs.writeFile("./" + sitepath + "_includes/subpages/image", tpl.render(image_tpl, list, "utf8", next));
              });
            });
          });
        });
      });
    });
  };

  start = function() {
    var gitpull;
    console.log('git pull start');
    ready = 'on';
    gitpull = spawn("./" + sitepath + "gitpull.sh");
    return gitpull.on('exit', function(code, signal) {
      console.log('git pull finish');
      return imwork("./" + sitepath + "images/", function() {
        var gitpush;
        console.log('git push start');
        gitpush = spawn('./#{sitepath}gitpush.sh');
        return gitpush.on('exit', function(code, signal) {
          console.log('git push finish');
          if (ready === 'ready') {
            return start();
          } else {
            return ready = 'off';
          }
        });
      });
    });
  };

  xmpp.on('online', function() {
    return console.log('Yes, I\'m connected!');
  });

  xmpp.on('chat', function(from, message) {
    if (from === "github-services@jabber.org" && message.indexOf('autoupdate') < 0) {
      if (ready === 'on') {
        return ready = 'ready';
      } else if (ready === 'ready') {
        return console.log('already');
      } else {
        return start();
      }
    }
  });

  xmpp.on('error', function(err) {
    return console.error(err);
  });

  xmpp.connect({
    jid: "hi.makiss@gmail.com",
    password: "123makiss",
    host: "talk.google.com",
    port: "5222"
  });

  start();

}).call(this);
