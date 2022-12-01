------ NOTE: KEY (WHEN USED FOR VARIABLE NAMES) REFRENCES THE KEYS OF THE PIANO ------
local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
-- import SONG_NAMES and SONG_NOTES variables 
local songData = require( "globalData.songData" ) 
 
local keysArray = {}
local KEY_COLORS = {{0.9, 0.2, 0.2}, {1, 0.5, 0}, {1, 0.9, 0.2}, {0.7, 0.9, 0.4}, {0.5, 0.9, 0.9}, {0.3, 0.3, 0.8}, {0.4, 0.2, 0.7}, {1, 0.5, 0.7}}

local keyIndex = 0
local demo = true

local function onDemoButtonRelease (event) --FIXME: should this be here 
    transition.fadeOut( demoButton, { time = 400 } )
    playDemo()
end 

local function onStartButtonRelease (event) --FIXME: should this be here 
    transition.fadeOut( startButton, { time = 400 } )
    keyIndex = 0 --FIXME: use better name
    demo = false 
    composer.hideOverlay()
end 

demoButtonProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title    
    x = display.contentCenterX,
    y = display.contentCenterY - 60 ,
    label = "Play Demo", --FIXME: add play icon
    labelAlign = "center",
    labelColor = { default = { 1, 1, 1 } },
    font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
    fontSize = 50,
    onRelease = onDemoButtonRelease
}

startButtonProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title and THESE PROPS ARE REPETITION
    x = display.contentCenterX,
    y = display.contentCenterY - 60,
    label = "Start Game", 
    labelAlign = "center",
    labelColor = { default = { 1, 1, 1 }},
    font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
    fontSize = 50,
    alpha = 0,
    onRelease = onStartButtonRelease
}

local songTitleTextProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title
    text = "",     
    x = display.contentCenterX,
    y = display.contentCenterY - 130,
    font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
    fontSize = 30,
    align = "center"
}

function scene:create( event )
    local sceneGroup = self.view
    songId = event.params.songId

    keysGroup = display.newGroup()

    sceneGroup:insert(keysGroup) 

    display.setDefault( 'background', 0.1 )

    composer.showOverlay( "scenes.demo", { isModal = true } )

    songTitle = display.newText( songTitleTextProps ) 
    songTitle.text = SONG_NAMES[songId]

    songNotes = SONG_NOTES[songId]

end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        local KEY_WIDTH = 65
        local KEY_HEIGHT = 140
        local NUM_OF_KEYS = 8
        local SPACING_BETWEEN_KEYS = 5.5
        local PIANO_WIDTH = (KEY_WIDTH + SPACING_BETWEEN_KEYS) * NUM_OF_KEYS

        local function drawKey (keyId, xPos, yPos)
            key = display.newRoundedRect(keysGroup, xPos, yPos, KEY_WIDTH, KEY_HEIGHT, 12)
            key.fill = KEY_COLORS[keyId]
            key.number = keyId
            table.insert(keysArray, keyId, key)
        end

        local function drawPiano ()
        local xPos = display.contentCenterX - (PIANO_WIDTH / 2 - (KEY_WIDTH + SPACING_BETWEEN_KEYS) / 2)
        local yPos = display.contentCenterY + 70

            for count = 1, NUM_OF_KEYS, 1 do
                drawKey(count, xPos, yPos)
                xPos = xPos + KEY_WIDTH + SPACING_BETWEEN_KEYS
            end
        end

        drawPiano()

        demoButton = widget.newButton( demoButtonProps )
 
    elseif ( phase == "did" ) then
        local function afterKeyTouch(event)
            local params = event.source.params
            params.keyTouchEvent.target.alpha = 1
        end

        local function onKeyTouch(event) 
            if event.phase == "began" then
                compareKeys(event.target.number)
                event.target.alpha = 0.5  
                local effectTimer = timer.performWithDelay( 250, afterKeyTouch )
                effectTimer.params = { keyTouchEvent = event }
            end
        end

        for index, key in ipairs(keysArray) do
            key:addEventListener("touch", onKeyTouch)
        end

        local function pressKey(event) 
            local params = event.source.params
            onKeyTouch({phase = "began", name = "touch", target = keysArray[params.key]})
        end

        local function createStartButton ()
            startButton = widget.newButton( startButtonProps )
        end
        
        function playDemo ()
            delay = 0;
            for index, keyNumber in ipairs(songNotes) do
                delay = delay + 500
                local delayBetweenNotes = timer.performWithDelay( delay, pressKey )
                delayBetweenNotes.params = { key = keyNumber }
            end
            
            timer.performWithDelay( 500 * #songNotes, createStartButton )
        end

        function endGame (event)
            local params = event.source.params
            composer.gotoScene( 'scenes.review', { params={ songId = songId, result = params.result } })
        end

        function compareKeys (keyPressed)
            keyIndex = keyIndex + 1
            if (keyPressed ~= songNotes[keyIndex]) then
                delayExit = timer.performWithDelay (500, endGame)
                delayExit.params = { result = 'fail' }
            elseif (keyIndex == #songNotes and demo == false) then
                delayExit = timer.performWithDelay (500, endGame)
                delayExit.params = { result = 'pass' }
            end
        end

    end
end
 
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        print ('game will hide')
 
    elseif ( phase == "did" ) then
        composer.removeScene( "scenes.game")
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view
    songTitle:removeSelf()
    songTitle = nil
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene