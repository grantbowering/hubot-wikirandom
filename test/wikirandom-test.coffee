Helper = require('hubot-test-helper')
chai = require 'chai'
sinon = require 'sinon'
nock = require('nock')

expect = chai.expect

helper = new Helper('../src/wikirandom.coffee')

describe 'wikirandom', ->
 room = null
 beforeEach ->
    room = helper.createRoom()
    do nock.disableNetConnect
    nock("https://en.wikipedia.org")
      .get('/wiki/Special:Random')
      .reply 302, {}, {
        'location': 'https://en.wikipedia.org/redirectedto/somearticle'
      }

  it 'should reply with first paragraph of article', (done) ->

    nock("https://en.wikipedia.org")
    .get('/redirectedto/somearticle')
    .reply 200, {
      "
        <html>
          <body>
            <div id='mw-content-text'>
              <p>This should be the first paragraph</p>
            </div>
          </body>
        </html>
      "
    }
  
    room.user.say('alice', 'tell us a story').then =>
      expect(room.messages).to.eql [
        ['alice', 'tell us a story']
        ['hubot', 'Sure! Let me see what I can come up with.']
      ]
      setTimeout -> 
        expect(room.messages).to.eql [
          ['alice', 'tell us a story']
          ['hubot', 'Sure! Let me see what I can come up with.']
          ['hubot', 'Once upon a time...']
        ]
        setTimeout -> 
          expect(room.messages).to.eql [
            ['alice', 'tell us a story']
            ['hubot', 'Sure! Let me see what I can come up with.']
            ['hubot', 'Once upon a time...']
            ['hubot', 'This should be the first paragraph']
          ]
          setTimeout -> 
            expect(room.messages).to.eql [
              ['alice', 'tell us a story']
              ['hubot', 'Sure! Let me see what I can come up with.']
              ['hubot', 'Once upon a time...']
              ['hubot', 'This should be the first paragraph']
              ['hubot', 'The end.']
            ]
            room.destroy()
            nock.cleanAll()
            done()
          , 1100
        , 1100        
      , 1100
  .timeout(5000)