function Init(abilityData)
	plugin.registerEvent(abilityData, "MW040-changeDifficult", "PlayerInteractEvent", 6000)
	plugin.registerEvent(abilityData, "MW040-calculateDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW040-changeDifficult" then changeDifficult(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW040-calculateDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then calculateDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW040-passiveCount") == nil then 
		player:setVariable("MW040-passiveCount", 0) 
		setDifficult(player:getPlayer())
	end
end

function changeDifficult(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					setDifficult(event:getPlayer())
				end
			end
		end
	end
end

function calculateDamage(LAPlayer, event, ability, id)
	local damagee = event:getEntity()
	local damager = event:getDamager()
	if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
	
	if damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
			if game.getPlayer(damagee):getVariable("MW040-difficult") == 1 then event:setDamage(event:getDamage() * 0.5)
			elseif game.getPlayer(damagee):getVariable("MW040-difficult") == 2 then event:setDamage(event:getDamage() * 0.75)
			elseif game.getPlayer(damagee):getVariable("MW040-difficult") == 3 then event:setDamage(event:getDamage())
			elseif game.getPlayer(damagee):getVariable("MW040-difficult") == 4 then event:setDamage(event:getDamage() * 1.25)
			else event:setDamage(event:getDamage() * 1.5) end
		end
		
		if game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
			if game.getPlayer(damager):getVariable("MW040-difficult") == 1 then event:setDamage(event:getDamage() * 0.5)
			elseif game.getPlayer(damager):getVariable("MW040-difficult") == 2 then event:setDamage(event:getDamage() * 0.75)
			elseif game.getPlayer(damager):getVariable("MW040-difficult") == 3 then event:setDamage(event:getDamage())
			elseif game.getPlayer(damager):getVariable("MW040-difficult") == 4 then event:setDamage(event:getDamage() * 1.5)
			else event:setDamage(event:getDamage() * 2) end
		end
	end
end

function setDifficult(p)
	math.randomseed(os.time())
	local difficult = util.random(1, 5)
	if difficult == 1 then game.sendMessage(p, "§2[§a플레이어§2] §a난이도가 §b평화로움§a이 되었습니다.")
	elseif difficult == 2 then game.sendMessage(p, "§2[§a플레이어§2] §a난이도가 §e쉬움§a이 되었습니다.")
	elseif difficult == 3 then game.sendMessage(p, "§2[§a플레이어§2] §a난이도가 §6보통§a이 되었습니다.")
	elseif difficult == 4 then game.sendMessage(p, "§2[§a플레이어§2] §a난이도가 §c어려움§a이 되었습니다.")
	else game.sendMessage(p, "§2[§a플레이어§2] §a난이도가 §4하드코어§a가 되었습니다.") end
	game.getPlayer(p):setVariable("MW040-difficult", difficult) 
	p:getWorld():spawnParticle(import("$.Particle").COMPOSTER, p:getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
	p:getWorld():playSound(p:getLocation(), import("$.Sound").ENTITY_PLAYER_LEVELUP, 1, 1)
end