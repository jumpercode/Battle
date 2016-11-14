globalEvs = {}

globalEvs.isGameOver = false
globalEvs.px = 0
globalEvs.py = 0
globalEvs.fire = false
globalEvs.movs = {}
globalEvs.cols = {}

function globalEvs.finishAnim( event )
    if ( event.phase == "ended" ) then
        event.target:removeSelf()
    end
end

function globalEvs.onKey(event)

    if(event.keyName == 'space' and event.phase == 'down') then
        globalEvs.fire = true
    elseif(event.keyName == 'space' and event.phase == 'up') then
        globalEvs.fire = false
    elseif(event.keyName == 'left' and event.phase == 'down') then
        table.insert( globalEvs.movs, 1, "toleft" )
    elseif(event.keyName == 'left' and event.phase == 'up') then
        for i,v in ipairs(globalEvs.movs) do
            if(v == "toleft") then
                table.remove( globalEvs.movs, i )
            end
        end
    elseif(event.keyName == 'right' and event.phase == 'down') then
        table.insert( globalEvs.movs, 1, "toright" )
    elseif(event.keyName == 'right' and event.phase == 'up') then
        for i,v in ipairs(globalEvs.movs) do
            if(v == "toright") then
                table.remove( globalEvs.movs, i )
            end
        end
    end
end

function globalEvs.onCollision( event )

    if ( event.phase == "began" ) then

        local ob1 = event.object1
        local ob2 = event.object2

        if(
            (ob1.obName == "ThePlayer" and ob2.obName == "TheBoosShoot") or
            (ob1.obName == "TheBoos" and ob2.obName == "ThePlayerShoot") or
            (ob1.obName == "TheBoosShoot" and ob2.obName == "ThePlayerShoot") or
            (ob1.obName == "ThePlayerShoot" and ob2.obName == "TheBoosShoot") or
            (ob1.obName == "ThePlayerShoot" and ob2.obName == "TheBoosShield") or
            (ob1.obName == "TheBoosShield" and ob2.obName == "ThePlayerShoot")
        ) then
            table.insert( globalEvs.cols, {ob1, ob2} )
        end

    end
end
