--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerFireState = Class{__includes = BaseState}

function PlayerFireState:init(player, gravity)
    self.player = player
    self.gravity = gravity
end

function PlayerFireState:enter(params)
    self.player.texture = 'fire-alien'
    self.fireDuration = params.fireDuration
end


function PlayerFireState:update(dt)

    if love.keyboard.wasPressed('f') then

        local fireball
            fireball = Fireball (self.player, self.gravity)
            table.insert(self.player.level.objects, fireball)
    end

    if self.fireDuration <= 0 then
    
          self.player:changepowerupState('normal')
    end
    
    self.fireDuration = self.fireDuration - dt

end