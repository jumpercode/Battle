local builder = {}

function builder:create(bkgroup, group, frgroup, x, y)

    local ship = display.newImageRect( group, "res/img/boos.png", 146, 150)
    physics.addBody( ship, "static")
    ship.x = x
    ship.y = y
    ship.obName = "TheBoos"

    ship.bkgroup = bkgroup
    ship.frgroup = frgroup

    ship.modo = 1                       -- 1 - Ofensivo | 2 - Defensivo
    ship.last_des = -1200               -- Ultimo cambio de desision
    ship.delay_des = 1200               -- Demora para cambiar de desision
    ship.lMove = 0                      -- Ultimo movimiento
    ship.lAct = 0                       -- Ultima accion
    ship.acuDam = 0                     -- Daño acumulado
    ship.max_hp = 5000                  -- Maximos puntos de vida

    ship.hp = 5000                      -- Puntos de vida
    ship.pp = 500                       -- Puntos de energia
    ship.rec_pp = 12                     -- Puntos de energia recuperados
    ship.tim_pp = 100                   -- Demora para recuperar energia (ms)
    ship.last_pp = 0                    -- Ultima recuperacion de energia
    ship.max_pp = 500                   -- Maximo punto de energia

    ship.last_hshoot = 0                 -- Tiempo del ultimo disparo fuerte
    ship.delay_hshoot = 1500             -- Demora minima entre disparos fuertes
    ship.power_hshoot = 300               -- Daño causado por el disparo fuerte

    ship.last_sshoot = 0                 -- Tiempo del ultimo disparor rapido
    ship.delay_sshoot = 250              -- Demora minima entre disparos rapido
    ship.power_sshoot = 50               -- Daño causado por el disparo rapido

    ship.restore_max = 90                -- Ciclos Maximo de recuperacion
    ship.restore_res = 0                 -- Tiempo de recuperacion restante

    ship.shield_max = 180                 -- Ciclos Maximo de recuperacion
    ship.shield_res = 0                   -- Tiempo de recuperacion restante

    ship.special = nil                   -- Objeto grafico del movimiento especial

    ship.exploder =  require "src.efect.explo"
    ship.hitter =  require "src.efect.hit"

    function ship:recDamage(power, hx, hy)

        self.acuDam = self.acuDam + power

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

        timer.cancel( self.tim_inner )

        local explo = self.exploder:create(self.frgroup, self.x, self.y)
        explo:run()

        display.remove( self )

    end

    function ship:actuar()

        if((system.getTimer()-self.last_des) > self.delay_des) then

            local porPerDam = 0.1+(self.acuDam/self.max_hp)
            if porPerDam > 0.65 then porPerDam = 0.65 end

            local proModo = {ofensivo=(1.0-porPerDam), defensivo=1.0}

            local randes = math.random()
            if(randes >= 0 and randes <= proModo.ofensivo) then
                self.modo = 1
            else
                self.modo = 2
            end

            local proMov = {left=0.45, center=0.55, right=1.0}
            local playdir = self.x - globalEvs.px

            if(self.modo == 1) then
                if(playdir == 0) then
                    proMov = {left=0.1, center=0.9, right=1.0}
                elseif(playdir < 0) then
                    proMov = {left=0.1, center=0.2, right=1.0}
                else
                    proMov = {left=0.8, center=0.9, right=1.0}
                end
            else
                if(playdir == 0) then
                    proMov = {left=0.45, center=0.55, right=1.0}
                elseif(playdir < 0) then
                    proMov = {left=0.8, center=0.9, right=1.0}
                else
                    proMov = {left=0.1, center=0.2, right=1.0}
                end
            end

            local randes = math.random()
            if(randes >= 0 and randes < proMov.left) then
                self.lMove = 1
            elseif(randes >= proMov.left and randes < proMov.center) then
                self.lMove = 2
            else
                self.lMove = 3
            end

            local proAct = { wait=0.05, speedAt=0.50, hardAt=0.70, shield=0.90, restore=1.0 }

            if(self.modo == 2) then
                proAct = { wait=0.05, speedAt=0.30, hardAt=0.50, shield=0.80, restore=1.0 }
            end

            if(self.hp >=  math.floor(self.max_hp*0.75)) then
                proAct = { wait=0.05, speedAt=0.55, hardAt=0.85, shield=0.99, restore=1.0 }
            elseif(self.hp < math.floor(self.max_hp*0.30)) then
                proAct = { wait=0.10, speedAt=0.25, hardAt=0.40, shield=0.60, restore=1.0 }
            end

            if(self.pp < 200 and self.pp > 100) then
                proAct = { wait=0.30, speedAt=0.50, hardAt=0.65, shield=0.90, restore=1.0 }
            elseif(self.pp < 100) then
                proAct = { wait=0.50, speedAt=0.65, hardAt=0.70, shield=0.90, restore=1.0 }
            end

            local randes = math.random()
            if(randes >= 0 and randes < proAct.wait) then
                self.lAct = 1
            elseif(randes >= proAct.wait and randes < proAct.speedAt) then
                self.lAct = 2
            elseif(randes >= proAct.speedAt and randes < proAct.hardAt) then
                self.lAct = 3
            elseif(randes >= proAct.hardAt and randes < proAct.shield) then
                self.lAct = 4
            else
                self.lAct = 5
            end

            self.last_des = system.getTimer()

        end

        if(self.lMove == 1) then
            self:moveLeft()
        elseif(self.lMove == 2) then
            self:nada()
        elseif(self.lMove == 3) then
            self:moveRight()
        end

        if(self.special == nil) then
            if(self.lAct == 1) then
                self:nada()
            elseif(self.lAct == 2) then
                self:speedFire()
            elseif(self.lAct == 3) then
                self:hardFire()
            elseif(self.lAct == 4) then
                self:shield()
            elseif(self.lAct == 5) then
                self:restore()
            end
        end

    end

    function ship:nada()
        local pass = true
    end

    function ship:restore()
        if(self.pp >= 200 and self.special == nil) then
            self.special = 1
            self.pp = 0
            self.restore_res = self.restore_max
        end
    end

    function ship:shield()

        if(self.pp >= 100 and self.special == nil) then
            self.special = 1
            self.pp = self.pp - 100
            self.shield_res = self.shield_max
        end

    end

    function ship:speedFire()

        if(self.pp >= 25 and (system.getTimer()-self.last_sshoot) >= self.delay_sshoot) then

            self.pp = self.pp - 25

            for i=1,2 do

                local shoot = display.newImageRect( self.bkgroup, "res/img/shoot_1.png", 22, 88 )
                shoot.obName = "TheBoosShoot"
                physics.addBody( shoot, "dynamic", { isSensor=true } )
                shoot.isBullet = true

                if(i == 1) then
                    shoot.x = self.x-52
                else
                    shoot.x = self.x+52
                end

                shoot.y = self.y + 42
                shoot.power = self.power_sshoot

                transition.to( shoot,
                {
                    y=700,
                    time=300,
                    onComplete = function()
                        display.remove( shoot )
                    end
                } )
            end


            self.last_sshoot = system.getTimer()

        end

    end

    function ship:hardFire()

        if(self.pp >= 200 and (system.getTimer()-self.last_hshoot) >= self.delay_hshoot) then

            self.pp = self.pp - 200

            local shoot = display.newImageRect( self.bkgroup, "res/img/shoot_2.png", 62, 108 )
            shoot.obName = "TheBoosShoot"
            physics.addBody( shoot, "dynamic", { isSensor=true } )
            shoot.isBullet = true

            shoot.x = self.x

            shoot.y = self.y + 42
            shoot.power = self.power_hshoot

            transition.to( shoot,
            {
                y=700,
                time=2000,
                onComplete = function()
                    display.remove( shoot )
                end
            } )


            self.last_hshoot = system.getTimer()

        end

    end

    function ship:moveLeft()
        if(self.x >= 75) then
            self.x = self.x - 2
        end
    end

    function ship:moveRight()
        if(self.x <= 725) then
            self.x = self.x + 2
        end
    end

    local function innerLoop()

        if(ship.restore_res == 0) then

            if((system.getTimer()-ship.last_pp) >= ship.tim_pp) then
                local dif = ship.max_pp - ship.pp

                local incpp = 0
                if(ship.shield_res == 0) then
                    incpp = ship.rec_pp
                else
                    incpp = math.floor(ship.rec_pp / 2)
                end

                if(dif > 0 and dif >= incpp) then
                    ship.pp = ship.pp + incpp
                elseif(dif > 0) then
                    ship.pp = ship.pp + dif
                end

                ship.last_pp = system.getTimer()

            end

        elseif(ship.restore_res == ship.restore_max) then

            ship.special = display.newImageRect( ship.frgroup, "res/img/spark.png", 400, 400 )
            ship.special.x = ship.x
            ship.special.y = ship.y
            ship.restore_res = ship.restore_res - 1

        elseif(ship.restore_res < ship.restore_max and ship.restore_res > 1) then

            ship.special.x = ship.x
            ship.special:rotate(1)

            if(ship.hp < 7000) then
                local inc = math.floor(ship.hp*0.0025)
                if(ship.hp + inc < 7000) then
                    ship.hp = ship.hp+inc
                else
                    ship.hp = 7000
                end
            end

            ship.restore_res = ship.restore_res - 1

        elseif(ship.restore_res == 1) then

            display.remove(ship.special)
            ship.special = nil
            ship.restore_res = 0

        end

        if(ship.shield_res == ship.shield_max) then

            ship.shield_res = ship.shield_res - 1

            ship.special = display.newImageRect( ship.frgroup, "res/img/shield.png", 220, 220 )
            ship.special.obName = "TheBoosShield"
            physics.addBody( ship.special,  "static", { radius=125 } )
            ship.special.x = ship.x
            ship.special.y = ship.y

        elseif(ship.shield_res < ship.shield_max and ship.shield_res > 1) then

            ship.special.x = ship.x
            ship.special:rotate(1)

            ship.shield_res = ship.shield_res - 1

        elseif(ship.shield_res == 1) then

            display.remove(ship.special)
            ship.special = nil
            ship.shield_res = 0

        end

    end

    ship.tim_inner = timer.performWithDelay(16, innerLoop, 0)

    return ship

end

return builder
