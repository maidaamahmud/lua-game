------ NOTE: KEY (WHEN USED FOR VARIABLE NAMES) REFRENCES THE KEYS OF THE PIANO ------
local composer = require( "composer" )
local widget = require( "widget" )

-- import SONG_NAMES, SONG_NOTES, and LEVELS variables 
local songData = require( "global.songData" ) 

local scene = composer.newScene()
 
-- piano keys constant variables
local KEY_VALUES = {"B", "C", "D", "E", "F", "G", "A", "B", "C", "D", "E", "F", "G", "A", "B"}
local KEY_COLORS = {
  ["B"] = {0.9, 0.3, 0.3},
  ["C"] = {1, 0.6, 0.1},
  ["D"] = {1, 0.9, 0.2},
  ["E"] = {0.7, 0.9, 0.4},
  ["F"] = {0.4, 0.8, 0.8},
  ["G"] = {0.4, 0.4, 1},
  ["A"] = {0.5, 0.3, 0.8}
}
local NUM_OF_KEYS = 15
local KEY_WIDTH = (display.contentWidth / NUM_OF_KEYS ) - 5
local KEY_HEIGHT = display.contentHeight / 2.5
local SPACING_BETWEEN_KEYS = 4
local PIANO_WIDTH = (KEY_WIDTH + SPACING_BETWEEN_KEYS) * NUM_OF_KEYS

-- array to store all the paino keys created in order 
local keysArray = {} 

-- userKeyIndex and paceKeyIndex are compared to determine if the user is pressing the keys on beat
-- increments after user presses key
local userKeyIndex = 0
-- incements on each song beat (a key should be pressed on each beat)
local paceKeyIndex = 0 

-- set to true when the user is playing, set to false during demo and when the user is not activley playing
local gameInProgress = false

function scene:create( event )
    local sceneGroup = self.view

    keysGroup = display.newGroup()
    sceneGroup:insert(keysGroup) 

    songID = event.params.songID
    level = event.params.level

    songNotes = SONG_NOTES[songID]

    tempo = LEVELS[level]["tempo"]

    composer.showOverlay( "scenes.overlay", { isModal = true } ) -- overlay prevents user from interacting with piano keys
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

        levelText = display.newText({ -- displays level number on the top of the screen
            text = "LEVEL " .. level,     
            x = display.contentCenterX,
            y = display.contentCenterY - 150,
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 15,
            align = "center"
        }) 

        songTitle = display.newText({ -- displays name of song
            text = SONG_NAMES[songID],     
            x = display.contentCenterX,
            y = display.contentCenterY - 115,
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            align = "center"
        }) 

        pressText = display.newText({ -- flashing text informing user when to press the next key
            x = display.contentCenterX,
            y = display.contentCenterY - 60,
            text = "PRESS",
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 40,
        }) 
        pressText.alpha = 0 -- initially text is not visible

        demoButton = widget.newButton({ -- play demo button 
            x = display.contentCenterX,
            y = display.contentCenterY - 60,
            label = "PLAY DEMO", 
            labelAlign = "center",
            labelColor = { default = { 1, 1, 1 } },
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 40,
            onRelease = function() 
                transition.fadeOut( demoButton, { time = 400 } ) -- removes demo button from the screen
                playDemo()
            end
        })

        local function drawKey (keyID, xPos, yPos)
            -- newRoundedRect(parent, x, y, width, height, cornerRadius)
            key = display.newRoundedRect(keysGroup, xPos, yPos, KEY_WIDTH, KEY_HEIGHT, 3)
            key.fill = KEY_COLORS[KEY_VALUES[keyID]]
            key.number = keyID

            -- the song note that appears on each key
            keyText = display.newText({
                parent = keysGroup,
                text = KEY_VALUES[keyID],     
                x = xPos,
                y = yPos + KEY_HEIGHT / 3,
                font = 'fonts/GroupeMedium-8MXgn.otf',
                fontSize = 13,
                align = "center",
            })
            keyText:setFillColor({0,0,0})
            
            table.insert(keysArray, keyID, key) 
        end

        local function drawPiano ()
        local xPos = display.contentCenterX - ( PIANO_WIDTH / 2 - (KEY_WIDTH + SPACING_BETWEEN_KEYS) / 2 )
        local yPos = display.contentCenterY + 70
            for count = 1, NUM_OF_KEYS do
                drawKey( count, xPos, yPos )
                xPos = xPos + KEY_WIDTH + SPACING_BETWEEN_KEYS
            end
        end

        drawPiano()
 
    elseif ( phase == "did" ) then
        local function afterKeyTouch( event ) 
            local params = event.source.params
            -- returns the color of the key back to normal
            params.keyTouchEvent.target.alpha = 1
        end

        local function onKeyTouch( event ) -- when key is pressed
            if event.phase == "began" then
                compareKeys( event.target.number ) -- when key is pressed, it is checks to see if correct one was pressed
                event.target.alpha = 0.5 -- the color of the key becomes darker once it is pressed
                -- the key remains slightly darker, and then afterKeyTouch is run <- returns the key to its normal color
                local effectTimer = timer.performWithDelay( 250, afterKeyTouch ) 
                effectTimer.params = { keyTouchEvent = event } 
            end
        end

        for index, key in ipairs(keysArray) do
            key:addEventListener("touch", onKeyTouch) -- add touch event listener to each piano key 
        end

        local function onSongBeat (onDelay) -- runs a callback function on every beat (according to the set tempo)
            delay = 0;
            for index, keyNumber in ipairs(songNotes) do
                delay = delay + tempo 
                local delayBetweenNotes = timer.performWithDelay( delay, onDelay ) 
                delayBetweenNotes.params = { key = keyNumber }
            end
        end

        local function imitatePressKey(event) -- imitates touch event without user interaction (for demo)
            local params = event.source.params
            onKeyTouch({phase = "began", name = "touch", target = keysArray[params.key]})
        end

        local function pulsatePressText () -- makes press text appear and then dissapear from screen once
            paceKeyIndex = paceKeyIndex + 1 -- everytime the press text appears, the paceKeyIndex is incremented
            transition.to(pressText, {time=tempo/3, alpha=1, onComplete=function()
            transition.to(pressText, {time=tempo/3, alpha=0})
            end})
        end

        local function createStartButton ()
            startButton = widget.newButton({
                x = display.contentCenterX,
                y = display.contentCenterY - 60,
                label = "START GAME", 
                labelAlign = "center",
                labelColor = { default = { 1, 1, 1 } },
                font = 'fonts/GroupeMedium-8MXgn.otf',
                fontSize = 40,
                onRelease = function() 
                    transition.fadeOut( startButton, { time = 400 } )
                    userKeyIndex = 0 -- sets back to 0 once the demo is over and the game begins 
                    gameInProgress = true 
                    composer.hideOverlay() -- hiding overlay means user can interact with the piano 
                    onSongBeat(pulsatePressText) -- renders the press text to the song beat (tempo)
                end
            })
        end

        function playDemo ()
            onSongBeat(imitatePressKey) -- presses key to the song beat (tempo)
            timer.performWithDelay( tempo * #songNotes, createStartButton ) -- after demo ends, runs function to render start button on screen
        end

 
        function onEndLevel(event)
            -- Takes user to review screen after game over
            local params = event.source.params
            composer.gotoScene('scenes.review', {
                params = {
                    songID = songID,
                    result = params.result,
                    currentLevel = level,
                    nextLevel = params.nextLevel,
                    description = params.description
                }
            }) 
        end

        function compareKeys(keyPressed)
            userKeyIndex = userKeyIndex + 1 -- everytime a key is pressed the key index is incremented

            -- if game is in progress and the number of keys pressed by user is not equal to...
            -- ...the number of keys that should have been pressed by now according to the pace of song
            if (userKeyIndex ~= paceKeyIndex and gameInProgress) then 
                -- user fails
                delayExit = timer.performWithDelay(500, onEndLevel)
                delayExit.params = { result = 'fail', description = 'OH NO, YOU WERE OFF BEAT', nextLevel = level }
                -- if key pressed by user is not the correct key 
            elseif (keyPressed ~= songNotes[userKeyIndex]) then
                -- user fails
                delayExit = timer.performWithDelay(500, onEndLevel)
                delayExit.params = { result = 'fail', description = 'OH NO, YOU PLAYED THE WRONG NOTE', nextLevel = level }
                -- if game is in progress and the number of keys pressed by user is equal to...
                -- ...the number of key notes in the song 
            elseif (userKeyIndex == #songNotes and gameInProgress) then 
                -- user passes
                if level < #LEVELS then -- if all levels have not been completed yet
                    description = 'WELL DONE, NOW LETS MAKE IT FASTER'
                    nextLevel = level + 1
                else -- if all levels have been completed
                    description = 'YOU COMPLETED ALL THE LEVELS'
                    nextLevel = 1
                end
                delayExit = timer.performWithDelay(500, onEndLevel)
                delayExit.params = { result = 'pass', description = description, nextLevel = nextLevel }
            end
        end
    end
end
 
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
 
    elseif ( phase == "did" ) then
        composer.removeScene( "scenes.game")
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view

    songTitle:removeSelf()
    songTitle = nil

    pressText:removeSelf()
    pressText = nil

    levelText:removeSelf()
    levelText = nil

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene