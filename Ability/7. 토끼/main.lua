local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW007-damaged", "EntityDamageEvent", 400)
end

function onEvent(funcTable)
	if funcTable[1] == "MW007-damaged" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then damaged(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW007-passiveCount") == nil then player:setVariable("MW007-passiveCount", 0) end
	local count = player:getVariable("MW007-passiveCount")
	addEffect(player, count)
	if count >= 600 then count = 0 end
	count = count + 2
	player:setVariable("MW007-passiveCount", count)
end

function addEffect(player)
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.JUMP, 20, 1}))
	if player:getVariable("MW007-redrum") == true then player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 20, 0})) end
end

function addEffect(player, count)
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.JUMP, 20, 1}))
	if player:getVariable("MW007-redrum") == true then 
		player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 20, 0}))
		if count == 600 then player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.CONFUSION, 300, 0})) end
	end
end

function damaged(LAPlayer, event, ability, id)
	local damagee = event:getEntity()
	local damager = event:getDamager()
	if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
	
	if damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
		math.randomseed(os.time())
		if util.random(100) <= 10 and game.getPlayer(damagee):getVariable("MW007-redrum") ~= true then 
			if game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
				game.getPlayer(damagee):setVariable("MW007-redrum", true)
				damagee:getWorld():spawnParticle(import("$.Particle").REDSTONE, damagee:getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
				damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_RABBIT_ATTACK, 0.5, 1)
			end
		end
	end
end