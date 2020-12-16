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
	currVies = -1
	
	tirs = {}
	
	love.graphics.setFont(love.graphics.newFont(32))
	score = 0
	nbTirMax = 8
	
	-- Definition des asteroides
	asteroids = {
        {
            x = 150,
            y = 150,
        },
        {
            x = screenWidth - 150,
            y = 150,
        },
        {
            x = screenWidth / 2,
            y = screenHeight - 150,
        },
    }
	
	asteroidRadius = 120
	tailleTir = 5
	
	-- Configuration des asteroides
	configAsteroides = {
        {
            vitesse = 120,
            rayon = 30,
			score = 800
        },
        {
            vitesse = 70,
            rayon = 50,
			score = 400
        },
        {
            vitesse = 50,
            rayon = 70,
			score = 200
        },
        {
            vitesse = 20,
            rayon = 120,
			score = 100
        }
    }
	
		-- Initialisation des directions
	for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.angle = love.math.random() * (2 * math.pi)
		asteroid.niveau = #configAsteroides
    end
	
	-- Gestion du joystick
	local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	lastbutton = "none"
	
end

function love.draw()

	if currVies >= 0 then
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
					love.graphics.circle('fill', tir.x, tir.y, tailleTir)
				end
		
				-- TODO Asteroides
				for asteroidIndex, asteroid in ipairs(asteroids) do
					love.graphics.setColor(1, 1, 0)
					love.graphics.circle('fill', asteroid.x, asteroid.y, configAsteroides[asteroid.niveau].rayon)
				end
		

				-- nombre de vies
				for nbVies = 0, currVies do
					
					-- RAZ des couleurs
					love.graphics.setColor(255, 255, 255, 255)

					-- Dessiner la vaisseau our les vies
					love.graphics.draw(playerShip, nbVies * playerSize, screenHeight, (1.5 * math.pi), 0.25, 0.25,  - (playerSize), -(playerSize))

				end
				
				-- Score
				love.graphics.print("Score  : " .. score, screenWidth, screenHeight, 0, 1, 1, screenWidth / 4, 50)
				
			end
		end
	else
	
		--local joysticks = love.joystick.getJoysticks()
		--for i, joystick in ipairs(joysticks) do
		--	love.graphics.print(joystick:getName(), 10, (i + 1) * 20)
		--end
		
		--love.graphics.print("Last gamepad button pressed: "..lastbutton, 10, 10)

		-- Texte 
		love.graphics.print("Appuyer sur Espace pour commencer", screenWidth / 4, screenHeight / 2, 0, 1, 1, 0, 0)
		
		-- Score
		love.graphics.print("Score  : " .. score, screenWidth, screenHeight, 0, 1, 1, screenWidth / 4, 50)
	end
	
end


function love.update(dt)

	-- Contrôle des collisions - Merci Pythagore
	local function checkCollision(aX, aY, aRadius, bX, bY, bRadius)
        return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
    end

	-- Rotation vers la droite
	if love.keyboard.isDown('right') or joystick:isGamepadDown("dpright") then
         playerR = playerR + vitesseR * dt
    end
	
	-- Idem vers la gauche
	if love.keyboard.isDown('left') or joystick:isGamepadDown("dpleft") then
         playerR = playerR - vitesseR * dt
    end
	
	-- Limiter entre 0 et 2Pi (Radians)
	playerR = playerR % (2 * math.pi)

	-- Déplacement vaisseau
	-- Calul de la vitesse
	if love.keyboard.isDown('up')  or joystick:isGamepadDown("dpup") then
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
	
	-- Calcul du déplacement des asteroides
	for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.x = (asteroid.x + math.cos(asteroid.angle)
            * configAsteroides[asteroid.niveau].vitesse * dt) % screenWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.angle)
            * configAsteroides[asteroid.niveau].vitesse * dt) % screenHeight
			
		-- Contrôle collisions avec le vaisseau
		if checkCollision(
            playerX, playerY, playerSize,
            asteroid.x, asteroid.y, configAsteroides[asteroid.niveau].rayon
        ) then
            newLife()
            break
        end
		
		-- Contrôle collisions avec les tirs
		for tirIndex, tir in ipairs(tirs) do
			if checkCollision(
				tir.x, tir.y, tailleTir,
				asteroid.x, asteroid.y, configAsteroides[asteroid.niveau].rayon
			) then
				-- Metttre à jour le score
				score = score + configAsteroides[asteroid.niveau].score
			
				-- Retirer le Tir
				table.remove(tirs, tirIndex)
				
				-- Générer de nouveaux asteroides
				if asteroid.niveau > 1 then
				
					local angle1 = love.math.random() * (2 * math.pi)
					local angle2 = (angle1 - 2*math.pi/3) % (2 * math.pi)
					local angle3 = (angle1 + 2*math.pi/3) % (2 * math.pi)
				
					table.insert(asteroids, {
						x = asteroid.x,
						y = asteroid.y,
						angle = angle1,
						niveau = asteroid.niveau - 1
					})
					
					table.insert(asteroids, {
						x = asteroid.x,
						y = asteroid.y,
						angle = angle2,
						niveau = asteroid.niveau - 1
					})
					
					
					table.insert(asteroids, {
						x = asteroid.x,
						y = asteroid.y,
						angle = angle3,
						niveau = asteroid.niveau - 1
					})
				end
				
				-- Retirer l'asteroid
				table.remove(asteroids, asteroidIndex)
				break
			end
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
	 if key == 'space' and currVies >= 0 and #tirs < nbTirMax then
        table.insert(tirs, {
			x = playerX + math.cos(playerR) * playerSize,
            y = playerY + math.sin(playerR) * playerSize,
			r = playerR,
			duree = dureeTir
        })
    end
	
	-- ESPACE => lancement partie
	 if key == 'space' and currVies < 0 then
        resetGame()
    end
	
end

-- Idem pour le Joystick
function love.gamepadpressed(joystick, button)
    lastbutton = button
	
	
	-- ESPACE => Tir
	 if button == 'a' and currVies >= 0 and #tirs < nbTirMax then
        table.insert(tirs, {
			x = playerX + math.cos(playerR) * playerSize,
            y = playerY + math.sin(playerR) * playerSize,
			r = playerR,
			duree = dureeTir
        })
    end
	
	-- ESPACE => lancement partie
	 if button == 'a' and currVies < 0 then
        resetGame()
    end
	
end

-- Fonction pour relancer la partie
function resetGame()

	currVies = 3
	score = 0
	newLife()

end



-- Fonction pour relancer la partie
function newLife()

	currVies = currVies - 1

	-- Definition des variables globales
	playerX = screenWidth / 2
	playerY = screenHeight / 2
	playerSpeedX = 0
	playerSpeedY = 0
	playerR = math.pi / 2
	
	tirs = {}
	
	-- Definition des asteroides
	asteroids = {
        {
            x = 150,
            y = 150,
        },
        {
            x = screenWidth - 150,
            y = 150,
        },
        {
            x = screenWidth / 2,
            y = screenHeight - 150,
        },
    }
	
	
	-- Initialisation des directions
	for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.angle = love.math.random() * (2 * math.pi)
		asteroid.niveau = #configAsteroides
    end

end


