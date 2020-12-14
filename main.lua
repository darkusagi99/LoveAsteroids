
function love.load()
	-- Chargement des éléments du jeu
	playerShip = love.graphics.newImage("resources/player.png")
	
	-- Definition des variables globales
	version = 0.001
	screenWidth, screenHeight = love.graphics.getDimensions( )
	playerX = screenWidth / 2
	playerY = screenHeight / 2
	playerSpeedX = 0
	playerSpeedY = 0
	playerR = math.pi / 2
	playerSize = 64
	
	vitesseR = 10
	vitesseMax = 100
	
	vitesseTir = 500
	dureeTir = 4
	currVies = 2
	
	tirs = {}
	
	love.graphics.setFont(love.graphics.newFont(32))
	score = 0
	nbTirMax = 8
	
end

function love.draw()

	for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * screenWidth, y * screenHeight)
			
			-- RAZ des couleurs
			love.graphics.setColor(255, 255, 255, 255)

			-- Dessiner la vaisseau
			love.graphics.draw(playerShip, playerX, playerY, playerR, 1, 1, playerSize, playerSize)
	
			-- Tirs
			for tirIndex, tir in ipairs(tirs) do
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle('fill', tir.x, tir.y, 5)
            end
	
			-- TODO Asteroides

	

			-- nombre de vies
			for nbVies = 0, currVies do
				
				-- RAZ des couleurs
				love.graphics.setColor(255, 255, 255, 255)

				-- Dessiner la vaisseau our les vies
				love.graphics.draw(playerShip, nbVies * playerSize, screenHeight, (1.5 * math.pi), 0.25, 0.25,  - (playerSize), -(playerSize))

			end
			
			-- TODO Score
			love.graphics.print("Score  : " .. score, screenWidth, screenHeight, 0, 1, 1, screenWidth / 4, 50)
			
	    end
    end
	
end


function love.update(dt)

	-- Rotation vers la droite
	if love.keyboard.isDown('right') then
         playerR = playerR + vitesseR * dt
    end
	
	-- Idem vers la gauche
	if love.keyboard.isDown('left') then
         playerR = playerR - vitesseR * dt
    end
	
	-- Limiter entre 0 et 2Pi (Radians)
	playerR = playerR % (2 * math.pi)

	-- Déplacement vaisseau
	-- Calul de la vitesse
	if love.keyboard.isDown('up') then
        local vitesseMax = 100
        playerSpeedX = playerSpeedX + math.cos(playerR) * vitesseMax * dt
        playerSpeedY = playerSpeedY + math.sin(playerR) * vitesseMax * dt
    end

	-- Calcul de la nouvelle position du vaisseau
    playerX = (playerX + playerSpeedX * dt) % screenWidth
    playerY = (playerY + playerSpeedY * dt) % screenHeight
	
	-- Calcul du déplacement des tirs
    for tirIndex, tir in ipairs(tirs) do
	
		-- On retire du temps de vie au tir
		tir.duree = tir.duree - dt
	
		-- Si temps de tir = 0, suppression
		if tir.duree <= 0 then
			table.remove(tirs, tirIndex)
		else
		-- Sinon déplacement
			tir.x = (tir.x + math.cos(tir.r) * vitesseTir * dt) % screenWidth
			tir.y = (tir.y + math.sin(tir.r) * vitesseTir * dt) % screenHeight
		end
    end

end

-- Fonction de détection des touches
function love.keypressed(key)

	-- ECHAP => Fermeture programme
	if key == 'escape' then
		love.event.quit()
	end
	
	-- ESPACE => Tir
	 if key == 'space' and #tirs < nbTirMax then
        table.insert(tirs, {
			x = playerX + math.cos(playerR) * playerSize,
            y = playerY + math.sin(playerR) * playerSize,
			r = playerR,
			duree = dureeTir
        })
    end
	
end