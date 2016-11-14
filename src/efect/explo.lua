local builder = {}

function builder:create(group, x, y)

    local options =
    {
        width = 240,
        height = 240,
        numFrames = 20
    }

    local sequence = {
        {
            name = "explotar",
            start = 1,
            count = 20,
            time = 2000,
            loopCount = 1
        },
    }

    local imageSheet = graphics.newImageSheet( "res/img/explo.png", options )
    local explo = display.newSprite( group, imageSheet, sequence )

    explo.isVisible = false
    explo.x = x
    explo.y = y
    explo:setSequence("explotar")
    explo:addEventListener( "sprite", globalEvs.finishAnim )

    function explo:run()
        self.isVisible = true
        self:play()
    end

    return explo

end

return builder
