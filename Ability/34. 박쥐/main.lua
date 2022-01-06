function main(abilityData)
	local effect = import("$.potion.PotionEffectType")
	local attribute = import("$.attribute.Attribute")
	
	plugin.addPassiveScript(abilityData, 0, function(p)
		p:getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(6)
		game.getPlayer(p):addVariable("MW034-playerType", "동물")
	end)
	
	plugin.onPlayerEnd(abilityData, function(p)
		p:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(p:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getDefaultValue())
	end)
	
	plugin.addPassiveScript(abilityData, 1800, function(p)
		
		if math.random(2) == 1 then
			game.getPlayer(p):setVariable("MW034-playerType", "동물")
			game.sendMessage(p, "§2[§a박쥐§2] §a능력 타입이 §2동물§a이 되었습니다.")
			game.sendMessage(p, "§2[§a박쥐§2] §a동물 능력자에게는 데미지를 입지 않습니다.")
		else
			game.getPlayer(p):setVariable("MW034-playerType", "몬스터")
			game.sendMessage(p, "§2[§a박쥐§2] §a능력 타입이 §2몬스터§a가 되었습니다.")
			game.sendMessage(p, "§2[§a박쥐§2] §a몬스터 능력자에게는 데미지를 입지 않습니다.")
		end
		p:getWorld():playSound(p:getLocation(), import("$.Sound").ENTITY_BAT_AMBIENT, 1, 1)
	end)
	
	plugin.registerEvent(abilityData, "EntityDamageByEntityEvent", 0, function(a, e)
		local damagee = e:getEntity()
		local damager = e:getDamager()
		if e:getCause():toString() == "PROJECTILE" then damager = e:getDamager():getShooter() end
		
		if damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" and game.getPlayerAbility(damager) ~= nil then
			local abilities = util.getTableFromList(game.getPlayerAbility(damager))
			if #abilities > 0 and abilities[1].abilityType == game.getPlayer(damagee):getVariable("MW034-playerType") then
				if game.checkCooldown(damagee, a, 0) then
					e:setCancelled(true)
				end
			else
				if game.checkCooldown(damagee, a, 0) then
					damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_BAT_HURT, 0.25, 1)
				end
			end
		end
	end)
end


