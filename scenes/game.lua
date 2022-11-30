------ NOTE: KEY (WHEN USED FOR VARIABLE NAMES) REFRENCES THE KEYS OF THE PIANO ------
local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
-- import SONG_NAMES and SONG_NOTES variables 
local songData = require( "globalData.songData" ) 
 
local keysArray = {}
local KEY_COLORS = {{0.9, 0.2, 0.2}, {1, 0.5, 0}, {1, 0.9, 0.2}, {0.7, 0.9, 0.4}, {0.5, 0.9, 0.9}, {0.3, 0.3, 0.8}, {0.4, 0.2, 0.7}, {1, 0.5, 0.7}}

local function onDemoButtonRelease (event) --FIXME: should this be here 
    demoButton:removeSelf()
    startButton = widget.newButton( startButtonProps )
    playDemo()
end 

local function onStartButtonRelease (event) --FIXME: should this be here 
    startButton:removeSelf()
    composer.hideOverlay( "fade", 400 )
end 

demoButtonProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title    
    x = display.contentCenterX,
    y = display.contentCenterY - 30,
    label = "Play Demo", --FIXME: add play icon
    labelAlign = "center",
    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
    font = native.systemFont,
    fontSize = 20,
    onRelease = onDemoButtonRelease
}

startButtonProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title    
    x = display.contentCenterX,
    y = display.contentCenterY - 30,
    label = "Start Game", 
    labelAlign = "center",
    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
    font = native.systemFont,
    fontSize = 20,
    onRelease = onStartButtonRelease
}

local songTitleTextProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title
    text = "",     
    x = display.contentCenterX,
    y = display.contentCenterY - 130,
    font = native.systemFontBold,
    fontSize = 22,
    align = "center"
}

function scene:create( event )
    local sceneGroup = self.view
    local params = event.params

    keysGroup = display.newGroup()

    sceneGroup:insert(keysGroup) 

    display.setDefault( 'background', 0.1 )

    composer.showOverlay( "scenes.demo", { isModal = true } )

    songTitle = display.newText( songTitleTextProps ) 
    songTitle.text = SONG_NAMES[params.songId]

    songNotes = SONG_NOTES[params.songId]
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
            key = display.newRect(keysGroup, xPos, yPos, KEY_WIDTH, KEY_HEIGHT)
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

        function playDemo ()
            local delay = 0;
            for index, keyNumber in ipairs(songNotes) do
                delay = delay + 500
                local delayBetweenNotes = timer.performWithDelay( delay, pressKey )
                delayBetweenNotes.params = { key = keyNumber }
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
        print ('game did hide')
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view
    print ('game destroy')
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene