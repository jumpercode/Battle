local builder = {}

function builder:create(group, x, y)

    local options =
    {
        width = 32,
        height = 32,
        numFrames = 16
    }

    local sequence = {
        {
            name = "explotar",
            start = 1,
            count = 16,
            time = 1000,
            loopCount = 1
        },
    }

    local imageSheet = graphics.newImageSheet( "res/img/minex.png", options )
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
