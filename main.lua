local composer = require( 'composer' )
display.setStatusBar( display.HiddenStatusBar )
composer.gotoScene( 'scenes.menu', { time=1000, effects="crossFade" } )
-- composer.gotoScene( 'scenes.game', { time=1000, effects="crossFade" } )