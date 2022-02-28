local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW020-track", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW020-track" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then track(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	addEffect(player)
end

function track(LAPlayer, event, ability, id)
	if (event:getCause():toString() == "PROJECTILE" or event:getCause():toString() == "ENTITY_ATTACK") and event:getEntity():getType():toString() == "PLAYER" then
		local damager = event:getDamager()
		if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
		
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 600, 1}))
			event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.DAMAGE_RESISTANCE, 400, 1}))
			
			if game.targetPlayer(LAPlayer, game.getPlayer(damager), false) then
				for i = 0, 4 do 
					util.runLater(function() 
						local vibration = newInstance("$.Vibration", { event:getEntity():getLocation(), newInstance("$.Vibration$Destination$EntityDestination", {damager}), 20})
						event:getEntity():getWorld():spawnParticle(import("$.Particle").VIBRATION, event:getEntity():getEyeLocation(), 1, 0.5, 1, 0.5, 1, vibration)
						event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").BLOCK_SCULK_SENSOR_CLICKING, 1, 0.3)
					end, i * 20)
				end
			end
		end
	end
end

function addEffect(player)
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 40, 0}))
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 20, 1}))
end