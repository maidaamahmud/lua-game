local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    local params = event.params
    songId = params.songId
    result = params.result
    level = params.level
    description = params.description
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

        local function onMenuButtonRelease () 
            composer.gotoScene( 'scenes.menu' )
        end 

        local function onGameButtonRelease () 
            composer.gotoScene( 'scenes.game', { params = { songId = songId, level = level} } )
        end 

        menuButton = widget.newButton({
            x = display.contentCenterX - 100,
            y = display.contentCenterY + 40,
            label = "Go to Menu", 
            labelAlign = "center",
            labelColor = { default={ 1, 1, 1 } },
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            onRelease = onMenuButtonRelease
        })

        gameButton = widget.newButton({
            x = display.contentCenterX + 100,
            y = display.contentCenterY + 40,
            label = "", 
            labelAlign = "center",
            labelColor = { default={ 1, 1, 1 } },
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            onRelease = onGameButtonRelease
        })

        resultText = display.newText({
            text = "",     
            x = display.contentCenterX,
            y = display.contentCenterY - 60,
            font =  'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 50,
            align = "center"
        }) 

        descriptionText = display.newText({
            text = description,     
            x = display.contentCenterX,
            y = display.contentCenterY - 20 , 
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 20,
            align = "center"
        }) 

        if (result == 'pass') then
            resultText.text = "PASSED"
            resultText:setFillColor( 0.7, 1, 0.6 )
            gameButton:setLabel("Next Level")
        else 
            resultText.text = "FAILED"   
            resultText:setFillColor( 1, 0.4, 0.4 )
            gameButton:setLabel("Try Again")
        end

    elseif ( phase == "did" ) then
        
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeScene( "scenes.review" )
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    menuButton:removeSelf()
    menuButton = nil

    gameButton:removeSelf()
    gxameButton = nil

    resultText:removeSelf()
    resultText = nil

    descriptionText:removeSelf()
    descriptionText = nil
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene