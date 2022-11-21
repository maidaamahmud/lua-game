
------ NOTE: KEY (WHEN USED FOR VARIABLE NAMES) REFRENCES THE KEYS OF THE PIANO ------
local composer = require( "composer" )
 
local scene = composer.newScene()

local keysArray = {}
local KEY_COLORS = {{0.9, 0.2, 0.2}, {1, 0.5, 0}, {1, 0.9, 0.2}, {0.7, 0.9, 0.4}, {0.5, 0.9, 0.9}, {0.3, 0.3, 0.8}, {0.4, 0.2, 0.7}, {1, 0.5, 0.7}}
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
function scene:create( event )
 
    local sceneGroup = self.view
   
    display.setDefault( 'background', 0.1 )
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

        local KEY_WIDTH = 70
        local KEY_HEIGHT = 140
        local NUM_OF_KEYS = 8
        local SPACING_BETWEEN_KEYS = 5.5
        local PIANO_WIDTH = (KEY_WIDTH + SPACING_BETWEEN_KEYS) * NUM_OF_KEYS

        local startingPosX = display.contentCenterX - (PIANO_WIDTH / 2 - (KEY_WIDTH + SPACING_BETWEEN_KEYS) / 2)
        local startingPosY = display.contentCenterY + 70

        local function drawKey (keyId, xPos, yPos)
            key = display.newRect(xPos, yPos, KEY_WIDTH, KEY_HEIGHT)
            key.fill = KEY_COLORS[keyId]
            key.number = keyId
            table.insert(keysArray, keyId, key)
        end

        local function drawPiano (xPos, yPos)

            for count = 1, NUM_OF_KEYS, 1 do
                drawKey(count, xPos, yPos)
                xPos = xPos + KEY_WIDTH + SPACING_BETWEEN_KEYS
            end
        end

        drawPiano(startingPosX, startingPosY)
 
    elseif ( phase == "did" ) then

        local function afterKeyTouch( event )
            local params = event.source.params
                params.keyTouchEvent.target.alpha = 1
        end

        local function onKeyTouch(event) 
            if event.phase == "began" then
                event.target.alpha = 0.5  
                local effectTimer = timer.performWithDelay( 300, afterKeyTouch )
                effectTimer.params = { keyTouchEvent = event }
            end
        end

        for index, key in ipairs(keysArray) do
            key:addEventListener("touch", onKeyTouch)
        end
         
    end
end
 
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        print ('game did hide')
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        print ('game did hide')
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    print ('game destroy')
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene