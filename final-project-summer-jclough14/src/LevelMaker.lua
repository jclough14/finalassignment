--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}
    local keypresent = false
    local keycolumn = math.random(width/2)
    local lockcolumn = math.random(width/2) + width/2
    local keyframe = math.random(#KEY_IDS)
    local lockobj

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        local specialcolumn = false
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        if x == keycolumn then
                
            specialcolumn = true

            table.insert(objects, GameObject {
                texture = 'keys-locks',
                x = (x - 1) * TILE_SIZE,
                y = (3) * TILE_SIZE,
                width = 16,
                height = 16,

                -- make it a random variant
                frame = keyframe,
                collidable = false,
                consumable = true,
                hit = false,
                solid = false,

                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    lockobj.consumable = true
                                    lockobj.solid = false
                end         
            })
        end

        if x == lockcolumn then
                
            specialcolumn = true

            lockobj = GameObject {
                texture = 'keys-locks',
                x = (x - 1) * TILE_SIZE,
                y = (3) * TILE_SIZE,
                width = 16,
                height = 16,

                -- make it a random variant
                frame = keyframe + #KEY_IDS,
                collidable = false,
                consumable = false,
                hit = false,
                solid = true,
   
            -- Insert Flagpole

                    onConsume = function(player, object)
                                    gSounds['pickup']:play()
                
                    local flagframe = math.random(4)
                    local poleframe = flagframe + 2

                     table.insert(objects, GameObject {
                     texture = 'flagpole',
                     x = (width-2) * TILE_SIZE,
                    y = (3) * TILE_SIZE,
                    width = 16,
                    height = 48,

                    -- make it a random variant
                    
                    frame = poleframe,
                    collidable = false,
                    consumable = true,
                    hit = false,
                    solid = false,

                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        gStateMachine:change('play', {
                                            width = width + 10, 
                                            score = player.score + 500,
                                            plevel = player.plevel + 1})
                   end,
 
                    onCollide = function ()
                    gSounds['pickup']:play()

                    end         
                     })

            -- Insert flag

                    table.insert(objects, GameObject {
                     texture = 'flags',
                     x = (width-2) * TILE_SIZE + TILE_SIZE/2,
                    y = (3) * TILE_SIZE + TILE_SIZE/3,
                    width = 16,
                    height = 16,

                    -- make it a random variant
                    frame = flagframe * 9 - 2,
                    collidable = false,
                    consumable = true,
                    hit = false,
                    solid = false,

                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        lockobj.consumable = true
                                        lockobj.solid = false
                    end         
                     })

                    end,         
                    
                    onCollide = function()

                    end

                    }
            
                    table.insert(objects, lockobj)
        
                    end

        -- chance to just be emptiness
       
        if x >1 and math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

        
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end
               
            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 and not specialcolumn then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                


                                else

                                    -- maintain reference so we can set it to nil
                                    local button = GameObject {
                                        texture = 'buttons',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = 3,
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            local duration = {fireDuration = 10}
                                            player:changepowerupState('fire', duration)
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [button] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, button)


                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end