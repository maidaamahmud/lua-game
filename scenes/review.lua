local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()

local function onMenuButtonRelease (event) --FIXME: should this be here 
    composer.gotoScene( 'scenes.menu' )
end 

local function onRetryButtonRelease (event) --FIXME: should this be here 
    composer.gotoScene( 'scenes.game', { params = { songId = songId } } )
end 

menuButtonProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title    
    x = display.contentCenterX + 100,
    y = display.contentCenterY + 40,
    label = "Go to Menu", 
    labelAlign = "center",
    labelColor = { default={ 1, 1, 1 } },
    font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
    fontSize = 35,
    onRelease = onMenuButtonRelease
}

retryButtonProps = 
{
    parent = sceneGroup, --FIXME: add new group for song title    
    x = display.contentCenterX - 100,
    y = display.contentCenterY + 40,
    label = "Play Again", 
    labelAlign = "center",
    labelColor = { default={ 1, 1, 1 } },
    font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
    fontSize = 35,
    onRelease = onRetryButtonRelease
}

local resultTextProps = 
{
    parent = sceneGroup, --FIXME: add group to add subtitle
    text = "oye",     
    x = display.contentCenterX,
    y = display.contentCenterY - 60,
    font =  'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
    fontSize = 50,
    align = "center"
}

function scene:create( event )
    local sceneGroup = self.view
    songId = event.params.songId
    result = event.params.result

    print("chweck", result, songId)

    menuButton = widget.newButton( menuButtonProps )
    retryButton = widget.newButton( retryButtonProps )
    
    resultText = display.newText( resultTextProps ) 

    if (result == 'pass') then
    resultText.text = "PASSED"
    resultText:setFillColor( 0.7, 1, 0.6 )
    else
    resultText.text = "FAILED"   
    resultText:setFillColor( 1, 0.4, 0.4 )
    end

end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
    end
end
 
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
 
    elseif ( phase == "did" ) then
        composer.removeScene( "scenes.review")
    end
end
 
 
-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    menuButton:removeSelf()
    menuButton = nil

    retryButton:removeSelf()
    retryButton = nil

    resultText:removeSelf()
    resultText = nil
end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene