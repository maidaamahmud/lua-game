local composer = require( 'composer' )
display.setStatusBar( display.HiddenStatusBar )
composer.gotoScene( 'scenes.game', { time=1000, effects="crossFade" } )