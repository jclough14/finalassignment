--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerNormalState = Class{__includes = BaseState}

function PlayerNormalState:init(player)
    self.player = player
    
end

function PlayerNormalState:enter(params)
    self.player.texture = 'green-alien'
end

function PlayerNormalState:update(dt)
    
end