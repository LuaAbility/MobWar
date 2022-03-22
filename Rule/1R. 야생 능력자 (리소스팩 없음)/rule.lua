local material = import("$.Material") -- 건들면 안됨!
local godModeTick = 6000 -- 무적 시간 (틱)

local infinityFoodLevel = true -- 배고픔 무한 모드 
local giveItemOnSpawn = true -- 시작 / 스폰 시 기본 아이템 지급
local startX = 105 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표
local startY = 1 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표
local startZ = 87 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표

local startBorderSize = 500.0 -- 시작 시 월드 보더의 크기
local endBorderSize = 20.0 -- 마지막 월드 보더의 크기
local borderChangeSecond = 120 -- 월드보더의 크기가 변화하는 시간
local endBorderTick = 12000 -- 월드보더 크기 축소 시작 시간 (틱)
	
local abilityItem = material.IRON_INGOT -- 능력 시전 아이템
local abilityItemName = "철괴" -- 능력 시전 아이템 이름

function Init()
	math.randomseed(os.time()) -- 건들면 안됨!
	
	plugin.getPlugin().gameManager:setVariable("gameCount", 0)
	plugin.getPlugin().gameManager:setVariable("isGodMode", false)
	plugin.getPlugin().gameManager:setVariable("worldBorder", nil)
	
	plugin.skipInformationOption(false) -- 모든 게임 시작과정을 생략하고 게임을 시작할 지 정합니다.
	plugin.raffleAbilityOption(true) -- 시작 시 능력을 추첨할 지 결정합니다.
	plugin.skipYesOrNoOption(false) -- 플레이어에게 능력 재설정을 가능하게 할 것인지 정합니다. true : 능력 재설정 불가 / false : 능력 재설정 가능
	plugin.abilityAmountOption(1, false) -- 능력의 추첨 옵션입니다. 숫자로 능력의 추첨 개수를 정하고, true/false로 다른 플레이어와 능력이 중복될 수 있는지를 정합니다. 같은 플레이어에게는 중복된 능력이 적용되지 않습니다.
	plugin.abilityItemOption(false, abilityItem, abilityItemName) -- 능력 발동 아이템 옵션입니다. true/false로 모든 능력의 발동 아이템을 통일 할 것인지 정하고, Material을 통해 통일할 아이템을 설정합니다.
	plugin.abilityCheckOption(true) -- 능력 확인 옵션입니다. 플레이어가 자신의 능력을 확인할 수 있는 지 정합니다.
	plugin.cooldownMultiplyOption(1.0) -- 능력 쿨타임 옵션입니다. 해당 값만큼 쿨타임 값에 곱해져 적용됩니다. (예: 0.5일 경우 쿨타임이 기본 쿨타임의 50%, 2.0일 경우 쿨타임이 기본 쿨타임의 200%)
	plugin.setResourcePackPort(13356)
	plugin.getPlugin().useResourcePack = false
	game.setMaxHealth(20)
	
	plugin.banAbilityID("LA-SCP-451")
	plugin.banAbilityID("LA-SCP-___")
	plugin.banAbilityID("LA-MW-036")
	plugin.banAbilityID("LA-MW-019")
	plugin.banAbilityID("LA-MW-014")
	plugin.banAbilityID("LA-MW-008")
	plugin.banAbilityID("LA-MW-006")
	plugin.banAbilityID("LA-MW-004")
	plugin.banAbilityID("LA-MW-001")
	plugin.banAbilityID("LA-HS-015")
	plugin.banAbilityID("LA-HS-001")
	plugin.banAbilityID("LA-EX-034")
	plugin.banAbilityID("LA-EX-032")
	plugin.banAbilityID("LA-EX-028")
	plugin.banAbilityID("LA-EX-023")

	plugin.registerRuleEvent("PlayerDeathEvent", "eliminate")
	plugin.registerRuleEvent("EntityDamageEvent", "godMode")
	plugin.registerRuleEvent("PlayerJoinEvent", "spectator")
end

function onEvent(funcID, event)
	if funcID == "eliminate" then eliminate(event) end
	if funcID == "spectator" then spectator(event) end
	if funcID == "godMode" and plugin.getPlugin().gameManager:getVariable("isGodMode") == true then cancelDamage(event) end
end

function spectator(event)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i]:getPlayer():getName() == event:getPlayer():getName() then return 0 end
	end
	
	game.sendMessage(event:getPlayer(), "§6[§eLAbility§6] §e게임이 진행 중입니다. 관전 모드가 됩니다.")
	event:getPlayer():setGameMode(import("$.GameMode").SPECTATOR)
end

function onTimer()
	local count = plugin.getPlugin().gameManager:getVariable("gameCount")
	if count == nil then
		plugin.getPlugin().gameManager:setVariable("gameCount", 0)
		plugin.getPlugin().gameManager:setVariable("isGodMode", false)
		plugin.getPlugin().gameManager:setVariable("worldBorder", nil)
		count = 0
	end
	if count == 0 then
		setGodMode(true)
		teleport()
		heal()
		changeGamemode()
		setWorldBorder()
	end

	if count == godModeTick then setGodMode(false) end
	if count == endBorderTick then reductWorldBorder() end
	bossbar(count)
	count = count + 1
	plugin.getPlugin().gameManager:setVariable("gameCount", count)
end

function setGodMode(enable)
	local players = util.getTableFromList(game.getPlayers())
	if enable then
		for i = 1, #players do
			players[i]:setVariable("abilityLock", true)
		end
		plugin.getPlugin().gameManager:setVariable("isGodMode", true)
		game.broadcastMessage("§6[§eLAbility§6] §e게임 시작 후 ".. (godModeTick / 20.0) .. "초 간 무적으로 진행됩니다.")
	else
		for i = 1, #players do
			players[i]:setVariable("abilityLock", false)
		end
		plugin.getPlugin().gameManager:setVariable("isGodMode", false)
		game.broadcastMessage("§4[§cLAbility§4] §c무적시간이 종료되었습니다. 이제 데미지를 입습니다.")
		game.broadcastMessage("§1[§bLAbility§1] §b이제 능력 사용이 가능합니다.")
	end	
end

function teleport()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():getInventory():clear()
		players[i]:getPlayer():teleport(newInstance("$.Location", { players[i]:getPlayer():getWorld(), startX, startY, startZ }) )
	end
end


function changeGamemode()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():setGameMode(import("$.GameMode").SURVIVAL)
	end
end

function heal()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():setHealth(players[i]:getPlayer():getAttribute(import("$.attribute.Attribute").GENERIC_MAX_HEALTH):getBaseValue())
	end
end

function setWorldBorder()
	local player = util.getTableFromList(game.getPlayers())[1]:getPlayer()
	local border = player:getWorld():getWorldBorder()
	border:setCenter(startX, startZ)
	border:setSize(startBorderSize)
	
	game.broadcastMessage("§6[§eLAbility§6] §e게임 시작 후 ".. (endBorderTick / 20.0 / 60.0) .. "분 이후 월드의 크기가 작아집니다.")
	plugin.getPlugin().gameManager:setVariable("worldBorder", border)
end

function reductWorldBorder()
	local border = plugin.getPlugin().gameManager:getVariable("worldBorder")
	if border ~= nil then
		border:setSize(endBorderSize, borderChangeSecond)
		border:setDamageAmount(0.01)
		border:setDamageBuffer(10)
		game.broadcastMessage("§4[§cLAbility§4] §c지금부터 월드의 크기가 작아집니다!")
		game.broadcastMessage("§4[§cLAbility§4] §c크기는 ".. borderChangeSecond .. "초 동안 축소됩니다.")
		game.broadcastMessage("§4[§cLAbility§4] §c기준 좌표 - X : " .. startX .. " / Z : " .. startZ)
		game.broadcastMessage("§4[§cLAbility§4] §c크기 - " .. endBorderSize .. "칸")
	end
end

function cancelDamage(event)
	if event:getEntity():getType():toString() == "PLAYER" then
		event:setCancelled(true)
	end
end

function eliminate(event)
	if event:getEntity():getType():toString() == "PLAYER" then
		local player = game.getPlayer(event:getEntity())
		if player ~= nil then
			event:getEntity():getWorld():strikeLightningEffect(event:getEntity():getLocation())
			game.broadcastMessage("§4[§cLAbility§4] §c" .. event:getEntity():getName() .. "님이 탈락하셨습니다.")
			game.sendMessage(event:getEntity(), "§4[§cLAbility§4] §c사망으로 인해 탈락하셨습니다.")
			game.eliminatePlayer(player)
		end
		
		local damageEvent = event:getEntity():getLastDamageCause()
	
		if (damageEvent ~= nil and damageEvent:isCancelled() == false and damageEvent:getEventName() == "EntityDamageByEntityEvent") then
			local damagee = damageEvent:getEntity()
			local damager = damageEvent:getDamager()
			if damageEvent:getCause():toString() == "PROJECTILE" then damager = damageEvent:getDamager():getShooter() end
			
			if not util.hasClass(damager, "org.bukkit.projectiles.BlockProjectileSource") and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
				damager:getInventory():addItem( { newInstance("$.inventory.ItemStack", {material.GOLDEN_APPLE, 1}) } )
			end
		end
	end
end

function bossbar(count)
	local bossbar = plugin.getPlugin().gameManager:getVariable("timeBossbar")
	if not bossbar then
		local bossbarKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), "timeBossbar" })
		local timeBossbar = plugin.getServer():createBossBar(bossbarKey, "", import("$.boss.BarColor").WHITE, import("$.boss.BarStyle").SEGMENTED_20, { } )
		local players = util.getTableFromList(game.getPlayers())
		for i = 1, #players do
			timeBossbar:addPlayer(players[i]:getPlayer())
		end
		
		plugin.getPlugin().gameManager:setVariable("timeBossbar", timeBossbar)
		bossbar = timeBossbar
	end
	
	if count <= godModeTick then
		local timedata = count / godModeTick
		if timedata > 1 then timedata = 1 end
		bossbar:setProgress(1 - timedata)
		bossbar:setTitle("§6[§e무적§6] §c(능력 사용 불가)")
		bossbar:setColor(import("$.boss.BarColor").YELLOW)
	elseif count <= endBorderTick then
		local timedata = (count - godModeTick) / (endBorderTick - godModeTick)
		if timedata > 1 then timedata = 1 end
		bossbar:setProgress(1 - timedata)
		bossbar:setTitle("§2[§a전투§2]")
		bossbar:setColor(import("$.boss.BarColor").GREEN)
	elseif count <= endBorderTick + (borderChangeSecond * 20) then
		local timedata = (count - endBorderTick) / (borderChangeSecond * 20)
		if timedata > 1 then timedata = 1 end
		bossbar:setProgress(1 - timedata)
		local currentSize = startBorderSize - math.floor((startBorderSize - endBorderSize) * (timedata) + 0.5)
		local str = " §c현재 월드 크기 : " .. currentSize .. "칸"
		
		bossbar:setTitle("§4[§c월드 축소§4]" .. str)
		bossbar:setColor(import("$.boss.BarColor").RED)
	else
		bossbar:setProgress(1)
		bossbar:setTitle("§8[§7월드 축소 종료§8]")
		bossbar:setColor(import("$.boss.BarColor").WHITE)
	end
end

function Reset()
	local border = plugin.getPlugin().gameManager:getVariable("worldBorder")
	if border ~= nil then
		border:setSize(9999999)
		border:setCenter(startX, startZ)
	end

	local bossbars = util.getTableFromList(plugin.getServer():getBossBars())
	for i = 1, #bossbars do
		plugin.getServer():getBossBar(bossbars[i]:getKey()):removeAll()
		plugin.getServer():getBossBar(bossbars[i]:getKey()):setVisible(false)
		plugin.getServer():removeBossBar(bossbars[i]:getKey())
	end
end