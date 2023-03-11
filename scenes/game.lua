------ NOTE: KEY (WHEN USED FOR VARIABLE NAMES) REFRENCES THE KEYS OF THE PIANO ------
local composer = require( "composer" )
local widget = require( "widget" )
-- import SONG_NAMES and SONG_NOTES variables 
local songData = require( "global.songData" ) 

local scene = composer.newScene()
 
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

local keysArray = {} -- array to store all the keys created in order 

local userKeyIndex = 0 -- the index of the key in the songNotes array (key index is incremented after user presses key)
local paceKeyIndex = 0 -- moniters user's pace (key index is set to what it should be according to song pace)

local gameInProgress = false

function scene:create( event )
    local sceneGroup = self.view
    keysGroup = display.newGroup()

    sceneGroup:insert(keysGroup) 

    songID = event.params.songID
    songNotes = SONG_NOTES[ songID ]

    level = event.params.level

    tempo = LEVELS[level]["tempo"]
     
    display.setDefault( 'background', 0.1 )

    composer.showOverlay( "scenes.demo", { isModal = true } ) -- overlay prevents user from interacting with piano keys

end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        levelText = display.newText({
            text = "LEVEL " .. level,     
            x = display.contentCenterX,
            y = display.contentCenterY - 150,
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 15,
            align = "center"
        }) 

        songTitle = display.newText({
            text = SONG_NAMES[songID],     
            x = display.contentCenterX,
            y = display.contentCenterY - 115,
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            align = "center"
        }) 

        pressText = display.newText({
            x = display.contentCenterX,
            y = display.contentCenterY - 60,
            text = "PRESS",
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 40,
        }) 
        pressText.alpha = 0

        local NUM_OF_KEYS = 15
        local KEY_WIDTH = (display.contentWidth / NUM_OF_KEYS ) - 5
        local KEY_HEIGHT = display.contentHeight / 2.5
        local SPACING_BETWEEN_KEYS = 4
        local PIANO_WIDTH = (KEY_WIDTH + SPACING_BETWEEN_KEYS) * NUM_OF_KEYS

        local function drawKey (keyID, xPos, yPos)
            key = display.newRoundedRect(keysGroup, xPos, yPos, KEY_WIDTH, KEY_HEIGHT, 3)
            key.fill = KEY_COLORS[KEY_VALUES[keyID]]
            key.number = keyID
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
            table.insert( keysArray, keyID, key) 
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
        local function afterKeyTouch( event ) -- key press transition 
            local params = event.source.params
            params.keyTouchEvent.target.alpha = 1
        end

        local function onKeyTouch( event ) -- used for demo (to imitate press) and used when user presses key
            if event.phase == "began" then
                compareKeys( event.target.number ) -- when key is pressed, it is checked to see if correct one was pressed
                event.target.alpha = 0.5 
                local effectTimer = timer.performWithDelay( 250, afterKeyTouch )  -- runs key press transition 
                effectTimer.params = { keyTouchEvent = event } 
            end
        end

        for index, key in ipairs(keysArray) do
            key:addEventListener("touch", onKeyTouch) -- add touch event listner to each piano key 
        end

        
        local function onDemoButtonRelease (event) 
            transition.fadeOut( demoButton, { time = 400 } )
            playDemo()
        end 

        demoButton = widget.newButton({
            x = display.contentCenterX,
            y = display.contentCenterY - 60,
            label = "PLAY DEMO", 
            labelAlign = "center",
            labelColor = { default = { 1, 1, 1 } },
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 40,
            onRelease = onDemoButtonRelease
        })

        local function onSongBeat (onDelay)
            delay = 0;
            for index, keyNumber in ipairs(songNotes) do
                delay = delay + tempo 
                local delayBetweenNotes = timer.performWithDelay( delay, onDelay ) 
                delayBetweenNotes.params = { key = keyNumber }
            end
        end

        local function imitatePressKey(event) -- imitates touch event without user interaction ( for demo )
            local params = event.source.params
            onKeyTouch({phase = "began", name = "touch", target = keysArray[params.key]})
        end

        local function pulsatePressButton ()
            paceKeyIndex = paceKeyIndex + 1

            transition.to( pressText, { time=tempo/3, alpha=1, onComplete=function()
            transition.to( pressText, { time=tempo/3, alpha=0 } )
            end } )
        end

        local function onStartButtonRelease (event) 
            transition.fadeOut( startButton, { time = 400 } )
            userKeyIndex = 0 -- sets back to 0 once the demo is over and the game begins 
            gameInProgress = true
            composer.hideOverlay() -- hiding overlay means user can interact with the piano 
 
            onSongBeat(pulsatePressButton)
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
                onRelease = onStartButtonRelease
            })
        end
        
        function playDemo ()
            onSongBeat(imitatePressKey)  
            timer.performWithDelay( tempo * #songNotes, createStartButton ) -- after demo ended, runs function to render start button
        end
 
        function onEndLevel (event) -- takes user to review screen after game over
            local params = event.source.params
            composer.gotoScene( 'scenes.review', { params={ songID = songID, result = params.result, currentLevel = level, nextLevel = params.nextLevel, description = params.description} } ) 
        end

        function compareKeys (keyPressed) -- Compares the keyID of key pressed by user with the keyID in the same index ( using keyIndex defined above ) in the songNotes array 
            userKeyIndex = userKeyIndex + 1 -- everytime a key is pressed the key index is incremented
            if (userKeyIndex ~= paceKeyIndex and gameInProgress) then
                delayExit = timer.performWithDelay (500, onEndLevel)
                delayExit.params = { result = 'fail', description = 'OH NO, YOU WERE OFF BEAT', nextLevel = level}
            elseif (keyPressed ~= songNotes[userKeyIndex] ) then
                delayExit = timer.performWithDelay (500, onEndLevel)
                delayExit.params = { result = 'fail', description = 'OH NO, YOU PLAYED THE WRONG NOTE', nextLevel = level}
            elseif (userKeyIndex == #songNotes and gameInProgress) then 
                if level < #LEVELS then
                    description = 'WELL DONE, NOW LETS MAKE IT FASTER'
                    nextLevel = level + 1
                else 
                    description = 'YOU COMPLETED ALL THE LEVELS'
                    nextLevel = 1
                end

                delayExit = timer.performWithDelay (500, onEndLevel)
                delayExit.params = { result = 'pass', description = description, nextLevel = nextLevel}
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