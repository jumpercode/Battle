-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

require "src.global.events"

physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local atac = display.newGroup()
local main = display.newGroup()
local efec = display.newGroup()
local mark = display.newGroup()

local factoryPlayer = require "src.ships.player"
local factoryBoss = require "src.ships.boss"

local player = factoryPlayer:create(atac, main, efec, 400, 540)
local boss = factoryBoss:create(atac, main, efec, 400, 120)

local dphp = display.newText( mark, "PLAYER HP: "..player.hp, 70, 20, 120, 20, native.systemFontBold, 12 )
dphp:setFillColor( 1, 0, 0 )

local dppp = display.newText( mark, "PLAYER PP: "..player.pp, 70, 40, 120, 20, native.systemFontBold, 12 )
dppp:setFillColor( 0, 1, 0 )

local dbhp = display.newText( mark, "BOOS HP: "..boss.hp, 720, 20, 150, 20, native.systemFontBold, 12 )
dbhp:setFillColor( 1, 0, 0 )

local dbpp = display.newText( mark, "BOOS PP: "..boss.pp, 720, 40, 150, 20, native.systemFontBold, 12 )
dbpp:setFillColor( 0, 1, 0 )

local dbmd = display.newText( mark, "BOOS MD: ", 720, 60, 150, 20, native.systemFontBold, 12 )
dbmd:setFillColor( 0, 0, 1 )

local function updateMarks()

    dphp.text = "PLAYER HP: "..player.hp
    dppp.text = "PLAYER PP: "..player.pp

    dbhp.text = "BOOS HP: "..boss.hp
    dbpp.text = "BOOS PP: "..boss.pp

    if(boss.modo == 1) then
        dbmd.text = "BOOS MD: OFFENSIVE"
    else
        dbmd.text = "BOOS MD: DEFENSIVE"
    end

end

local function gameLoop()

    updateMarks()

    if(not globalEvs.isGameOver) then

        for i,v in ipairs(globalEvs.cols) do

            if(v[2].x == nil) then v[2].x = -100 end
            if(v[2].y == nil) then v[2].y = -100 end
            if(v[2].height == nil) then v[2].height = 0 end

            if(v[1].obName == "TheBoos" and v[2].obName == "ThePlayerShoot") then
                boss:recDamage(v[2].power, v[2].x, (v[2].y-(v[2].height/2)))
                display.remove( v[2] )
            elseif(v[1].obName == "ThePlayer" and v[2].obName == "TheBoosShoot") then
                player:recDamage(v[2].power, v[2].x, (v[2].y+(v[2].height/2)))
                display.remove( v[2] )
            elseif((v[1].obName == "TheBoosShoot" and v[2].obName == "ThePlayerShoot") or (v[1].obName == "ThePlayerShoot" and v[2].obName == "TheBoosShoot")) then
                display.remove( v[1] )
                display.remove( v[2] )
            elseif(v[1].obName == "ThePlayerShoot" and v[2].obName == "TheBoosShield") then
                display.remove( v[1] )
            elseif(v[1].obName == "TheBoosShield" and v[2].obName == "ThePlayerShoot") then
                display.remove( v[2] )
            end
        end

        for i,v in ipairs(globalEvs.cols) do
            table.remove( globalEvs.cols, i )
        end

        player:actuar()

        globalEvs.px = player.x
        globalEvs.py = player.y

        boss:actuar()

    end

    updateMarks()

    --print(display.fps)

    if(globalEvs.isGameOver) then
        timer.cancel( globalEvs.master )
    end

end

globalEvs.master = timer.performWithDelay( 16, gameLoop, 0)

Runtime:addEventListener( "key", globalEvs.onKey )
Runtime:addEventListener( "collision", globalEvs.onCollision )
