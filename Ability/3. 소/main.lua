function main(abilityData)
	local cowBlindness = true
	local effect = import("$.potion.PotionEffectType")
		
	plugin.registerEvent(abilityData, "PlayerItemConsumeEvent", 0, function(a, e)
		if e:getItem():getType():toString() == "COOKED_BEEF" or e:getItem():getType():toString() == "BEEF" then
			if game.checkCooldown(e:getPlayer(), a, 0) then
				game.getPlayer(e:getPlayer()):setVariable("MW003-cowBlindness", "true")
				e:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
				util.runLater(function() game.getPlayer(e:getPlayer()):setVariable("MW003-cowBlindness", "false") end, 100)
			end
		end
	end)
	
	plugin.addPassiveScript(abilityData, 1, function(p)
		if (p:hasPotionEffect(effect.BLINDNESS) and game.getPlayer(p):getVariable("MW003-cowBlindness") == "false") then p:removePotionEffect(effect.BLINDNESS) end
		if (p:hasPotionEffect(effect.CONFUSION)) then p:removePotionEffect(effect.CONFUSION) end
		if (p:hasPotionEffect(effect.HUNGER)) then p:removePotionEffect(effect.HUNGER) end
		if (p:hasPotionEffect(effect.LEVITATION)) then p:removePotionEffect(effect.LEVITATION) end
		if (p:hasPotionEffect(effect.POISON)) then p:removePotionEffect(effect.POISON) end
		if (p:hasPotionEffect(effect.SLOW)) then p:removePotionEffect(effect.SLOW) end
		if (p:hasPotionEffect(effect.SLOW_DIGGING)) then p:removePotionEffect(effect.SLOW_DIGGING) end
		if (p:hasPotionEffect(effect.UNLUCK)) then p:removePotionEffect(effect.UNLUCK) end
		if (p:hasPotionEffect(effect.WEAKNESS)) then p:removePotionEffect(effect.WEAKNESS) end
		if (p:hasPotionEffect(effect.WITHER)) then p:removePotionEffect(effect.WITHER) end
	end)
end