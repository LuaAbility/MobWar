local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW011-blind", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW011-blind" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then blind(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function blind(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) and game.targetPlayer(LAPlayer, game.getPlayer(event:getDamager()), false) then
			event:getDamager():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 200, 0}))
			event:getDamager():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getDamager():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").BLACK_WOOL}))
			event:getDamager():getWorld():playSound(event:getDamager():getLocation(), import("$.Sound").ENTITY_SQUID_SQUIRT, 0.25, 1)
		end
	end
end