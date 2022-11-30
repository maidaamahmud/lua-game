local composer = require( "composer" )
 
local scene = composer.newScene()

-- local function onDemoButtonRelease (event) --FIXME: should this be here 
--     demoButton:removeSelf()
--     startButton = widget.newButton( startButtonProps )
--     playDemo()
-- end 

-- local function onStartButtonRelease (event) --FIXME: should this be here 
--     startButton:removeSelf()
--     composer.hideOverlay( "fade", 400 )
-- end 

-- demoButtonProps = 
-- {
--     parent = sceneGroup, --FIXME: add new group for song title    
--     x = display.contentCenterX,
--     y = display.contentCenterY - 30,
--     label = "Play Demo", --FIXME: add play icon
--     labelAlign = "center",
--     labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
--     font = native.systemFont,
--     fontSize = 20,
--     onRelease = onDemoButtonRelease
-- }

-- startButtonProps = 
-- {
--     parent = sceneGroup, --FIXME: add new group for song title    
--     x = display.contentCenterX,
--     y = display.contentCenterY - 30,
--     label = "Start Game", 
--     labelAlign = "center",
--     labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
--     font = native.systemFont,
--     fontSize = 20,
--     onRelease = onPlayButtonRelease
-- }

function scene:create( event )
 
    local sceneGroup = self.view
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
   
    elseif ( phase == "did" ) then
         print ('fn_ did show')
    end
end
 
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        print ('fn_ did hide')
 
    elseif ( phase == "did" ) then
        print ('fn_ did hide')
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    print ('fn_ destroy')
end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene