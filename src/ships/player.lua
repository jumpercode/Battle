local builder = {}

function builder:create(bkgroup, group, frgroup, x, y)

    local ship = display.newImageRect( group, "res/img/play.png", 58, 100)
    physics.addBody( ship, "static")
    ship.x = x
    ship.y = y
    ship.obName = "ThePlayer"

    ship.bkgroup = bkgroup
    ship.frgroup = frgroup

    ship.hp = 1000                      -- Puntos de vida
    ship.pp = 100                       -- Puntos de energia
    ship.rec_pp = 2                     -- Puntos de energia recuperados
    ship.tim_pp = 100                   -- Demora para recuperar energia (ms)
    ship.max_pp = 100                   -- Maximo punto de energia

    ship.last_shoot = 0                 -- Tiempo del ultimo disparo
    ship.delay_shoot = 100              -- Demora minima entre disparos
    ship.power_shoot = 50               -- Daño causado por el disparo

    ship.exploder =  require "src.efect.explo"
    ship.hitter =  require "src.efect.hit"

    function ship:actuar()

        if(globalEvs.movs[1] == "toleft" and self.x >= 34) then
            self.x = self.x - 5
        elseif(globalEvs.movs[1] == "toright" and self.x <= 766) then
            self.x = self.x + 5
        end

        if(globalEvs.fire) then

            if(self.pp >= 10 and (system.getTimer()-self.last_shoot) >= self.delay_shoot) then

                self.pp = self.pp - 10

                local shoot = display.newImageRect( self.bkgroup, "res/img/shoot_3.png", 30, 55 )
                shoot.obName = "ThePlayerShoot"
                physics.addBody( shoot, "dynamic", { isSensor=true } )
                shoot.isBullet = true
                shoot.x = self.x
                shoot.y = self.y - 40
                shoot.power = self.power_shoot

                transition.to( shoot,
                {
                    y=-100,
                    time=500,
                    onComplete = function()
                        display.remove( shoot )
                    end
                } )

                self.last_shoot = system.getTimer()

            end
        end

    end

    function ship:recDamage(power, hx, hy)

        self.hp = self.hp-power

        local hit = self.hitter:create(self.frgroup, hx, hy)
        hit:run()

        if(self.hp <= 0) then
            self.hp = 0
            self:dead()
        end

    end

    function ship:dead()

        globalEvs.isGameOver = true

        timer.cancel( self.tim_ener )

        local explo = self.exploder:create(self.frgroup, self.x, self.y)
        explo:run()

        display.remove( self )

    end

    local function recEnergy()
        if(not globalEvs.fire) then
            local dif = ship.max_pp - ship.pp

            if(dif > 0 and dif >= ship.rec_pp) then
                ship.pp = ship.pp + ship.rec_pp
            elseif(dif > 0) then
                ship.pp = ship.pp + dif
            end
        end
    end

    ship.tim_ener = timer.performWithDelay(ship.tim_pp, recEnergy, 0)

    return ship

end

return builder
