local composer = require( "composer" )

-- import SONG_NAMES, and LEVELS variables 
local songData = require( "global.songData" ) 

-- import drawStar and readHighscores functions
local globalFuncs = require( "global.functions" ) 

local scene = composer.newScene()

local songOptionsArray = {}

function scene:create( event )
    local sceneGroup = self.view

    starsGroup = display.newGroup()
    sceneGroup:insert(starsGroup) 

    display.setDefault( 'background', 0.1 )

    readHighscores() -- declares variable highscores (containg highscore (max level reached) for each song)
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

        local function drawSongOption (songID, xPos, yPos)
            local songOptionText = display.newText( {  
                text = SONG_NAMES[songID],  
                x = xPos,
                y = yPos,
                font = 'fonts/LoveGlitchPersonalUseRegular-vmEyA.ttf',   
                fontSize = 27,
            }) 
            songOptionText.number = songID
            songOptionText.anchorX = 0 -- left align text
            table.insert(songOptionsArray, songID, songOptionText)
        end

        local function drawSongsMenu (xPos, yPos)
            local SPACING_BETWEEN_OPTIONS = 45
            local xPosText = 100
            local yPos = display.contentCenterY - 60

            for countSong = 1, #SONG_NAMES, 1 do
                drawSongOption(countSong, xPosText , yPos)
                -- draw stars
                local starWidth = #LEVELS * 20
                local xPosStar = display.contentWidth - 100 - starWidth
                for countStar = 1, #LEVELS do -- draw outlined stars equal to the total number of levels
                    -- drawStar(group, x, y, size, style) 
                    drawStar(starsGroup, xPosStar + countStar  * 20, yPos, 9, "outlined")
                end
                if highscores then
                    if highscores[SONG_NAMES[countSong]] then -- draw filled stars equal to the number of levels completed
                        completedLevels = highscores[SONG_NAMES[countSong]]
                        for countStar = 1, completedLevels do
                            drawStar(starsGroup, xPosStar + countStar * 20, yPos, 9, "filled")
                        end
                    end
                end
              
                yPos = yPos + SPACING_BETWEEN_OPTIONS
            end
        end

        drawSongsMenu()
 
    elseif ( phase == "did" ) then
        local function onOptionTouch(event) 
            if event.phase == "began" then 
                -- when song is clicked on, it directs to the game, picking up from the level they were on (highscore level + 1)
                nextLevel = 1 -- if song does not exist in the highscores, it starts from level 1
                if highscores then
                    if highscores[event.target.text] then
                        -- if song is in highscores, the next level is highscore level + 1
                        nextLevel = highscores[event.target.text] + 1 
                        if highscores[event.target.text] == #LEVELS then 
                            -- if the highscore level is the final level, the user is instead directed to the levels overview screen
                            composer.gotoScene( 'scenes.levelsOverview', { params = { songID = event.target.number} } )
                            return
                        end
                    end
                end
                -- user is directed to game, starting on the appropriate level
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