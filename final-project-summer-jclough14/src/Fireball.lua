--[[
    GD50
    Super Mario Bros. Remake

    -- Fireball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

FINAL ASSIGNMENT - JONATHAN CLOUGH

]]

Fireball = Class{__includes = GameObject}

function Fireball:init(player, gravity)

    GameObject.init(self, 

	{   x = player.x,
	    y = player.y,
	    texture = 'fireball',
	    width = 16,
	    height = 16,
	    frame = 4,
	    solid = false,
	    collidable = true,
	    consumable = false,
	    onCollide = function() end,
	    onConsume = function() end,
	}
	)
	self.directionMultiplier = player.direction == 'left' and -1 or 1
	self.rotation = 0
	self.player = player
	self.gravity = gravity
	self.dy = 0
    self.timeToLive = 5

end

function Fireball:render()

	love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x + 8, self.y + 8, self.rotation, self.directionMultiplier * .5, .5, 8, 8)

end

function Fireball:update(dt)

    -- decrementing timeToLive
    self.timeToLive = self.timeToLive - dt

    -- set rotation
	self.rotation = self.rotation + 12 * dt * self.directionMultiplier

    -- motion	
	self.x = self.x + PLAYER_WALK_SPEED * 1.8 * dt * self.directionMultiplier

    self.dy = self.dy + self.gravity
    self.y = self.y + (self.dy * dt)

    -- Check collisions with walls and reversing direction
	if self.directionMultiplier == -1 and self:checkLeftCollisions(dt) then
 		self.directionMultiplier = 1
 	elseif self.directionMultiplier == 1 and self:checkRightCollisions(dt) then
 		self.directionMultiplier = -1
	end
	
	local collided = false

    -- remove snails if hit
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self) then
            gSounds['kill']:play()
            gSounds['kill2']:play()
            self.player.score = self.player.score + 100
            table.remove(self.player.level.entities, k)

            collided = true
        end
    end

    -- removing fireball if it hits a snail
    if collided == true or self.timeToLive <= 0 then
		for k, object in pairs(self.player.level.objects) do
        	if object == self then
            	table.remove(self.player.level.objects, k)
        	end
    	end
    end

    -- look at two tiles below our feet and check for collisions
    local tileBottomLeft = self.player.map:pointToTile(self.x + 1 + 4, self.y + self.height * .75)
    local tileBottomRight = self.player.map:pointToTile(self.x + self.width - 1 - 4, self.y + self.height * .75)


    -- if we get a collision beneath us, bounce
    if (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() and tileBottomRight:collidable()) then
        self.dy = self.player.height * -3
      	self.y = (tileBottomLeft.y - 1) * TILE_SIZE - self.height
    end

    -- check for object collisions below
    self.y = self.y + 1

    local collidedObjects = self:checkObjectCollisions()

    self.y = self.y - 1

    if #collidedObjects ~= 0 then
        self.dy = self.player.height * -3
    end
end

function Fireball:checkLeftCollisions(dt)
    -- check for left two tiles collision
    local tileTopLeft = self.player.map:pointToTile(self.x + 1 + 4, self.y + 1 + 4)
    local tileBottomLeft = self.player.map:pointToTile(self.x + 1 + 4, self.y + self.height - 1)

    -- place player outside the X bounds on one of the tiles to reset any overlap
    if (tileTopLeft and tileBottomLeft) and (tileTopLeft:collidable() and tileBottomLeft:collidable()) then
        self.x = (tileTopLeft.x - 1) * TILE_SIZE + tileTopLeft.width - 1 
        return true
    else
        
    -- allow us to walk atop solid objects even if we collide with them
        self.y = self.y - 1
        local collidedObjects = self:checkObjectCollisions()
        self.y = self.y + 1

        -- reset X if new collided object
        if #collidedObjects > 0 then
            return true--self.x = self.x + PLAYER_WALK_SPEED * dt
        end--]]
        return false
    end
end

function Fireball:checkRightCollisions(dt)
    -- check for right two tiles collision
    local tileTopRight = self.player.map:pointToTile(self.x + self.width - 1 - 4, self.y + 1 + 4)
    local tileBottomRight = self.player.map:pointToTile(self.x + self.width - 1 -4, self.y + self.height - 1)

    -- place player outside the X bounds on one of the tiles to reset any overlap
    if (tileTopRight and tileBottomRight) and (tileTopRight:collidable() and tileBottomRight:collidable()) then
        self.x = (tileTopRight.x - 1) * TILE_SIZE - self.width
    return true
	else
        
    -- allow us to walk atop solid objects even if we collide with them
    self.y = self.y - 1
    local collidedObjects = self:checkObjectCollisions()
    self.y = self.y + 1

        -- bounce if new collided object
        if #collidedObjects > 0 then
            return true
        end
        
        return false
    end
end

function Fireball:checkObjectCollisions()
    local collidedObjects = {}

    for k, object in pairs(self.player.level.objects) do
        if object:collides(self) then
            if object.solid then
                table.insert(collidedObjects, object)
            end
        end
    end

    return collidedObjects
end

























--	    self.player.dy = self.player.dy + self.gravity
--	    self.player.y = self.player.y + (self.player.dy * dt)

	    -- look at two tiles below our feet and check for collisions
--    local tileBottomLeft = self.player.map:pointToTile(self.player.x + 1, self.player.y + self.player.height)
--	    local tileBottomRight = self.player.map:pointToTile(self.player.x + self.player.width - 1, self.player.y + self.player.height)

	    -- if we get a collision beneath us, go into either walking or idle
--	    if (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) then
--	        self.player.dy = 0
	        

--	        self.player.y = (tileBottomLeft.y - 1) * TILE_SIZE - self.player.height
	    
	    -- go back to start if we fall below the map boundary
	--    elseif self.player.y > VIRTUAL_HEIGHT then
	  --      gSounds['death']:play()
	    --    gStateMachine:change('start')
	    
	--[[    -- check side collisions and reset position
	    if self.directionMultiplier == -1 and Player.checkLeftCollisions(self, dt) then

	    elseif love.keyboard.isDown('right') then
	        self.player.direction = 'right'
	        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
	        self.player:checkRightCollisions(dt)
	    end

	    -- check if we've collided with any collidable game objects
	    for k, object in pairs(self.player.level.objects) do
	        if object:collides(self.player) then
	            if object.solid then
	                self.player.dy = 0
	                self.player.y = object.y - self.player.height

	                if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
	                    self.player:changeState('walking')
	                else
	                    self.player:changeState('idle')
	                end
	            elseif object.consumable then
	                object.onConsume(self.player)
	                table.remove(self.player.level.objects, k)
	            end
	        end
	    end

	    -- check if we've collided with any entities and kill them if so
	    for k, entity in pairs(self.player.level.entities) do
	        if entity:collides(self.player) then
	            gSounds['kill']:play()
	            gSounds['kill2']:play()
	            self.player.score = self.player.score + 100
	            table.remove(self.player.level.entities, k)
	        end
	    end
	end--]]