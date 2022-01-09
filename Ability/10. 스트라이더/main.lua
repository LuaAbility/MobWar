local effect = import("$.potion.PotionEffectType")

function Init(abilityData) end

function onTimer(player, ability)
	if player:getVariable("MW010-passiveCount") == nil then player:setVariable("MW010-passiveCount", 0) end
	local count = player:getVariable("MW010-passiveCount")
	if count == 20 then 
		count = 0
		addEffect(player)
	end
	count = count + 1
	player:setVariable("MW010-passiveCount", count)
end

function addEffect(player)
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.FIRE_RESISTANCE, 30, 0}))
	if player:getPlayer():getLocation():getBlock():getType():toString() == "WATER" or player:getPlayer():getLocation():getBlock():getType():toString() == "WATER_CAULDRON" then
		player:getPlayer():damage(1)
		player:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 50, 0.5, 1, 0.5, 0.05)
		player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_STRIDER_HURT, 0.25, 1)
	end
end