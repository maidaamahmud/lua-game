local composer = require( "composer" )
-- import SONG_NAMES and SONG_NOTES variables 
local songData = require( "global.songData" ) 

local globalFuncs = require( "global.functions" ) 

local scene = composer.newScene()

local songOptionsArray = {}

function scene:create( event )
    local sceneGroup = self.view
    starsGroup = display.newGroup()
    sceneGroup:insert(starsGroup) 

    display.setDefault( 'background', 0.1 )

    readHighscores() --gives variable highscores (containg highscore for each song)
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        title = display.newText({
            text = "MAGIC KEYS",     
            x = display.contentCenterX,
            y = display.contentCenterY - 125,
            font =  'fonts/AlegreyaSans-Black.ttf',
            fontSize = 33,
            align = "center"
        }) 
        title:setFillColor( 0.7, 0.5, 1 )

        local function drawOption (id, xPos, yPos)
            local songOptionText = display.newText( {  
                text = "",  
                font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',   
                fontSize = 27,
                align = "center" 
            }) 
            songOptionText.x = xPos
            songOptionText.y = yPos
            songOptionText.anchorX = 0
            songOptionText.text= SONG_NAMES[id]
            songOptionText.number = id
            table.insert(songOptionsArray, id, songOptionText)
        end

        local function drawMenu (xPos, yPos)
            local SPACING_BETWEEN_OPTIONS = 45
            local xPosText = 100
            local yPos = display.contentCenterY - 60

            for countSong = 1, #SONG_NAMES, 1 do
                drawOption(countSong, xPosText , yPos)
                local starWidth = #LEVELS * 20
                xPosStar = display.contentWidth - 100 - starWidth
                for countStar = 1, #LEVELS do
                    drawStar(starsGroup, xPosStar + countStar  * 20, yPos, 9)
                end
                if highscores[SONG_NAMES[countSong]] then   
                    completedLevels = highscores[SONG_NAMES[countSong]]
                    for countStar = 1, completedLevels do
                        drawStar(starsGroup, xPosStar + countStar * 20, yPos, 9, "filled")
                    end
                end
                yPos = yPos + SPACING_BETWEEN_OPTIONS
            end
        end

        drawMenu()
 
    elseif ( phase == "did" ) then
        local function onOptionTouch(event) 
            if event.phase == "began" then 
                nextLevel = 1
                if highscores[event.target.text] then
                    nextLevel = highscores[event.target.text] + 1
                    if highscores[event.target.text] == #LEVELS then
                        composer.gotoScene( 'scenes.levelsOverview', { params = { songID = event.target.number} } )
                        return
                    end
                end
                composer.gotoScene( 'scenes.game', { params = { songID = event.target.number, level = nextLevel} } )
            end
        end
        
        for index, songOption in ipairs(songOptionsArray) do
            songOption:addEventListener("touch", onOptionTouch)
        end
    end
end
 
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeScene( "scenes.menu") 
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view

    title:removeSelf()
    title = nil
    
    for index, songOption in ipairs(songOptionsArray) do
        songOption:removeSelf() 
        songOption = nil
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene