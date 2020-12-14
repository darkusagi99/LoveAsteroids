-- Configuration générale du programme
function love.conf(t)
	-- Affichage plein écran
    t.window.fullscreen = true
	
	-- Desactivation de la physique
	t.modules.physics = true 
end