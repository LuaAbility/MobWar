local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW022-shoot", "EntityDamageEvent", 600)
	plugin.registerEvent(abilityData, "MW022-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW022-shoot" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then shoot(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW022-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "BEE" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function shoot(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		local item = event:getDamager():getInventory():getItemInMainHand()
		if game.isAbilityItem(item, "IRON_INGOT") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				event:getDamager():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.CONFUSION, 200, 0}))
				event:getDamager():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WEAKNESS, 200, 0}))
				event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.CONFUSION, 200, 0}))
				event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.POISON, 200, 0}))
				
				event:getEntity():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getEntity():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").HONEYCOMB_BLOCK}))
				event:getDamager():getWorld():playSound(event:getDamager():getLocation(), import("$.Sound").ENTITY_BEE_STING, 1, 1)
			end
		end
	end
end