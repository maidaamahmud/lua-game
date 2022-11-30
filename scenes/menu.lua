local composer = require( "composer" )
local scene = composer.newScene()
-- import SONG_NAMES and SONG_NOTES variables 
local songData = require( "globalData.songData" ) 

local songOptionsArray = {}

local subtitleTextProps = 
{
    parent = sceneGroup, --FIXME: add group to add subtitle
    text = "select a song to play",     
    x = display.contentCenterX,
    y = display.contentCenterY - 60,
    font = native.systemFont,
    fontSize = 17,
    align = "center"
}

local songOptionTextProps = 
{  
    parent = optionsGroup,
    text = "",  
    font = native.systemFontBold,   
    fontSize = 20,
    align = "center" 
}

function scene:create( event )
    local sceneGroup = self.view

    local optionsGroup = display.newGroup() 

    sceneGroup:insert(optionsGroup) 

    display.setDefault( 'background', 0.1 )

    subtitle = display.newText( subtitleTextProps ) 
    --subtitle:setFillColor( 1, 0, 0 )

    local titleImage = display.newImage(sceneGroup, "images/logo.png" ) --FIXME: add group to add title image
    titleImage:translate( display.contentCenterX, display.contentCenterY - 130 )
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        local SPACING_BETWEEN_OPTIONS = 55

        local function drawOption (id, xPos, yPos)
            local songOptionText = display.newText( songOptionTextProps ) 
            --songOption:setFillColor( 1, 0, 0 )
            songOptionText.x = xPos
            songOptionText.y = yPos
            songOptionText.text= SONG_NAMES[id]
            songOptionText.number = id
            table.insert(songOptionsArray, id, songOptionText)
        end

        local function drawMenu (xPos, yPos)
            local xPos = display.contentCenterX 
            local yPos = display.contentCenterY - 10

            for count = 1, #SONG_NAMES, 1 do
                drawOption(count, xPos, yPos)
                yPos = yPos + SPACING_BETWEEN_OPTIONS
            end
        end

        drawMenu()
 
    elseif ( phase == "did" ) then
        local function onOptionTouch(event) 
            if event.phase == "began" then
                composer.gotoScene( 'scenes.game', { time=1000, effects="crossFade", params={ songId=event.target.number }})
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
        print ('menu will hide')
 
    elseif ( phase == "did" ) then
        print ('menu did hide')
        composer.removeScene( "scenes.menu") -- FIXME: should menu scene be recycled?
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view
    subtitle:removeSelf()
    subtitle = nil
    for index, songOption in ipairs(songOptionsArray) do
        songOption:removeSelf() --FIXME: do by removing optionsGroup instead 
        songOption = nil
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene