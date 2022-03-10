local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW015-cancelBadEffect", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "MW015-cancelTarget", "EntityTargetEvent", 0)
	plugin.registerEvent(abilityData, "MW015-infectAbility", "PlayerDeathEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW015-cancelBadEffect" then cancelBadEffect(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW015-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW015-infectAbility" then infectAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelBadEffect(LAPlayer, event, ability, id)
	if event:getItem():getType():toString() == "ROTTEN_FLESH" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
			event:getPlayer():setFoodLevel(event:getPlayer():getFoodLevel() + 4)
			local itemStack = { newInstance("$.inventory.ItemStack", {event:getItem():getType(), 1}) }
			event:getPlayer():getInventory():removeItem(itemStack)
			event:setCancelled(true)
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "ZOMBIE" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function infectAbility(LAPlayer, event, ability, id)
	local damageEvent = event:getEntity():getLastDamageCause()
	
	if (damageEvent ~= nil and damageEvent:isCancelled() == false and damageEvent:getEventName() == "EntityDamageByEntityEvent") then
		local damagee = damageEvent:getEntity()
		local damager = damageEvent:getDamager()
		if damageEvent:getCause():toString() == "PROJECTILE" then damager = damageEvent:getDamager():getShooter() end
		
		if not util.hasClass(damager, "org.bukkit.projectiles.BlockProjectileSource") and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
				if game.targetPlayer(LAPlayer, game.getPlayer(damager)) then
					util.runLater(function() game.changeAbility(game.getPlayer(damager), ability, "LA-MW-015", true) end, 1)
					game.sendMessage(damager, "§4좀비 §c능력에 감염되었습니다.")
					damager:getWorld():spawnParticle(import("$.Particle").REDSTONE, damager:getLocation():add(0,1,0), 300, 0.5, 1, 0.5, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
					damager:getWorld():playSound(damager:getLocation(), import("$.Sound").ENTITY_ZOMBIE_INFECT, 1, 1)
					damager:getWorld():playSound(damager:getLocation(), import("$.Sound").ENTITY_ZOMBIE_AMBIENT, 1, 1)
				end
			end
		end
	end
end