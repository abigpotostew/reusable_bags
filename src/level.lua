-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

local sprite = require "sprite"
local class = require "src.class"
local util = require"src.util"
local collision = require "src.collision"

collision.SetGroups{"bird", "ammo", "ammoExplosion", "ground", "hut"}

local Level = class:makeSubclass("Level")


-------------------------------------------------------------------------------
-- Constructor

Level:makeInit(function(class, self)
	class.super:initWith(self)

	-- forward declarations and other locals
    self.screenW, self.screenH, self.halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5


    self.worldScale = display.contentWidth / self.width
	self.worldOffset = { x = 0, y = 0}

	self.worldGroup = display.newGroup()
	self.scene.view:insert(self.worldGroup)
	self.worldGroup.xScale = self.worldScale
	self.worldGroup.yScale = self.worldScale
    
    
	self.scene = storyboard.newScene()
	self.scene:addEventListener("createScene", self)
	self.scene:addEventListener("enterScene", self)
	self.scene:addEventListener("exitScene", self)
	self.scene:addEventListener("destroyScene", self)

	return self
end)



--------------------------------------------



-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
Level.createScene = Level:makeMethod(function(self, event)
	local group = self.view

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	local crate = display.newImageRect( "images/crate.png", 90, 90 )
	crate.x, crate.y = 160, -100
	crate.rotation = 15
	
	-- add physics to the crate
	physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "images/grass.png", screenW, 82 )
	grass:setReferencePoint( display.BottomLeftReferencePoint )
	grass.x, grass.y = 0, display.contentHeight
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( grass)
	group:insert( crate )
end)

-- Called immediately after scene has moved onscreen:
Level.enterScene = Level:makeMethod(function(self, event)
	local group = self.view
	
	physics.start()
	
end)

-- Called when scene is about to move offscreen:
Level.exitScene = Level:makeMethod(function(self, event)
	local group = self.view
	
	physics.stop()
	
end)

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
Level.destroyScene = Level:makeMethod(function(self, event)
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end)

-------------------------------------------------------------------------------
-- Getters and utility functions

Level.GetWorldGroup = Level:makeMethod(function(self)
	return self.worldGroup
end)

Level.GetScreenGroup = Level:makeMethod(function(self)
	return self.scene.view
end)

Level.GetWorldScale = Level:makeMethod(function(self)
	return self.worldScale
end)

Level.WorldToScreen = Level:makeMethod(function(self, x, y)
	return (x * self.worldScale + self.worldOffset.x), (y * self.worldScale + self.worldOffset.y)
end)

Level.ScreenToWorld = Level:makeMethod(function(self, x, y)
	return ((x - self.worldOffset.x) / self.worldScale), ((y - self.worldOffset.y) / self.worldScale)
end)

Level.GetWorldViewSize = Level:makeMethod(function(self)
	return self.width, self.height
end)

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene