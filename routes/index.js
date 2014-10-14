var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database('pluses.db');
var express = require('express');
var router = express.Router();
var request = require('request');
var http = require('http');
var querystring = require('querystring');
var sys = require('sys')
var exec = require('child_process').exec;
function puts(error, stdout, stderr) { sys.puts(stdout) }
var image_index = 0;
var rando = false;

router.post('/', function(req, res) {
	// Replace spaces in request
	var term = req.body.text.replace(/^\./g, ''),
        parts = term.split(" "),
        command = parts[0],
        args = parts.slice(1).join(" "),
		finishCall = function(item) {
			res.end(JSON.stringify({text: item}));
		};
    if (parts[1]) {
        var nick = parts[1],
            nick = nick.replace(/[^a-zA-z0-9_ \.-]/g, '');
    }
    var leaderboard = function (table) {
        db.all("SELECT nick, pluses FROM " + table + " ORDER BY pluses DESC LIMIT 10", function (err, rows) {
            var leaders = table.charAt(0).toUpperCase() + table.slice(1) + " Leaderboard:\n";
            var i = 0;
            rows.forEach(function (row) {
                i++;
                leaders += i + ". " + row.pluses + " " + row.nick + "\n";
            });
            finishCall(leaders);
        });
    }

    var add_one = function(table, nick, req) {
        if (nick != req.body.user_name) {
            console.log("|" + nick + "| incremented " + table);
            db.run("INSERT OR IGNORE INTO " + table + " VALUES (?, 0)", nick);
            db.run("UPDATE " + table + " SET pluses = pluses + 1 WHERE nick = ?", nick);

            db.get("SELECT pluses FROM " + table + " WHERE nick = ?", nick, function (err, row) {
                finishCall(nick + " now has " + row.pluses + " " + table);
            });
        } else {
            finishCall("nice try");
        }
    }

    var sub_one = function(table, nick, req) {
        console.log("|" + req.body.user_name + "| tried to decrement" + table);
        db.run("INSERT OR IGNORE INTO " + table + " VALUES (?, 0)", req.body.user_name);
        db.run("UPDATE " + table + " SET pluses = pluses - 1 WHERE nick = ?", req.body.user_name);

        db.get("SELECT pluses FROM " + table + " WHERE nick = ?", req.body.user_name, function (err, row) {
            finishCall("Don't be a meanie! " + req.body.user_name + " now has " + row.pluses + " " + table);
        });
    }

    switch (command) {
        case "increment":
        case "pluses":
        case "plus":
            if (!nick) {
                leaderboard("pluses");
            } else {
                add_one("pluses", nick, req);
            }
            break;
        case "decrement":
            sub_one("pluses", nick, req);
            break;
        case "troll":
        case "trolls":
            if (!nick) {
                leaderboard("trolls");
            } else {
                add_one("trolls", nick);
            }
            break;
        case "resummon":
            rando = true;
        case "summon":
        case "gif":
            if (0 && req.body.user_name == "travis") {
                finishCall("http://4.bp.blogspot.com/_Nu9qz3BZvZU/S427XIB031I/AAAAAAAAAPg/38S5euCch7k/s400/justin_bieber_wallpaper_album_2009.jpg");
                break;
            }
            var options = {
                host: 'www.google.com',
                port: 80,
                path: "/search?safe=strict&tbm=isch&q=" + encodeURIComponent(args),
                method: 'GET',
                headers: {
                    'user-agent': 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)'
                }
            };
            var tmpist = [];
            var req = http.get(options, 
                function(res) {
                    res.setEncoding('utf8');
                    res.on('data', function (chunk) {
                        tmpist.push(chunk);
                    });

                    res.on('end', function (e) {
                        chunk = tmpist.join('');

                        var matches = chunk.match(/imgurl=(.*?)&/g);
                        if (matches) {
                            if (rando) {
                                image_index = Math.floor(Math.random() * matches.length);
                            }
                            var match = matches[image_index];
                            console.log(match);
                            rando = false;
                            finishCall(match.replace(/^imgurl=/, '').replace(/&$/, ''));
                        }
                    });
                }
            ).on("error", function (e) {
                finishCall("Got error: " + e.message);
            });

            break;
        case 'g':
        case 'google':
            var tmp = []
            var options = {
                host: 'ajax.googleapis.com',
                port: 80,
                path: '/ajax/services/search/web?v=1.0&rsz=large&start=0&q=' + encodeURIComponent(args),
                method: 'GET',
                headers: {
                    'user-agent': 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)'
                }
            };
            var req = http.request(options, 
                function(res) {
                    res.setEncoding('utf8');
                    res.on('data', function (chunk) {
                        tmp.push(chunk);
                    });

                    res.on('end', function (e) {
                        var body = tmp.join('');
                        var result = JSON.parse(body);
                        finishCall(
                            result.responseData.results[0].titleNoFormatting + " @ " +
                            result.responseData.results[0].unescapedUrl
                        );
                    });
                }
            ).on("error", function (e) {
                finishCall("Got error: " + e.message);
            });
            req.end();
            break;
        case 'source':
            finishCall('https://github.com/jayson/SlackCat');
            break;
        case 'gitup':
            exec("git pull", function (error, stdout, stderr) {
                finishCall(stdout + "\n" + stderr);
            });
            break;
        case 'youtube':
            exec("./youtube.py " + args, function (error, stdout, stderr) {
                finishCall(stdout + "\n" + stderr);
            });
            break;
        case 'q':
        case 'quote':
            var symbol = args.replace(/\./, '-');
            var params = [
                's',
                'k1',
                'k2',
                'c6',
                'x',
                'n',
                'v',
                'j1'
            ]
            var tmp = []
            var options = {
                host: 'download.finance.yahoo.com',
                port: 80,
                path: '/d/quotes.csv?f=' + params.join('') + '&s=' + encodeURIComponent(args),
                method: 'GET',
                headers: {
                    'user-agent': 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)'
                }
            };

            var req = http.request(options, 
                function(res) {
                    res.setEncoding('utf8');
                    res.on('data', function (chunk) {
                        tmp.push(chunk);
                    });

                    res.on('end', function (e) {
                        var body = tmp.join('');
                        var raw_list = body.trim().replace(/"/g, '').split(',');
                        var price = raw_list[1];
                        price = price.replace(/N\/A - /,'');
                        price = price.replace(/<b>/,'');
                        price = price.replace(/<\/b>/, '');
                        var message = raw_list[5] + " (" + raw_list[0] + ") " + price + " " + raw_list[3] + " (" + raw_list[3] + "%) http://finance.yahoo.com/q?s=" + raw_list[0];
                        finishCall(message);
                    });
                }
            ).on("error", function (e) {
                finishCall("Got error: " + e.message);
            });
            req.end();
            break;

    }
});

module.exports = router;
