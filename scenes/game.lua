------ NOTE: KEY (WHEN USED FOR VARIABLE NAMES) REFRENCES THE KEYS OF THE PIANO ------
local composer = require( "composer" )
local widget = require( "widget" )
-- import SONG_NAMES and SONG_NOTES variables 
local songData = require( "global.songData" ) 

local scene = composer.newScene()
 
local KEY_COLORS = {{0.9, 0.2, 0.2}, {1, 0.5, 0}, {1, 0.9, 0.2}, {0.7, 0.9, 0.4}, {0.5, 0.9, 0.9}, {0.3, 0.3, 0.8}, {0.4, 0.2, 0.7}, {1, 0.5, 0.7}}

local keysArray = {} -- array to store all the keys created in order 

local userKeyIndex = 0 -- the index of the key in the songNotes array (key index is incremented after user presses key)
local paceKeyIndex = 0 -- moniters user's pace (key index is set to what it should be according to song pace)

local gameInProgress = false

function scene:create( event )
    local sceneGroup = self.view
    keysGroup = display.newGroup()

    sceneGroup:insert(keysGroup) 

    songId = event.params.songId
    songNotes = SONG_NOTES[ songId ]

    level = event.params.level
    if level == 1 then
        tempo = 1600
        print("level 1")
    elseif level == 2 then
        tempo = 1350
        print("level 2")
    elseif level == 3 then
        tempo = 1100
        print("level 3")
    elseif level == 4 then
        tempo = 850
        print("level 4")
    elseif level == 5 then
        tempo = 600
        print ("level 5")
    end
     
    display.setDefault( 'background', 0.1 )

    composer.showOverlay( "scenes.demo", { isModal = true } ) -- overlay prevents user from interacting with piano keys

end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        print(level)
        levelText = display.newText({
            text = "LEVEL " .. level,     
            x = display.contentCenterX,
            y = display.contentCenterY - 150,
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 15,
            align = "center"
        }) 

        songTitle = display.newText({
            text = SONG_NAMES[songId],     
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

        local KEY_WIDTH = 65
        local KEY_HEIGHT = 140
        local NUM_OF_KEYS = 8
        local SPACING_BETWEEN_KEYS = 5.5
        local PIANO_WIDTH = (KEY_WIDTH + SPACING_BETWEEN_KEYS) * NUM_OF_KEYS

        local function drawKey (keyId, xPos, yPos)
            key = display.newRoundedRect(keysGroup, xPos, yPos, KEY_WIDTH, KEY_HEIGHT, 12)
            key.fill = KEY_COLORS[keyId]
            key.number = keyId
            table.insert( keysArray, keyId, key) 
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
            print("hm", completedLevel)
            composer.gotoScene( 'scenes.review', { params={ songId = songId, result = params.result, currentLevel = level, nextLevel = params.nextLevel, description = params.description} } ) 
        end

        function compareKeys (keyPressed) -- Compares the keyId of key pressed by user with the keyId in the same index ( using keyIndex defined above ) in the songNotes array 
            userKeyIndex = userKeyIndex + 1 -- everytime a key is pressed the key index is incremented
            if (userKeyIndex ~= paceKeyIndex and gameInProgress) then
                delayExit = timer.performWithDelay (500, onEndLevel)
                delayExit.params = { result = 'fail', description = 'OH NO, YOU WERE OFF BEAT', nextLevel = level}
            elseif (keyPressed ~= songNotes[userKeyIndex] ) then
                delayExit = timer.performWithDelay (500, onEndLevel)
                delayExit.params = { result = 'fail', description = 'OH NO, YOU PLAYED THE WRONG NOTE', nextLevel = level}
            elseif (userKeyIndex == #songNotes and gameInProgress) then 
                if level < 5 then
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