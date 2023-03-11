local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

local songData = require( "global.songData" ) 
local globalFuncs = require( "global.functions" ) 

local widgetsToRemove = {}

function scene:create( event )
    local sceneGroup = self.view

    levelsGroup = display.newGroup()
    sceneGroup:insert(levelsGroup) 

    songID = event.params.songID

    readHighscores() --gives variable highscores (containg highscore for each song)
    
    local params = event.params
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
            if level > highscores[SONG_NAMES[songID]] then
                levelOption = widget.newButton({
                    parent = levelsGroup,
                    x = xPos,
                    y = yPos,
                    width = 50,
                    height = 50,
                    label = level, 
                    labelAlign = "center",
                    labelColor = { default={ 0.6, 0.6, 0.6 } }, 
                    font = 'fonts/GroupeMedium-8MXgn.otf',
                    fontSize = 30,
                })
            else
                levelOption = widget.newButton({
                    parent = levelsGroup,
                    x = xPos,
                    y = yPos,
                    width = 50,
                    height = 50,
                    label = level, 
                    labelAlign = "center",
                    labelColor = { default={ 1, 1, 1 } },
                    font = 'fonts/GroupeMedium-8MXgn.otf',
                    fontSize = 30,
                    onRelease = function() 
                        composer.gotoScene( 'scenes.game', { params = { songID = songID, level = level} } )
                    end,
                })
            end
            
            table.insert( widgetsToRemove, level, levelOption) 
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

    for i=#widgetsToRemove, 1, -1 do
        display.remove(widgetsToRemove[i])
    end

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene