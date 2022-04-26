local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW007-panelty", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "분노", "EntityDamageEvent", 400)
end

function onEvent(funcTable)
	if funcTable[1] == "MW007-panelty" then panelty(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "분노" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then damaged(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function panelty(LAPlayer, event, ability, id)
	if event:getItem():getType():toString() == "COOKED_RABBIT" or event:getItem():getType():toString() == "RABBIT" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
			event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
		end
	end
end

function onTimer(player, ability)
	if player:getVariable("MW007-passiveCount") == nil then player:setVariable("MW007-passiveCount", 0) end
	local count = player:getVariable("MW007-passiveCount")
	addEffect(player, count)
	if count >= 600 then count = 0 end
	count = count + 1
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
	local damager = util.getRealDamager(event:getDamager())
	if event:getCause():toString() == "PROJECTILE" and event:getDamager():getShooter() ~= nil then damager = event:getDamager():getShooter() end
	
	if damager ~= nil and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
		if util.random(100) <= 10 and game.getPlayer(damagee):getVariable("MW007-redrum") ~= true then 
			if game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
				game.getPlayer(damagee):setVariable("MW007-redrum", true)
				damagee:getWorld():spawnParticle(import("$.Particle").REDSTONE, damagee:getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
				damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_RABBIT_ATTACK, 0.5, 1)
			end
		end
	end
end