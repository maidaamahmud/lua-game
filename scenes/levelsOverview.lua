local composer = require( "composer" )
local widget = require( "widget" )

-- import SONG_NAMES, SONG_NOTES, and LEVELS variables 
local songData = require( "global.songData" ) 

-- import drawStar and readHighscores functions
local globalFuncs = require( "global.functions" ) 

local scene = composer.newScene()

local levelOptionsArray = {}

function scene:create( event )
    local sceneGroup = self.view

    levelsGroup = display.newGroup()
    sceneGroup:insert(levelsGroup) 

    songID = event.params.songID

    readHighscores() --gives variable highscores (containg highscore for each song)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

        overviewTitle = display.newText({
            text = "Levels",     
            x = display.contentCenterX,
            y = 70,
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 35,
            align = "center"
        }) 

        toMenuButton = widget.newButton({
            x = display.contentCenterX,
            y = display.contentCenterY + 75,
            label = "Go to Menu", 
            labelAlign = "center",
            labelColor = { default={ 1, 1, 1 } },
            font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',
            fontSize = 30,
            onRelease = function() 
                composer.gotoScene( 'scenes.menu' )
            end
        })

        local function drawLevelOption (level, xPos, yPos)
            local levelOption = display.newText({
                text = level,
                x = xPos,
                y = yPos,
                width = 50,
                height = 50,
                align = "center",
                font = "fonts/GroupeMedium-8MXgn.otf",
                fontSize = 30
            })
            levelOption.number = level

            if level - 1 <= highscores[SONG_NAMES[songID]] then 
                -- if level is equal to or less than the highscore level + 1 
                -- (as the user can also play the level after the highest level they have reached) 
                -- the color of the text is white (symbolizing that is it clickable)
                levelOption:setFillColor(1, 1, 1)
            else
                -- otherwise the color of the text is light grey (symbolizing that it is not clickable)
                levelOption:setFillColor(0.6, 0.6, 0.6)
            end

            table.insert(levelOptionsArray, level, levelOption) 
        end

        local function drawLevelsMenu ()
            local SPACE_BETWEEN_OPTIONS = 80
            local xPos = display.contentCenterX - (#LEVELS * SPACE_BETWEEN_OPTIONS) / 2 + 50
            local yPos = display.contentCenterY
            for count = 1, #LEVELS do
                drawLevelOption(count, xPos, yPos - 20)
                xPos = xPos + SPACE_BETWEEN_OPTIONS
            end
        end

        drawLevelsMenu()

    elseif ( phase == "did" ) then
    local function onOptionTouch(event) 
            if event.phase == "began" then 
                if event.target.number - 1 <= highscores[SONG_NAMES[songID]] then
                    -- takes user to game for the clicked on level, if level has been unlocked
                    -- if level has not been unlocked, nothing happens when the level number is clicked
                    composer.gotoScene( 'scenes.game', { params = { songID = songID, level = event.target.number} } )
                end
            end
        end
        
        for level, levelOption in ipairs(levelOptionsArray) do
            levelOption:addEventListener("touch", onOptionTouch)
        end
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeScene( "scenes.levelsOverview" )
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    overviewTitle:removeSelf()
    overviewTitle = nil

    toMenuButton:removeSelf()
    toMenuButton = nil
    
    for level, levelOption in ipairs(levelOptionsArray) do
        levelOption:removeSelf() 
        levelOption = nil
    end

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene