local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW014-damaged", "EntityDamageEvent", 1200)
	plugin.registerEvent(abilityData, "MW014-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW014-damaged" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then damaged(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW014-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	addEffect(player, count)
end

function addEffect(player)
	if player:getPlayer():getEquipment():getBoots() ~= nil and
	player:getPlayer():getEquipment():getHelmet() ~= nil and
	player:getPlayer():getEquipment():getLeggings() ~= nil and
	player:getPlayer():getEquipment():getChestplate() ~= nil then
		if string.find(player:getPlayer():getEquipment():getBoots():getType():toString(), "GOLDEN") and
		string.find(player:getPlayer():getEquipment():getHelmet():getType():toString(), "GOLDEN") and
		string.find(player:getPlayer():getEquipment():getLeggings():getType():toString(), "GOLDEN") and
		string.find(player:getPlayer():getEquipment():getChestplate():getType():toString(), "GOLDEN") then
			player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.DAMAGE_RESISTANCE, 20, 0}))
		end
	end
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "ZOMBIFIED_PIGLIN" then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function damaged(event, ability, id)
	local damagee = event:getEntity()
	local damager = event:getDamager()
	if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
	
	if damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
		if game.checkCooldown(game.getPlayer(event:getEntity()), ability, id) then
			damagee:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 600, 1}))
			damagee:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 600, 0}))
			damagee:getWorld():spawnParticle(import("$.Particle").VILLAGER_ANGRY, damagee:getLocation():add(0,1,0), 20, 0.5, 1, 0.5, 0.05)
			damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_ZOMBIFIED_PIGLIN_ANGRY, 1, 1)
		end
	end
end