local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")

local scene = composer.newScene()

local songData = require( "global.songData" ) 
local globalFuncs = require( "global.functions" ) 

local function saveHighscore(highscores)
    filePath = system.pathForFile("highscores.json", system.DocumentsDirectory)
    local file = io.open( filePath, "w" )
    if file then
        file:write( json.encode( highscores ) )
        io.close( file )
    end
end

local function updateHighscore(songName, currentLevel)
    readHighscores()
    if (highscores[songName] == nil or currentLevel > highscores[songName]) then
        -- if highscore for the song does not exist, or if the current score is higher than the stored score, update entry
        highscores[songName] = currentLevel
        saveHighscore(highscores)
    end
end

function scene:create( event )
    local sceneGroup = self.view
    starsGroup = display.newGroup()
    sceneGroup:insert(starsGroup) 
    
    local params = event.params

    songID = params.songID
    songName = SONG_NAMES[songID]
    result = params.result
    description = params.description
    currentLevel = params.currentLevel
    nextLevel = params.nextLevel
    completedLevel = nextLevel - 1

    updateHighscore(songName, currentLevel)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

        local function onMenuButtonRelease () 
            composer.gotoScene( 'scenes.menu' )
        end 

        local function onGameButtonRelease () 
            composer.gotoScene( 'scenes.game', { params = { songID = songID, level = nextLevel} } )
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
                drawStar(starsGroup, xPos + (count - 0.5) * 20, yPos, 10, "filled")
            end
        end
        
        if (result == 'pass') then
            resultText.text = "PASSED"
            resultText:setFillColor( 0.7, 1, 0.6 )
            if (completedLevel < 5) then
                gameButton:setLabel("Next Level")
            else 
                gameButton:setLabel("Play Again")
            end
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