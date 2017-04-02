# Description
#   Tells a 'story' by scraping a topic paragraph from the random article function of Wikipedia.
#
#
# Commands:
#   I tell you stories.
#
#
# Author:
#   grant.bowering@gmail.com

$ = require 'cheerio'

module.exports = (robot) ->

  robot.hear /(tell|teach) (me|us|her|him|them|@(\w+)) (a story|something)/i, (msg) ->
    msg.send "Sure! Let me see what I can come up with."
    msg.http("https://en.wikipedia.org/wiki/Special:Random")
        .get() (err, res, body) ->
            if err
                msg.send "Sorry, something went wrong with my brain! (#{err})"
                return
            if res.statusCode != 302
                msg.send "Sorry, something went wrong with my brain! (HTTP #{res.statusCode})"
                return
            setTimeout ->
              msg.send "Once upon a time..."
              msg.http(res.headers.location)
                  .get() (err, res, body) ->
                      if err
                          msg.send "Sorry, something went wrong with my brain! (#{err})"
                          return
                      if res.statusCode != 200
                          msg.send "Sorry, something went wrong with my brain! (HTTP #{res.statusCode})"
                          return
                      setTimeout -> 
                        msg.send "#{$($(body).find("#mw-content-text p")[0]).text().replace /\[[0-9]*\]/, ""}"
                        setTimeout -> 
                          msg.send "The end."
                        , 1000
                      , 1000
            , 1000