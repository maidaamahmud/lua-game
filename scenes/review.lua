local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")

local scene = composer.newScene()

local songData = require( "global.functions" ) 

function scene:create( event )
    local sceneGroup = self.view
    starsGroup = display.newGroup()

    sceneGroup:insert(starsGroup) 
    local params = event.params

    songId = params.songId
    result = params.result
    description = params.description
    currentLevel = params.currentLevel
    nextLevel = params.nextLevel
    completedLevel = nextLevel - 1

    highScoresFile = system.pathForFile("highscores.json", system.DocumentsDirectory)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

        local function onMenuButtonRelease () 
            composer.gotoScene( 'scenes.menu' )
        end 

        local function onGameButtonRelease () 
            composer.gotoScene( 'scenes.game', { params = { songId = songId, level = nextLevel} } )
        end 

        resultText = display.newText({
            text = "",     
            x = display.contentCenterX,
            y = display.contentCenterY - 80,
            font =  'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 55,
            align = "center"
        }) 

        descriptionText = display.newText({
            text = description,     
            x = display.contentCenterX,
            y = display.contentCenterY - 30 , 
            font = 'fonts/GroupeMedium-8MXgn.otf',
            fontSize = 20,
            align = "center"
        }) 

        menuButton = widget.newButton({
            x = display.contentCenterX - 100,
            y = display.contentCenterY + 60,
            label = "Go to Menu", 
            labelAlign = "center",
            labelColor = { default={ 1, 1, 1 } },
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            onRelease = onMenuButtonRelease
        })

        gameButton = widget.newButton({
            x = display.contentCenterX + 100,
            y = display.contentCenterY + 60,
            label = "", 
            labelAlign = "center",
            labelColor = { default={ 1, 1, 1 } },
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            onRelease = onGameButtonRelease
        })

        if completedLevel then
            local starWidth = completedLevel * 20
            local xPos = display.contentCenterX - starWidth / 2
            local yPos = display.contentCenterY + 20
            for count = 1, completedLevel do
                drawStar(starsGroup, xPos + (count - 0.5) * 20, yPos, 10)
            end
        end
        
        if (result == 'pass') then
            resultText:setFillColor( 0.7, 1, 0.6 )
            if (completedLevel < 5) then
                resultText.text = "PASSED"
                gameButton:setLabel("Next Level")
            else 
                resultText.text = "FAILED"
                gameButton:setLabel("Play Again")
            end
        else   
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