if getgenv().TRonVoidKaitun then
	pcall(function()
		for _,v in ipairs(game.CoreGui:GetChildren()) do
			if v.Name:find("TRonVoid") then v:Destroy() end
		end
	end)
	pcall(function()
		for _,v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
			if v.Name:find("TRonVoid") then v:Destroy() end
		end
	end)
end
getgenv().TRonVoidKaitun = true

getgenv().TRonConfig = getgenv().TRonConfig or {
	Team                  = "Pirate",
	FullFightStyles       = true,
	CDK                   = true,
	StayS2ForDarkFragment = false,
	FixLag                = false,
	TweenSpeed            = 350,
	EatFruit              = true,
	FruitToEat            = "",
	SkyFarm               = true,   -- Farm NPCs direto do céu (Safe Mode)
	SkyHeight             = 175,    -- Altura acima do NPC (studs) — recomendado 150~250
	AutoHop               = true,   -- Troca de servidor automaticamente
	HopInterval           = 1800,   -- Intervalo entre hops (segundos) — padrão 30min
}

local Players  = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local RS       = game:GetService("ReplicatedStorage")
local LP       = Players.LocalPlayer

repeat task.wait(0.5) until game:IsLoaded()
repeat task.wait(0.5) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait(0.5) until LP:FindFirstChild("Data")

local PID = game.PlaceId
World1 = (PID==2753915549 or PID==85211729168715)
World2 = (PID==4442272183 or PID==79091703265657)
World3 = (PID==7449423635 or PID==100117331123089)

task.spawn(function()
	repeat task.wait() until LP and LP.Character
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhDangNhoEm/TuanAnhIOS/refs/heads/main/koby"))()
	end)
end)

local function SafeInvoke(...)
	local args = {...}
	local ok, res = pcall(function()
		return RS:WaitForChild("Remotes",3):WaitForChild("CommF_",3):InvokeServer(table.unpack(args))
	end)
	return ok and res or nil
end

local function SafeFire(...)
	local args = {...}
	pcall(function()
		RS:WaitForChild("Remotes",3):WaitForChild("CommE",3):FireServer(table.unpack(args))
	end)
end

local function getLevel()
	local ok, val = pcall(function() return LP.Data.Level.Value end)
	return ok and val or 1
end

local function getBeli()
	local ok, val = pcall(function() return LP.Data.Beli.Value end)
	if ok and val then return val end
	local ok2, val2 = pcall(function()
		return LP.leaderstats and LP.leaderstats:FindFirstChild("Beli") and LP.leaderstats.Beli.Value
	end)
	return (ok2 and val2) or 0
end

local function getFragments()
	local ok, val = pcall(function() return LP.Data.Fragments.Value end)
	return ok and val or 0
end

local function getMastery(styleName)
	local m = 0
	pcall(function()
		local fs = LP.Data:FindFirstChild("FightingStyles") or LP.Data:FindFirstChild("M")
		if not fs then return end
		for _, v in ipairs(fs:GetChildren()) do
			if v.Name:lower():find(styleName:lower()) then
				m = v.Value or 0
			end
		end
	end)
	return m
end

local function getSwordMastery(name)
	local m = 0
	pcall(function()
		local sw = LP.Data:FindFirstChild("Swords") or LP.Data:FindFirstChild("Sword")
		if sw then
			for _, v in ipairs(sw:GetChildren()) do
				if v.Name:lower():find(name:lower()) then m = v.Value or 0 end
			end
		end
		-- fallback: Stats
		local st = LP.Data:FindFirstChild("Stats")
		if st and m == 0 then
			local sv = st:FindFirstChild(name) or st:FindFirstChild("Sword")
			if sv then m = sv.Value or 0 end
		end
	end)
	return m
end

-- Equipa a arma certa dependendo da fase:
--   Antes do God Human  → arma Melee (estilo de luta) para acumular maestria
--   Depois do God Human → espada (Yama > Tushita > CDK) para acumular maestria
local function EquipWeaponForPhase()
	pcall(function()
		local char = LP.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		local function equipTool(name)
			local tool = LP.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
			if tool and not char:FindFirstChild(name) then
				hum:EquipTool(tool)
				return true
			end
			return tool ~= nil
		end

		if not GodHumanDone then
			-- Fase Melee: equipa God Human se tiver, senão Dragon Talon, etc.
			local meleeOrder = {"God Human","Dragon Talon","Electric Claw","Sharkman Karate","Death Step","Dragon Breath","Electric","Black Leg"}
			for _, style in ipairs(meleeOrder) do
				if hasFightingStyle(style) then
					-- Fighting styles não são tools — não precisa equipar, o jogo já usa automaticamente
					break
				end
			end
		else
			-- Fase Sword: equipa CDK > Tushita > Yama em ordem de prioridade
			local swordOrder = {"Cursed Dual Katana", "Tushita", "Yama"}
			for _, sw in ipairs(swordOrder) do
				if equipTool(sw) then break end
			end
		end
	end)
end

local function hasFightingStyle(name)
	local found = false
	pcall(function()
		local fs = LP.Data:FindFirstChild("FightingStyles") or LP.Data:FindFirstChild("M")
		if fs then
			for _,v in ipairs(fs:GetChildren()) do
				if v.Name:lower():find(name:lower()) and (v.Value or 0) > 0 then
					found = true
				end
			end
		end
	end)
	if not found then
		pcall(function()
			for _,t in ipairs(LP.Backpack:GetChildren()) do
				if t.Name:lower():find(name:lower()) then found=true end
			end
		end)
		if not found and LP.Character then
			pcall(function()
				for _,t in ipairs(LP.Character:GetChildren()) do
					if t.Name:lower():find(name:lower()) then found=true end
				end
			end)
		end
	end
	return found
end

local function hasItem(name)
	local found = false
	pcall(function()
		for _,t in ipairs(LP.Backpack:GetChildren()) do
			if t.Name:lower():find(name:lower()) then found=true end
		end
	end)
	if not found and LP.Character then
		pcall(function()
			for _,t in ipairs(LP.Character:GetChildren()) do
				if t.Name:lower():find(name:lower()) then found=true end
			end
		end)
	end
	return found
end

local _mc = {e=0,f=0,b=0,t=0}
local function checkMaterial(name)
	if tick()-_mc.t < 8 then
		local nl = name:lower()
		if nl:find("ecto") then return _mc.e end
		if nl:find("dark") then return _mc.f end
		if nl:find("bone") then return _mc.b end
	end
	local e,f,b = 0,0,0
	pcall(function()
		local inv = SafeInvoke("getInventory")
		if type(inv)=="table" then
			for _,v in ipairs(inv) do
				local n=(v.Name or ""):lower()
				local c=v.Count or v.Amount or 1
				if n:find("ecto") then e=e+c end
				if n:find("dark fragment") then f=f+c end
				if n:find("bone") and not n:find("frag") then b=b+c end
			end
		end
	end)
	pcall(function()
		local de=LP.Data:FindFirstChild("Ectoplasm") or LP.Data:FindFirstChild("EctoplasmCount")
		if de and de.Value>0 then e=de.Value end
		local df=LP.Data:FindFirstChild("DarkFragment") or LP.Data:FindFirstChild("Dark_Fragment")
		if df and df.Value>0 then f=df.Value end
		local db=LP.Data:FindFirstChild("Bone") or LP.Data:FindFirstChild("BoneCount")
		if db and db.Value>0 then b=db.Value end
	end)
	_mc.e=e; _mc.f=f; _mc.b=b; _mc.t=tick()
	local nl=name:lower()
	if nl:find("ecto") then return e end
	if nl:find("dark") then return f end
	if nl:find("bone") then return b end
	return 0
end

local function hasHakiKen()
	local ok,v=pcall(function() return LP.Data and LP.Data:FindFirstChild("Ken") and LP.Data.Ken.Value>0 end)
	return ok and (v or false)
end

local function hasGodHuman()      return hasFightingStyle("God Human") end
local function hasCDK()           return hasItem("Cursed Dual Katana") end
local function hasValkiria()      return hasItem("Valkiria") or hasItem("Valkirie") or hasItem("Valkyrie") end
local function hasMirrorFractal() return hasItem("Mirror Fractal") end
local function hasSaber()         return hasItem("Saber") end
local function hasTushita()       return hasItem("Tushita") end
local function hasYama()          return hasItem("Yama") end
local function hasSkullGuitar()   return hasItem("Skull Guitar") or hasItem("SkullGuitar") end

getgenv().TRonStatus = "Inicializando..."
getgenv().TRonStatusLabel = nil
local function setStatus(s)
	getgenv().TRonStatus = tostring(s)
	pcall(function()
		if getgenv().TRonStatusLabel and getgenv().TRonStatusLabel.Parent then
			getgenv().TRonStatusLabel.Text = "⚡ "..tostring(s)
		end
	end)
end

local function TweenPlayer(cf)
	pcall(function()
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local dist = (hrp.Position - cf.Position).Magnitude
		if dist < 3 then return end
		-- Velocidade em studs/s igual ao Hub Main (350 = natural, sem risco de ban)
		local tweenSpeed = math.clamp(getgenv().TRonConfig.TweenSpeed or 350, 50, 600)
		local t = dist / tweenSpeed
		local tw = TweenSvc:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame=cf})
		tw:Play()
		local elapsed = 0
		while tw.PlaybackState ~= Enum.PlaybackState.Completed do
			task.wait(0.05); elapsed=elapsed+0.05
			if elapsed > t + 2 then tw:Cancel(); break end
		end
	end)
end

local function TP(cf)
	pcall(function()
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = cf end
	end)
	task.wait(0.1)
end

local function AutoHaki()
	pcall(function() SafeFire("Buso", true) end)
	task.wait(0.05)
	pcall(function() SafeFire("Ken", true) end)
end

local function Attack()
	pcall(function()
		local vim = game:GetService("VirtualInputManager")
		for _,k in ipairs({"Z","X","C"}) do
			pcall(function()
				vim:SendKeyEvent(true,k,false,game)
				task.wait(0.06)
				vim:SendKeyEvent(false,k,false,game)
				task.wait(0.04)
			end)
		end
	end)
end

local Pos = CFrame.new(0,0,3.5)

-- ===== SKY FARM HELPER =====
-- Retorna posicao no ceu acima do mob, olhando para ele
-- O NPC nao consegue atingir o jogador nessa altura
local function GetSkyPos(mob)
	local hrp = mob and mob:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local h = math.clamp(getgenv().TRonConfig.SkyHeight or 175, 80, 400)
	local above = hrp.Position + Vector3.new(0, h, 0)
	-- Olha para baixo em direcao ao NPC (melhora o hit rate das skills)
	return CFrame.new(above, hrp.Position)
end

-- Reposiciona no ceu se o jogador saiu do ponto ideal
local function LockSky(mob)
	if not getgenv().TRonConfig.SkyFarm then return end
	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	local mobHRP = mob and mob:FindFirstChild("HumanoidRootPart")
	if not hrp or not mobHRP then return end
	local h = math.clamp(getgenv().TRonConfig.SkyHeight or 175, 80, 400)
	local target = mobHRP.Position + Vector3.new(0, h, 0)
	-- So reposiciona se desviou mais de 12 studs
	if (hrp.Position - target).Magnitude > 12 then
		TweenPlayer(CFrame.new(target, mobHRP.Position))
	end
end

-- Unico ponto de entrada para mover ate o mob (normal ou sky)
local function MoveToMob(mob)
	if not mob then return end
	local mobHRP = mob:FindFirstChild("HumanoidRootPart")
	if not mobHRP then return end
	if getgenv().TRonConfig.SkyFarm then
		local skyPos = GetSkyPos(mob)
		if skyPos then TweenPlayer(skyPos) end
		LockSky(mob)
	else
		TweenPlayer(mobHRP.CFrame * Pos)
	end
end

local function GetEnemy(name)
	local ef = workspace:FindFirstChild("Enemies")
	if not ef then return nil end
	local nl = name:lower()
	for _,v in ipairs(ef:GetChildren()) do
		if v.Name:lower():find(nl) and v:FindFirstChild("Humanoid") and v.Humanoid.Health>0 and v:FindFirstChild("HumanoidRootPart") then
			return v
		end
	end
	return nil
end

local function IsAlive(m)
	return m and m.Parent and m:FindFirstChild("Humanoid") and m.Humanoid.Health>0
end

local FarmRunning = true
local function KillMob(mob)
	if not IsAlive(mob) then return end
	local deadline = tick() + 60
	-- Posiciona inicial antes do loop (sky ou chao)
	MoveToMob(mob)
	repeat
		pcall(function()
			AutoHaki()
				MoveToMob(mob)
			Attack()
		end)
		task.wait(0.18)
	until not IsAlive(mob) or not FarmRunning or tick() > deadline
end

local function Hop()
	setStatus("🔀 Trocando servidor...")
	pcall(function()
		local TS=game:GetService("TeleportService")
		for i=math.random(1,30),100 do
			local ok,e=pcall(function() return RS.__ServerBrowser:InvokeServer(i) end)
			if ok and e then
				for id,sv in next,e do
					if tonumber(sv.Count) and tonumber(sv.Count)<12 then
						TS:TeleportToPlaceInstance(game.PlaceId,id); return
					end
				end
			end
		end
	end)
end

-- ===== AUTO HOP A CADA 30 MINUTOS =====
task.spawn(function()
	while true do
		local interval = math.max(60, getgenv().TRonConfig.HopInterval or 1800)
		local remaining = interval
		while remaining > 0 do
			task.wait(1)
			remaining = remaining - 1
			-- Mostra contagem regressiva no status se inativo
			if remaining % 60 == 0 and remaining > 0 then
				pcall(function()
					if getgenv().TRonStatusLabel and getgenv().TRonStatusLabel.Parent then
						local mins = math.floor(remaining/60)
						local prev = getgenv().TRonStatus or ""
						getgenv().TRonStatusLabel.Text = prev.." [Hop em "..mins.."min]"
					end
				end)
			end
		end
		if getgenv().TRonConfig.AutoHop and FarmRunning then
			Hop()
		end
	end
end)

task.spawn(function()
	local equipTimer = 0
	while FarmRunning do
		task.wait(0.6)
		pcall(AutoHaki)
		-- Reequipa a arma certa a cada ~3s
		equipTimer = equipTimer + 0.6
		if equipTimer >= 3 then
			equipTimer = 0
			pcall(EquipWeaponForPhase)
		end
	end
end)

task.spawn(function()
	if getgenv().TRonConfig.FixLag then
		pcall(function()
			local L=game:GetService("Lighting")
			L.GlobalShadows=false; L.FogEnd=9e9
			settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
		end)
	end
	while true do
		task.wait(15)
		if getgenv().TRonConfig.FixLag then
			pcall(function()
				for _,v in ipairs(workspace:GetDescendants()) do
					if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
						v.Enabled=false
					end
				end
			end)
		end
	end
end)

task.spawn(function()
	task.wait(5)
	local codes={"ADMIN","BIGNEWS","BLOXFRUITS","CRYSTAL_1","SUB2GAMERROBOT_RESET1","FUDD10","FUDD10_V2","STRAWHATMAINE","1MLIKES","THEGREATACE","GIVEAWAYTIME","KITTGAMING","ENYU_IS_PRO","MISSOINARIE","MAGICTIMENOW","ONEPIECELOVER","SEATWO","THIRDSEA","SubToMikey786","SubToFlamingoYT","SubToRFedora","Jcwk","Jcwk2","Bluxxy","STAVBER","DEVSCOOKING","NOOB_BOAT","BIGNEWS2","ICREATEDBLOXFRUITS","ADMINNEW","DOUBLE_BELI","ICEADMIRAL","GAMER_ROBOT_1M","SECRET_ADMIN","CAKEBAR","BLOX_FRUIT","RESET_5TIMES","MIRRORQUEST","WELCOMEBACK","PRIDE","RAINBOW","Update17Part3","Update_17_3","Sub2OfficialNoobie","TantaiGaming","StrawHatMaine","Enyu_is_pro","instagramscripts","instagramscripts2","15B_BESTSCRIPT","INDEXERROR","NEWTROLL","XMASEXP","NEWYEAR"}
	for _,c in ipairs(codes) do
		pcall(function() SafeInvoke("Redeem",c) end)
		task.wait(0.35)
	end
end)

task.spawn(function()
	task.wait(4)
	pcall(function()
		local t=getgenv().TRonConfig.Team=="Marine" and "Marines" or "Pirates"
		SafeInvoke("SetTeam",t)
	end)
end)

task.spawn(function()
	while true do
		task.wait(4)
		if not FarmRunning then break end
		pcall(function()
			local pts=LP.Data.Points.Value
			if not pts or pts<=0 then return end
			local function gs(n) local ok,v=pcall(function() return LP.Data.Stats:FindFirstChild(n).Value end); return ok and v or 0 end
			if not GodHumanDone then
				-- Fase pré-God Human: maximiza Melee para maestria dos estilos
				if     gs("Melee")  < 2800 then SafeInvoke("AddPoint","Melee",pts)
				elseif gs("Defense") < 2800 then SafeInvoke("AddPoint","Defense",pts)
				elseif gs("Sword")   < 2800 then SafeInvoke("AddPoint","Sword",pts)
				end
			else
				-- Fase pós-God Human: maximiza Sword para Yama/Tushita/CDK
				if     gs("Sword")   < 2800 then SafeInvoke("AddPoint","Sword",pts)
				elseif gs("Defense") < 2800 then SafeInvoke("AddPoint","Defense",pts)
				elseif gs("Melee")   < 2800 then SafeInvoke("AddPoint","Melee",pts)
				end
			end
		end)
	end
end)

local FruitGrabbing=false
task.spawn(function()
	while true do
		task.wait(2)
		if not FarmRunning or not getgenv().TRonConfig.EatFruit then continue end
		pcall(function()
			local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local legNames={"Quake","Love","Creation","Spider","Sound","Phoenix","Leopard","Dragon","Spirit","Kitsune","Dough","Buddha","Rumble","Magma","Light","Dark","String","Flame","Ice","Sand"}
			local best,bestDist,bestHandle=nil,9000,nil
			local spawners={"AppleSpawner","PineappleSpawner","BananaSpawner","GrapeSpawner"}
			for _,sn in ipairs(spawners) do
				local sp=workspace:FindFirstChild(sn)
				if sp then
					for _,t in ipairs(sp:GetChildren()) do
						if t:IsA("Tool") then
							local h=t:FindFirstChild("Handle")
							if h then
								local d=(h.Position-hrp.Position).Magnitude
								local isLeg=false
								for _,f in ipairs(legNames) do if t.Name:lower():find(f:lower()) then isLeg=true break end end
								if isLeg and d<bestDist then best=t; bestDist=d; bestHandle=h end
							end
						end
					end
				end
			end
			if not best then
				for _,t in ipairs(workspace:GetDescendants()) do
					if t:IsA("Tool") and (t.ToolTip=="Fruit" or t:GetAttribute("Type")=="Fruit") then
						local h=t:FindFirstChild("Handle")
						if h then
							local d=(h.Position-hrp.Position).Magnitude
							if d<bestDist and d<8000 then best=t; bestDist=d; bestHandle=h end
						end
					end
				end
			end
			if best and bestHandle and bestDist<8000 then
				local prevStatus=getgenv().TRonStatus
				FruitGrabbing=true
				setStatus("🍎 Pegando Fruta: "..best.Name)
				TP(CFrame.new(bestHandle.Position+Vector3.new(0,3,0)))
				task.wait(0.5)
				local pp=best:FindFirstChildWhichIsA("ProximityPrompt") or (best.Parent and best.Parent:FindFirstChildWhichIsA("ProximityPrompt"))
				if pp then pcall(function() fireproximityprompt(pp) end) end
				if getgenv().TRonConfig.FruitToEat~="" then
					if best.Name:lower():find(getgenv().TRonConfig.FruitToEat:lower()) then
						task.wait(0.5)
						pcall(function() SafeInvoke("eatFruit",best.Name) end)
					end
				end
				task.wait(1.5)
				FruitGrabbing=false
				setStatus(prevStatus)
			end
		end)
	end
end)

local Mon="Bandit"; local NameQuest="BanditQuest1"; local LevelQuest=1
local CFrameQuest=CFrame.new(1059,17,1546); local CFrameMon=CFrame.new(943,45,1562)

local function CheckQuest()
	local I=getLevel()
	if World1 and I>699 then I=650 end
	if World2 and I>1499 then I=1450 end
	if World1 then
		if     I<=9   then Mon="Bandit";LevelQuest=1;NameQuest="BanditQuest1";CFrameQuest=CFrame.new(1059,17,1546);CFrameMon=CFrame.new(943,45,1562)
		elseif I<=14  then Mon="Monkey";LevelQuest=1;NameQuest="JungleQuest";CFrameQuest=CFrame.new(-1598,37,153);CFrameMon=CFrame.new(-1524,50,37)
		elseif I<=29  then Mon="Gorilla";LevelQuest=2;NameQuest="JungleQuest";CFrameQuest=CFrame.new(-1598,37,153);CFrameMon=CFrame.new(-1128,40,-451)
		elseif I<=39  then Mon="Pirate";LevelQuest=1;NameQuest="BuggyQuest1";CFrameQuest=CFrame.new(-1140,4,3829);CFrameMon=CFrame.new(-1262,40,3905)
		elseif I<=59  then Mon="Brute";LevelQuest=2;NameQuest="BuggyQuest1";CFrameQuest=CFrame.new(-1140,4,3829);CFrameMon=CFrame.new(-976,55,4304)
		elseif I<=74  then Mon="Desert Bandit";LevelQuest=1;NameQuest="DesertQuest";CFrameQuest=CFrame.new(897,6,4389);CFrameMon=CFrame.new(924,7,4482)
		elseif I<=89  then Mon="Desert Officer";LevelQuest=2;NameQuest="DesertQuest";CFrameQuest=CFrame.new(897,6,4389);CFrameMon=CFrame.new(1608,9,4371)
		elseif I<=99  then Mon="Snow Bandit";LevelQuest=1;NameQuest="SnowQuest";CFrameQuest=CFrame.new(1385,87,-1298);CFrameMon=CFrame.new(1362,120,-1531)
		elseif I<=119 then Mon="Snowman";LevelQuest=2;NameQuest="SnowQuest";CFrameQuest=CFrame.new(1385,87,-1298);CFrameMon=CFrame.new(1243,140,-1437)
		elseif I<=149 then Mon="Chief Petty Officer";LevelQuest=1;NameQuest="MarineQuest2";CFrameQuest=CFrame.new(-5035,29,4326);CFrameMon=CFrame.new(-4881,23,4274)
		elseif I<=174 then Mon="Sky Bandit";LevelQuest=1;NameQuest="SkyQuest";CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-4953,296,-2899)
		elseif I<=189 then Mon="Dark Master";LevelQuest=2;NameQuest="SkyQuest";CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-5260,391,-2229)
		elseif I<=209 then Mon="Prisoner";LevelQuest=1;NameQuest="PrisonerQuest";CFrameQuest=CFrame.new(5306,2,477);CFrameMon=CFrame.new(5099,0,474)
		elseif I<=249 then Mon="Dangerous Prisoner";LevelQuest=2;NameQuest="PrisonerQuest";CFrameQuest=CFrame.new(5306,2,477);CFrameMon=CFrame.new(5655,16,866)
		elseif I<=274 then Mon="Toga Warrior";LevelQuest=1;NameQuest="ColosseumQuest";CFrameQuest=CFrame.new(-1581,7,-2982);CFrameMon=CFrame.new(-1820,51,-2741)
		elseif I<=299 then Mon="Gladiator";LevelQuest=2;NameQuest="ColosseumQuest";CFrameQuest=CFrame.new(-1581,7,-2982);CFrameMon=CFrame.new(-1268,30,-2996)
		elseif I<=324 then Mon="Military Soldier";LevelQuest=1;NameQuest="MagmaQuest";CFrameQuest=CFrame.new(-5319,12,8515);CFrameMon=CFrame.new(-5335,46,8638)
		elseif I<=374 then Mon="Military Spy";LevelQuest=2;NameQuest="MagmaQuest";CFrameQuest=CFrame.new(-5319,12,8515);CFrameMon=CFrame.new(-5803,86,8829)
		elseif I<=399 then Mon="Fishman Warrior";LevelQuest=1;NameQuest="FishmanQuest";CFrameQuest=CFrame.new(61122,18,1567);CFrameMon=CFrame.new(60998,50,1534);SafeInvoke("requestEntrance",Vector3.new(61163.85,11.67,1819.78))
		elseif I<=424 then Mon="Fishman Commando";LevelQuest=2;NameQuest="FishmanQuest";CFrameQuest=CFrame.new(61122,18,1567);CFrameMon=CFrame.new(61560,22,1799);SafeInvoke("requestEntrance",Vector3.new(61163.85,11.67,1819.78))
		elseif I<=449 then Mon="Kilo Soldier";LevelQuest=1;NameQuest="LowerSkyQuest";CFrameQuest=CFrame.new(-12076,927,-9459);CFrameMon=CFrame.new(-11835,962,-9398)
		elseif I<=474 then Mon="Kilo Commander";LevelQuest=2;NameQuest="LowerSkyQuest";CFrameQuest=CFrame.new(-12076,927,-9459);CFrameMon=CFrame.new(-12294,960,-9701)
		elseif I<=499 then Mon="Galley Captain";LevelQuest=2;NameQuest="SkyPirateQuest";CFrameQuest=CFrame.new(-5082,2286,-11810);CFrameMon=CFrame.new(-4879,2253,-11938)
		elseif I<=524 then Mon="Sky Pirate";LevelQuest=1;NameQuest="UpperSkyQuest";CFrameQuest=CFrame.new(-7398,2608,-11390);CFrameMon=CFrame.new(-7277,2600,-11494)
		elseif I<=549 then Mon="Impostors";LevelQuest=2;NameQuest="UpperSkyQuest";CFrameQuest=CFrame.new(-7398,2608,-11390);CFrameMon=CFrame.new(-7631,2617,-11159)
		else Mon="Wystern Soldier";LevelQuest=1;NameQuest="GodQuest";CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-5260,391,-2229)
		end
	elseif World2 then
		if     I<=699  then Mon="Croc";LevelQuest=1;NameQuest="CrocQuest1";CFrameQuest=CFrame.new(889,15,3980);CFrameMon=CFrame.new(717,43,4195)
		elseif I<=724  then Mon="Mob Captain";LevelQuest=2;NameQuest="CrocQuest1";CFrameQuest=CFrame.new(889,15,3980);CFrameMon=CFrame.new(1226,41,4261)
		elseif I<=774  then Mon="Rebel Soldier";LevelQuest=1;NameQuest="DesertQuest2";CFrameQuest=CFrame.new(-5300,25,2800);CFrameMon=CFrame.new(-5200,50,2900)
		elseif I<=824  then Mon="Rebel Officer";LevelQuest=2;NameQuest="DesertQuest2";CFrameQuest=CFrame.new(-5300,25,2800);CFrameMon=CFrame.new(-5600,50,3100)
		elseif I<=874  then Mon="Marine Lieutenant";LevelQuest=1;NameQuest="Snow2Quest1";CFrameQuest=CFrame.new(1128,14,-3205);CFrameMon=CFrame.new(940,21,-3354)
		elseif I<=924  then Mon="Marine Captain";LevelQuest=2;NameQuest="Snow2Quest1";CFrameQuest=CFrame.new(1128,14,-3205);CFrameMon=CFrame.new(1402,21,-3248)
		elseif I<=974  then Mon="Zombie";LevelQuest=1;NameQuest="GraveyardQuest1";CFrameQuest=CFrame.new(3899,22,-4100);CFrameMon=CFrame.new(3731,22,-4210)
		elseif I<=1024 then Mon="Demonic Soul";LevelQuest=2;NameQuest="GraveyardQuest1";CFrameQuest=CFrame.new(3899,22,-4100);CFrameMon=CFrame.new(4200,22,-4300)
		elseif I<=1074 then Mon="Cocoa Warrior";LevelQuest=1;NameQuest="CandyQuest1";CFrameQuest=CFrame.new(-2200,14,-14500);CFrameMon=CFrame.new(-2100,45,-14600)
		elseif I<=1124 then Mon="Chocolate Bar Battler";LevelQuest=2;NameQuest="CandyQuest1";CFrameQuest=CFrame.new(-2200,14,-14500);CFrameMon=CFrame.new(-1800,45,-14500)
		elseif I<=1174 then Mon="Candy Rebel";LevelQuest=1;NameQuest="CandyQuest2";CFrameQuest=CFrame.new(-1148,14,-14446);CFrameMon=CFrame.new(-1371,70,-14405)
		elseif I<=1224 then Mon="Snow Demon";LevelQuest=2;NameQuest="CandyQuest2";CFrameQuest=CFrame.new(-1148,14,-14446);CFrameMon=CFrame.new(-836,70,-14326)
		elseif I<=1274 then Mon="Lava Pirate";LevelQuest=1;NameQuest="HotAndColdQuest1";CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-5600,30,-5100)
		elseif I<=1324 then Mon="Ice Pack";LevelQuest=2;NameQuest="HotAndColdQuest1";CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-5200,30,-5400)
		elseif I<=1374 then Mon="Arctic Warrior";LevelQuest=1;NameQuest="HotAndColdQuest2";CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-5100,30,-5600)
		elseif I<=1424 then Mon="Snow Lurker";LevelQuest=2;NameQuest="HotAndColdQuest2";CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-4800,30,-5300)
		else Mon="Lab Subordinate";LevelQuest=1;NameQuest="LabQuest1";CFrameQuest=CFrame.new(-6438,15,-4500);CFrameMon=CFrame.new(-6300,30,-4600)
		end
	elseif World3 then
		if     I<=1574 then Mon="Forest Pirate";LevelQuest=1;NameQuest="ForestQuest1";CFrameQuest=CFrame.new(5060,30,-8400);CFrameMon=CFrame.new(5200,50,-8300)
		elseif I<=1624 then Mon="Mythological Pirate";LevelQuest=2;NameQuest="ForestQuest1";CFrameQuest=CFrame.new(5060,30,-8400);CFrameMon=CFrame.new(5400,50,-8500)
		elseif I<=1674 then Mon="Yeti";LevelQuest=1;NameQuest="IceQuest1";CFrameQuest=CFrame.new(-14700,60,-12800);CFrameMon=CFrame.new(-14500,80,-12900)
		elseif I<=1724 then Mon="Snow Wolf";LevelQuest=2;NameQuest="IceQuest1";CFrameQuest=CFrame.new(-14700,60,-12800);CFrameMon=CFrame.new(-14900,80,-12700)
		elseif I<=1774 then Mon="Pipe Pirate";LevelQuest=1;NameQuest="MainIsland3Quest";CFrameQuest=CFrame.new(-12364,364,-7508);CFrameMon=CFrame.new(-12200,380,-7600)
		elseif I<=1824 then Mon="Possessed Mummy";LevelQuest=1;NameQuest="HauntedCastleQuest1";CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5400,35,-3300)
		elseif I<=1874 then Mon="Reaper";LevelQuest=2;NameQuest="HauntedCastleQuest1";CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5700,35,-3100)
		elseif I<=1924 then Mon="Cursed Skeleton";LevelQuest=1;NameQuest="HauntedCastleQuest2";CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5600,40,-3400)
		elseif I<=1974 then Mon="Demonic Soul";LevelQuest=2;NameQuest="HauntedCastleQuest2";CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5300,40,-3200)
		elseif I<=2024 then Mon="Captain Elephant";LevelQuest=1;NameQuest="FunkyQuest1";CFrameQuest=CFrame.new(5440,25,4540);CFrameMon=CFrame.new(5520,60,4500)
		elseif I<=2074 then Mon="Beautiful Pirate";LevelQuest=2;NameQuest="FunkyQuest1";CFrameQuest=CFrame.new(5440,25,4540);CFrameMon=CFrame.new(5700,60,4600)
		elseif I<=2124 then Mon="Surfer";LevelQuest=1;NameQuest="SurfQuest1";CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-3500,30,-13500)
		elseif I<=2174 then Mon="Fishman Raider";LevelQuest=2;NameQuest="SurfQuest1";CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-3800,30,-13300)
		elseif I<=2224 then Mon="Fishman Champion";LevelQuest=1;NameQuest="SurfQuest2";CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-3900,30,-13600)
		elseif I<=2274 then Mon="Terrorshark";LevelQuest=2;NameQuest="SurfQuest2";CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-4100,30,-13200)
		elseif I<=2324 then Mon="Dragonite";LevelQuest=1;NameQuest="DragonQuest1";CFrameQuest=CFrame.new(-16300,14,-16300);CFrameMon=CFrame.new(-16200,30,-16400)
		elseif I<=2374 then Mon="Dragon Crew";LevelQuest=2;NameQuest="DragonQuest1";CFrameQuest=CFrame.new(-16300,14,-16300);CFrameMon=CFrame.new(-16500,30,-16200)
		elseif I<=2424 then Mon="Candy Pirate";LevelQuest=1;NameQuest="CandyQuest3";CFrameQuest=CFrame.new(150,25,-12777);CFrameMon=CFrame.new(17,80,-12962)
		elseif I<=2449 then Mon="Snow Demon";LevelQuest=2;NameQuest="CandyQuest3";CFrameQuest=CFrame.new(-1148,14,-14446);CFrameMon=CFrame.new(-836,70,-14326)
		elseif I<=2474 then Mon="Isle Outlaw";LevelQuest=1;NameQuest="TikiQuest1";CFrameQuest=CFrame.new(-16547,56,-172);CFrameMon=CFrame.new(-16431,90,-223)
		elseif I<=2499 then Mon="Island Boy";LevelQuest=2;NameQuest="TikiQuest1";CFrameQuest=CFrame.new(-16547,56,-172);CFrameMon=CFrame.new(-16668,70,-243)
		elseif I<=2524 then Mon="Sun-kissed Warrior";LevelQuest=1;NameQuest="TikiQuest2";CFrameQuest=CFrame.new(-16540,56,1051);CFrameMon=CFrame.new(-16345,80,1004)
		elseif I<=2549 then Mon="Isle Champion";LevelQuest=2;NameQuest="TikiQuest2";CFrameQuest=CFrame.new(-16540,56,1051);CFrameMon=CFrame.new(-16634,85,1106)
		elseif I<=2574 then Mon="Serpent Hunter";LevelQuest=1;NameQuest="TikiQuest3";CFrameQuest=CFrame.new(-16665,105,1580);CFrameMon=CFrame.new(-16542,146,1529)
		elseif I<=2599 then Mon="Skull Slayer";LevelQuest=2;NameQuest="TikiQuest3";CFrameQuest=CFrame.new(-16665,105,1580);CFrameMon=CFrame.new(-16849,147,1640)
		elseif I<=2649 then Mon="Reef Bandit";LevelQuest=1;NameQuest="SubmergedQuest1";CFrameQuest=CFrame.new(10882,-2086,10034);CFrameMon=CFrame.new(10736,-2087,9338);SafeInvoke("requestEntrance",Vector3.new(10882,-2086,10034))
		elseif I<=2699 then Mon="Coral Pirate";LevelQuest=2;NameQuest="SubmergedQuest1";CFrameQuest=CFrame.new(10882,-2086,10034);CFrameMon=CFrame.new(10965,-2158,9177);SafeInvoke("requestEntrance",Vector3.new(10882,-2086,10034))
		elseif I<=2724 then Mon="High Disciple";LevelQuest=1;NameQuest="SubmergedQuest3";CFrameQuest=CFrame.new(9636,-1992,9609);CFrameMon=CFrame.new(9828,-1940,9693);SafeInvoke("requestEntrance",Vector3.new(10882,-2086,10034))
		else Mon="Grand Devotee";LevelQuest=2;NameQuest="SubmergedQuest3";CFrameQuest=CFrame.new(9636,-1992,9609);CFrameMon=CFrame.new(9557,-1928,9859);SafeInvoke("requestEntrance",Vector3.new(10882,-2086,10034))
		end
	end
end

local function DoFarmLevel()
	CheckQuest()
	setStatus("🗡️ Farm Nível ["..getLevel().."] | "..Mon)
	local qGui=LP.PlayerGui:FindFirstChild("Main")
	local hasQuest=qGui and qGui:FindFirstChild("Quest") and qGui.Quest.Visible
	if not hasQuest then
		TweenPlayer(CFrameQuest); task.wait(0.4)
		SafeInvoke("StartQuest",NameQuest,LevelQuest); task.wait(0.4)
	end
	local mob=GetEnemy(Mon)
	if mob and IsAlive(mob) then
		MoveToMob(mob)
		AutoHaki(); Attack()
	else TweenPlayer(CFrameMon) end
end

local chests={CFrame.new(977,25,1570),CFrame.new(-1250,25,900),CFrame.new(200,25,-1500),CFrame.new(-2000,25,-2500),CFrame.new(1800,25,-800),CFrame.new(500,120,2000),CFrame.new(-3200,25,1200),CFrame.new(2500,25,0),CFrame.new(1500,25,3200),CFrame.new(-800,25,-400),CFrame.new(0,120,500),CFrame.new(-500,25,2800)}
local chestTimer=0
local function FarmChests()
	setStatus("💰 Farmando Baús — Reset em: "..(10-math.floor(chestTimer)).."s")
	for _,cf in ipairs(chests) do
		if FruitGrabbing then return end
		TP(cf); task.wait(0.15)
		pcall(function()
			local hrp=LP.Character.HumanoidRootPart
			for _,v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("chest") and (v.Parent.Position-hrp.Position).Magnitude<25 then
					fireproximityprompt(v)
				end
			end
		end)
	end
	chestTimer=chestTimer+1
	if chestTimer>=10 then chestTimer=0 end
end

local SaberDone=hasSaber(); local TushitaDone=false; local CDKDone=hasCDK()
local SkullGuitarDone=hasSkullGuitar(); local TyrantDone=false
local BlackLegDone=hasFightingStyle("Black Leg"); local ElectricDone=hasFightingStyle("Electric")
local SharkV1Done=hasFightingStyle("Sharkman Karate"); local DragonBreathDone=hasFightingStyle("Dragon Breath")
local DeathStepDone=hasFightingStyle("Death Step"); local SharkV2Done=hasFightingStyle("Sharkman Karate V2")
local ElectricClawDone=hasFightingStyle("Electric Claw"); local DragonTalonDone=hasFightingStyle("Dragon Talon")
local GodHumanDone=hasGodHuman(); local HakiKenBought=hasHakiKen()

local function AdvanceFightStyle()
	if not getgenv().TRonConfig.FullFightStyles then return false end
	if World1 then
		if not BlackLegDone and getBeli()>=150000 then
			setStatus("🥋 Comprando Black Leg")
			TP(CFrame.new(-2030,200,-2200)); task.wait(0.8)
			SafeInvoke("BuyFightingStyle","Black Leg"); task.wait(1)
			BlackLegDone=hasFightingStyle("Black Leg"); return true
		end
	elseif World2 then
		if not ElectricDone and getMastery("Black Leg")>=400 and getBeli()>=500000 then
			setStatus("🥋 Comprando Electric Style")
			TP(CFrame.new(-5478,16,-5247)); task.wait(0.8)
			SafeInvoke("BuyFightingStyle","Electric"); task.wait(1)
			ElectricDone=hasFightingStyle("Electric"); return true
		elseif ElectricDone and not SharkV1Done and getMastery("Electric")>=400 then
			setStatus("🥋 Comprando Sharkman Karate V1")
			TP(CFrame.new(1000,120,4000)); task.wait(0.8)
			SafeInvoke("BuyFightingStyle","Sharkman Karate"); task.wait(1)
			SharkV1Done=hasFightingStyle("Sharkman Karate"); return true
		end
	elseif World3 then
		if SharkV1Done and not DragonBreathDone and getMastery("Sharkman Karate")>=400 then
			setStatus("🥋 Comprando Dragon Breath")
			TP(CFrame.new(4530,656,-131)); task.wait(0.8)
			SafeInvoke("BuyFightingStyle","Dragon Breath"); task.wait(1)
			DragonBreathDone=hasFightingStyle("Dragon Breath"); return true
		elseif DragonBreathDone and not DeathStepDone and getMastery("Dragon Breath")>=400 then
			setStatus("🥋 Comprando Death Step")
			TP(CFrame.new(-2370,74,3875)); task.wait(0.8)
			SafeInvoke("BuyFightingStyle","Death Step"); task.wait(1)
			DeathStepDone=hasFightingStyle("Death Step"); return true
		elseif DeathStepDone and not SharkV2Done and getMastery("Death Step")>=400 then
			setStatus("🥋 Comprando Sharkman Karate V2")
			TP(CFrame.new(1000,120,4000)); task.wait(0.8)
			SafeInvoke("BuyFightingStyle","Sharkman Karate V2"); task.wait(1)
			SharkV2Done=hasFightingStyle("Sharkman Karate V2"); return true
		elseif SharkV2Done and not ElectricClawDone and getMastery("Sharkman Karate V2")>=400 then
			setStatus("🥋 Comprando Electric Claw")
			TP(CFrame.new(216,126,-12599)); task.wait(0.8)
			SafeInvoke("UnlockElectricClaw"); task.wait(1)
			ElectricClawDone=hasFightingStyle("Electric Claw"); return true
		elseif ElectricClawDone and not DragonTalonDone then
			local bone=checkMaterial("Bone")
			if getMastery("Electric Claw")>=400 then
				if bone>=500 then
					setStatus("🥋 Girando Cursed Essence para Dragon Talon")
					SafeInvoke("SpinCursedEssence"); task.wait(2)
					DragonTalonDone=hasFightingStyle("Dragon Talon")
				else
					setStatus("🦴 Farmando Bones ("..bone.."/500) para Dragon Talon")
					local mob=GetEnemy("Possessed Mummy") or GetEnemy("Reaper") or GetEnemy("Cursed Skeleton")
					if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack()
					else TweenPlayer(CFrame.new(5500,22,-3200)) end
				end
			else
				setStatus("🥋 Treinando Electric Claw ["..getMastery("Electric Claw").."/400]")
				DoFarmLevel()
			end
			return true
		elseif DragonTalonDone and not GodHumanDone then
			if getMastery("Dragon Talon")>=400 then
				setStatus("🥋 Obtendo GOD HUMAN!")
				SafeInvoke("BuyGodHuman"); task.wait(2)
				GodHumanDone=hasGodHuman()
			else
				setStatus("🥋 Treinando Dragon Talon ["..getMastery("Dragon Talon").."/400]")
				DoFarmLevel()
			end
			return true
		end
	end
	return false
end

local function DoSaberQuest()
	if SaberDone or hasSaber() then SaberDone=true return end
	setStatus("⚔️ Quest Saber Expert")
	local mob=GetEnemy("Saber Expert")
	if mob and IsAlive(mob) then
		KillMob(mob); task.wait(0.5)
		SafeInvoke("ProQuestProgress","PlaceRelic"); task.wait(25)
		SaberDone=hasSaber()
	else TP(CFrame.new(-1401.85,29.97,8.81)) end
end

local function DoTushitaQuest()
	if TushitaDone or hasTushita() then TushitaDone=true return end
	setStatus("📜 Quest Tushita (Hydra Island)")
	SafeInvoke("requestEntrance",Vector3.new(-12386.9,364.3,-7590.2)); task.wait(0.5)
	TP(CFrame.new(-12386.9,364.3,-7590.2)); task.wait(0.8)
	SafeInvoke("StartQuest","TushitaQuest",1); task.wait(3)
	for _,target in ipairs({"Longma","Tushita"}) do
		local mob=GetEnemy(target)
		if mob and IsAlive(mob) then KillMob(mob); break end
	end
	task.wait(2); TushitaDone=hasTushita()
end

-- Maestria mínima exigida para Yama e Tushita antes de pegar a CDK
local YAMA_MASTERY_NEEDED    = 400
local TUSHITA_MASTERY_NEEDED = 400

local function FarmYamaMastery()
	-- Vai até a Ilha Empress e mata para acumular maestria da Yama
	setStatus("⚔️ CDK: Treinando Yama ["..getSwordMastery("Yama").."/"..(YAMA_MASTERY_NEEDED).."]")
	EquipWeaponForPhase()  -- garante que Yama está equipada
	SafeInvoke("StartQuest","YamaQuest",1); task.wait(0.3)
	local mob = GetEnemy("Island Empress") or GetEnemy("Yama") or GetEnemy("Awakened Ice Admiral")
	if mob and IsAlive(mob) then
		MoveToMob(mob); AutoHaki(); Attack()
	else
		TweenPlayer(CFrame.new(8037.26, 249.33, -1034.44))
	end
end

local function FarmTushitaMastery()
	-- Vai até Hydra Island e mata para acumular maestria da Tushita
	setStatus("📜 CDK: Treinando Tushita ["..getSwordMastery("Tushita").."/"..(TUSHITA_MASTERY_NEEDED).."]")
	EquipWeaponForPhase()  -- garante que Tushita está equipada
	SafeInvoke("requestEntrance", Vector3.new(-12386.9, 364.3, -7590.2)); task.wait(0.5)
	SafeInvoke("StartQuest","TushitaQuest",1); task.wait(0.3)
	local mob = GetEnemy("Longma") or GetEnemy("Tushita") or GetEnemy("Cursed Skeleton")
	if mob and IsAlive(mob) then
		MoveToMob(mob); AutoHaki(); Attack()
	else
		TweenPlayer(CFrame.new(-12386.9, 364.3, -7590.2))
	end
end

local function DoCDKQuest()
	if CDKDone or hasCDK() then CDKDone=true return end
	setStatus("⚔️ Quest CDK")

	-- Passo 1: Obter Yama
	if not hasYama() then
		setStatus("⚔️ CDK: Farmando Yama (item)")
		SafeInvoke("StartQuest","YamaQuest",1); task.wait(0.5)
		local mob = GetEnemy("Island Empress") or GetEnemy("Yama")
		if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack()
		else TweenPlayer(CFrame.new(8037.26, 249.33, -1034.44)) end
		return
	end

	-- Passo 2: Treinar maestria da Yama até o mínimo
	if getSwordMastery("Yama") < YAMA_MASTERY_NEEDED then
		FarmYamaMastery(); return
	end

	-- Passo 3: Obter Tushita
	if not hasTushita() then
		DoTushitaQuest(); return
	end

	-- Passo 4: Treinar maestria da Tushita até o mínimo
	if getSwordMastery("Tushita") < TUSHITA_MASTERY_NEEDED then
		FarmTushitaMastery(); return
	end

	-- Passo 5: Obter CDK
	setStatus("⚔️ CDK: Tudo pronto! Obtendo CDK!")
	SafeInvoke("GetCDK"); task.wait(3)
	CDKDone = hasCDK()
end

local function DoSkullGuitarQuest()
	if SkullGuitarDone or hasSkullGuitar() then SkullGuitarDone=true return end
	local frag=checkMaterial("Dark Fragment")
	local ecto=checkMaterial("Ectoplasm")
	local bone=checkMaterial("Bone")
	if frag>=1 and ecto>=250 and bone>=500 then
		setStatus("🎸 Fazendo Quest Skull Guitar!")
		SafeInvoke("StartQuest","SkullGuitarQuest",1); task.wait(3)
		SkullGuitarDone=hasSkullGuitar(); return
	end
	if frag<1 then
		local db=GetEnemy("Darkbeard") or GetEnemy("Dark Beard")
		if db and IsAlive(db) then
			setStatus("💎 Skull Guitar: Matando Darkbeard"); KillMob(db)
		else
			setStatus("💎 Skull Guitar: Aguardando Darkbeard (frag:"..frag..")")
			TweenPlayer(CFrame.new(3798.45,13.82,-3399.80)); task.wait(5)
			if not GetEnemy("Darkbeard") and not GetEnemy("Dark Beard") then Hop() end
		end
	elseif ecto<250 then
		setStatus("⚗️ Skull Guitar: Ecto no Navio Assombrado ("..ecto.."/250)")
		local mob=GetEnemy("Zombie") or GetEnemy("Demonic Soul") or GetEnemy("Cursed Skeleton")
		if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack()
		else TweenPlayer(CFrame.new(3898,22,-4100)) end
	elseif bone<500 then
		setStatus("🦴 Skull Guitar: Bones no Castelo Assombrado ("..bone.."/500)")
		local mob=GetEnemy("Possessed Mummy") or GetEnemy("Reaper") or GetEnemy("Cursed Skeleton")
		if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack()
		else TweenPlayer(CFrame.new(5500,22,-3200)) end
	end
end

local function DoTyrantOfSkies()
	if TyrantDone then return end
	setStatus("🌪️ Tirant of Skies — NPCs Tiki")
	local tyrant=GetEnemy("Tyrant") or GetEnemy("TyrantOfSkies")
	if tyrant and IsAlive(tyrant) then
		setStatus("🌪️ Derrotando Tirant of Skies!")
		KillMob(tyrant); TyrantDone=true; return
	end
	SafeInvoke("SummonTyrant"); task.wait(1)
	local npcs={"Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion","Serpent Hunter","Skull Slayer"}
	for _,n in ipairs(npcs) do
		local mob=GetEnemy(n)
		if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack(); return end
	end
	TweenPlayer(CFrame.new(-16547,56,-172))
end

local function DoRaidSea3()
	local frags=getFragments()
	if frags>=5000 then return end
	setStatus("🌀 Raid — Fragmentos: "..frags.."/5000")
	local hasChip=hasItem("Special Microchip")
	if not hasChip then
		local inv=SafeInvoke("getInventoryFruits")
		if type(inv)=="table" then
			for _,v in ipairs(inv) do
				if type(v.Price)=="number" and v.Price<1000000 then
					SafeInvoke("RaidsNpc","Select",v.Name or "Flame"); return
				end
			end
		end
		SafeInvoke("RaidsNpc","Select","Flame")
	else
		SafeInvoke("requestEntrance",Vector3.new(-5097.93,316.44,-3142.66)); task.wait(0.5)
		TweenPlayer(CFrame.new(-5033.50,315.01,-2947.77)); task.wait(0.5)
		pcall(function() fireclickdetector(workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector) end)
	end
end

task.spawn(function()
	while true do
		task.wait(30)
		pcall(function()
			if not HakiKenBought and getBeli()>=2000 then
				SafeInvoke("KenTalk","Buy"); SafeInvoke("BuyHaki","Geppo"); SafeInvoke("BuyHaki","Soru"); task.wait(0.5)
				HakiKenBought=hasHakiKen()
			end
		end)
	end
end)

local mainLoopActive=true
task.spawn(function()
	task.wait(6)
	pcall(function()
		if getBeli()>=2000 then SafeInvoke("KenTalk","Buy") SafeInvoke("BuyHaki","Geppo") SafeInvoke("BuyHaki","Soru") HakiKenBought=hasHakiKen() end
	end)
	while mainLoopActive do
		task.wait(0.25)
		local ok,_=pcall(function()
			if FruitGrabbing then return end
			local lv=getLevel(); local beli=getBeli(); local frags=getFragments()
			if World1 then
				local db=GetEnemy("Darkbeard") or GetEnemy("Dark Beard")
				if db and IsAlive(db) then setStatus("⚔️ DARK BEARD SEA1!"); KillMob(db); return end
				if lv<=1 and beli<150000 then FarmChests()
				elseif beli>=150000 and not BlackLegDone then AdvanceFightStyle()
				elseif lv<5 then setStatus("🗡️ Farm inicial Lv"..lv); DoFarmLevel()
				elseif lv<150 then
					setStatus("🌤️ Farm Sky Island Lv"..lv)
					local mob=GetEnemy("Sky Bandit") or GetEnemy("Dark Master") or GetEnemy("Galley Captain")
					if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack()
					else TweenPlayer(CFrame.new(-4953,296,-2899)) end
				elseif not SaberDone and lv>=200 then DoSaberQuest()
				elseif not HakiKenBought and beli>=750000 then
					setStatus("👁️ Comprando Haki Observação")
					TweenPlayer(CFrame.new(-1785,25,-75)); task.wait(0.8)
					SafeInvoke("KenTalk","Buy"); HakiKenBought=true
				else
					if not AdvanceFightStyle() then DoFarmLevel() end
				end
			elseif World2 then
				local db=GetEnemy("Darkbeard") or GetEnemy("Dark Beard")
				local tk=GetEnemy("Tide Keeper") or GetEnemy("TideKeeper")
				local ia=GetEnemy("Ice Admiral")
				if db and IsAlive(db) then setStatus("⚔️ DARK BEARD! Prioridade!"); KillMob(db); _mc.t=0; return end
				if tk and IsAlive(tk) then
					setStatus("🌊 TIDE KEEPER!"); KillMob(tk); task.wait(2)
					if hasItem("Key") or hasItem("Tidekeeper") then TP(CFrame.new(1000,120,4000)); task.wait(0.5); SafeInvoke("StartQuest","SharkmanV2Quest","Key") end; return
				end
				if ia and IsAlive(ia) then
					setStatus("❄️ ICE ADMIRAL!"); TweenPlayer(CFrame.new(1128,14,-3205)); KillMob(ia); task.wait(2)
					if hasItem("Key") then SafeInvoke("OpenPassage","Rengoku") end; return
				end
				if getgenv().TRonConfig.StayS2ForDarkFragment then
					local frag=checkMaterial("Dark Fragment"); local ecto=checkMaterial("Ectoplasm")
					if frag<1 then
						setStatus("💎 Sea2: Aguardando Darkbeard")
						TweenPlayer(CFrame.new(3798.45,13.82,-3399.80)); task.wait(4)
						if not GetEnemy("Darkbeard") and not GetEnemy("Dark Beard") then Hop() end
					elseif ecto<250 then
						setStatus("⚗️ Sea2: Farmando Ectoplasm ("..ecto.."/250)")
						local mob=GetEnemy("Zombie") or GetEnemy("Demonic Soul")
						if mob and IsAlive(mob) then MoveToMob(mob); AutoHaki(); Attack()
						else TweenPlayer(CFrame.new(3898,22,-4100)) end
					else setStatus("✅ Sea2: Materiais prontos!") end
					return
				end
				if lv>=1500 then
					local legFruit=nil
					pcall(function()
						local legNames={"Quake","Love","Creation","Spider","Sound","Phoenix"}
						for _,t in ipairs(workspace:GetDescendants()) do
							if t:IsA("Tool") and (t.ToolTip=="Fruit" or t:GetAttribute("Type")=="Fruit") then
								for _,f in ipairs(legNames) do
									if t.Name:lower():find(f:lower()) then legFruit=t break end
								end
								if legFruit then return end
							end
						end
					end)
					if legFruit then
						setStatus("🍎 Fruta Lendária para Sea 3: "..legFruit.Name)
						local h=legFruit:FindFirstChild("Handle")
						if h then TP(CFrame.new(h.Position+Vector3.new(0,3,0))); task.wait(0.3); local pp=legFruit:FindFirstChildWhichIsA("ProximityPrompt"); if pp then pcall(function() fireproximityprompt(pp) end) end end
					else
						setStatus("🔍 Lv1500+: Procurando Frutas Lendárias...")
						task.wait(4); Hop()
					end
					return
				end
				if not AdvanceFightStyle() then DoFarmLevel() end
			elseif World3 then
				local dough=GetEnemy("Dough King") or GetEnemy("Katakuri")
				local rip=GetEnemy("Rip_Indra") or GetEnemy("Rip Indra")
				local cake=GetEnemy("Cake Prince") or GetEnemy("Katakuri V1")
				local elite=GetEnemy("Diablo") or GetEnemy("Urban") or GetEnemy("Deandre") or GetEnemy("Elite Boss")
				if dough and IsAlive(dough) then setStatus("🍩 DOUGH KING! PRIORIDADE!"); KillMob(dough); _mc.t=0; return end
				if rip and IsAlive(rip) then
					if not TushitaDone then DoTushitaQuest()
					else setStatus("⚔️ RIP INDRA!"); KillMob(rip) end; return
				end
				if cake and IsAlive(cake) then setStatus("🎂 CAKE PRINCE!"); KillMob(cake); return end
				if elite and IsAlive(elite) then
					setStatus("👑 ELITE BOSS!"); SafeInvoke("EliteHunter"); task.wait(0.5)
					TweenPlayer(elite.HumanoidRootPart.CFrame*Pos); KillMob(elite); return
				end
				if lv>=2600 and not TyrantDone then DoTyrantOfSkies(); return end
				if lv>=2300 and not SkullGuitarDone then DoSkullGuitarQuest(); return end
				if getgenv().TRonConfig.CDK and not CDKDone and hasYama() and hasTushita() then DoCDKQuest(); return end
				if frags<5000 then DoRaidSea3(); return end
				if not AdvanceFightStyle() then DoFarmLevel() end
			else
				setStatus("⚠️ Sea desconhecido — PlaceId: "..PID); task.wait(3)
			end
		end)
		if not ok then task.wait(2) end
	end
end)

local SG=Instance.new("ScreenGui")
SG.Name="TRonVoidKaitunV2"; SG.ResetOnSpawn=false; SG.IgnoreGuiInset=true
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.DisplayOrder=9999
if not pcall(function() SG.Parent=game.CoreGui end) then SG.Parent=LP:WaitForChild("PlayerGui") end

local Main=Instance.new("Frame",SG)
Main.Name="MainFrame"; Main.Size=UDim2.new(0,590,0,690)
Main.Position=UDim2.new(0.5,-295,0.5,-345); Main.BackgroundColor3=Color3.fromRGB(0,0,0); Main.BorderSizePixel=0; Main.ClipsDescendants=true
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,14)
local MS=Instance.new("UIStroke",Main); MS.Color=Color3.fromRGB(100,0,200); MS.Thickness=2
local MG=Instance.new("UIGradient",Main); MG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(4,0,14)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,0,20))}); MG.Rotation=135

local TopAccent=Instance.new("Frame",Main); TopAccent.Size=UDim2.new(1,0,0,3); TopAccent.BackgroundColor3=Color3.fromRGB(100,0,200); TopAccent.BorderSizePixel=0
local TAG=Instance.new("UIGradient",TopAccent); TAG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.3,Color3.fromRGB(100,0,200)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(180,60,255)),ColorSequenceKeypoint.new(0.7,Color3.fromRGB(100,0,200)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))})

local TopBar=Instance.new("Frame",Main); TopBar.Size=UDim2.new(1,0,0,55); TopBar.BackgroundColor3=Color3.fromRGB(3,0,12); TopBar.BorderSizePixel=0
Instance.new("UICorner",TopBar).CornerRadius=UDim.new(0,12)
local TBS=Instance.new("UIStroke",TopBar); TBS.Color=Color3.fromRGB(60,0,120); TBS.Thickness=1

local LogoFrame=Instance.new("Frame",TopBar); LogoFrame.Size=UDim2.new(0,42,0,42); LogoFrame.Position=UDim2.new(0,8,0.5,-21); LogoFrame.BackgroundColor3=Color3.fromRGB(20,0,40); LogoFrame.BorderSizePixel=0
Instance.new("UICorner",LogoFrame).CornerRadius=UDim.new(1,0)
local LFS=Instance.new("UIStroke",LogoFrame); LFS.Color=Color3.fromRGB(160,0,255); LFS.Thickness=2
local LogoImg=Instance.new("ImageLabel",LogoFrame); LogoImg.Size=UDim2.new(1,-6,1,-6); LogoImg.Position=UDim2.new(0,3,0,3); LogoImg.BackgroundTransparency=1; LogoImg.Image="rbxassetid://133779423735605"; LogoImg.ScaleType=Enum.ScaleType.Fit

local TitleLabel=Instance.new("TextLabel",TopBar); TitleLabel.Size=UDim2.new(1,-125,0,26); TitleLabel.Position=UDim2.new(0,60,0,6); TitleLabel.BackgroundTransparency=1; TitleLabel.Text="TRon Void Hub Kaitun [BETA]"; TitleLabel.TextColor3=Color3.fromRGB(190,110,255); TitleLabel.TextSize=16; TitleLabel.Font=Enum.Font.GothamBold; TitleLabel.TextXAlignment=Enum.TextXAlignment.Left
local SubLabel=Instance.new("TextLabel",TopBar); SubLabel.Size=UDim2.new(1,-125,0,16); SubLabel.Position=UDim2.new(0,60,0,32); SubLabel.BackgroundTransparency=1; SubLabel.Text="Blox Fruits  •  Full Auto  •  Kaitun Support"; SubLabel.TextColor3=Color3.fromRGB(100,60,160); SubLabel.TextSize=11; SubLabel.Font=Enum.Font.Gotham; SubLabel.TextXAlignment=Enum.TextXAlignment.Left

local CloseBtn=Instance.new("TextButton",TopBar); CloseBtn.Size=UDim2.new(0,32,0,32); CloseBtn.Position=UDim2.new(1,-40,0.5,-16); CloseBtn.BackgroundColor3=Color3.fromRGB(90,0,150); CloseBtn.Text="✕"; CloseBtn.TextColor3=Color3.fromRGB(255,255,255); CloseBtn.TextSize=14; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.AutoButtonColor=false; CloseBtn.BorderSizePixel=0
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",CloseBtn).Color=Color3.fromRGB(200,0,255)
CloseBtn.MouseButton1Click:Connect(function() mainLoopActive=false; FarmRunning=false; SG:Destroy() end)
CloseBtn.MouseEnter:Connect(function() TweenSvc:Create(CloseBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(180,0,50)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenSvc:Create(CloseBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(90,0,150)}):Play() end)

local Scroll=Instance.new("ScrollingFrame",Main); Scroll.Size=UDim2.new(1,-4,1,-60); Scroll.Position=UDim2.new(0,2,0,58); Scroll.BackgroundTransparency=1; Scroll.ScrollBarThickness=4; Scroll.ScrollBarImageColor3=Color3.fromRGB(100,0,200); Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.BorderSizePixel=0
local SLL=Instance.new("UIListLayout",Scroll); SLL.SortOrder=Enum.SortOrder.LayoutOrder; SLL.Padding=UDim.new(0,6)
local SPad=Instance.new("UIPadding",Scroll); SPad.PaddingLeft=UDim.new(0,7); SPad.PaddingRight=UDim.new(0,7); SPad.PaddingTop=UDim.new(0,7); SPad.PaddingBottom=UDim.new(0,7)

local function mkSec(txt)
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(1,0,0,26); f.BackgroundColor3=Color3.fromRGB(30,0,58); f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
	local s=Instance.new("UIStroke",f); s.Color=Color3.fromRGB(90,0,160); s.Thickness=1
	local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-10,1,0); l.Position=UDim2.new(0,8,0,0); l.BackgroundTransparency=1; l.Text="▸  "..txt; l.TextColor3=Color3.fromRGB(200,130,255); l.TextSize=12; l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
end

local function mkCard(h)
	local f=Instance.new("Frame",Scroll); f.Size=UDim2.new(1,0,0,h); f.BackgroundColor3=Color3.fromRGB(5,0,14); f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
	local s=Instance.new("UIStroke",f); s.Color=Color3.fromRGB(40,0,80); s.Thickness=1
	return f
end

local function mkLbl(parent,txt,sz,col,x,y,w,h)
	local l=Instance.new("TextLabel",parent); l.Size=UDim2.new(w or 1,-14,0,h or 20); l.Position=UDim2.new(x or 0,7,y or 0,4); l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=col or Color3.fromRGB(200,200,200); l.TextSize=sz or 12; l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; return l
end

local function mkBadge(parent,txt,x,y,w,h,bgc)
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(w or 0.5,-8,0,h or 22); f.Position=UDim2.new(x or 0,x==0 and 7 or 2,0,(y or 0)*26+6); f.BackgroundColor3=bgc or Color3.fromRGB(8,0,20); f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
	local s=Instance.new("UIStroke",f); s.Color=Color3.fromRGB(55,0,100); s.Thickness=1
	local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-4,1,0); l.Position=UDim2.new(0,2,0,0); l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=Color3.fromRGB(160,160,160); l.TextSize=11; l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Center; l.TextYAlignment=Enum.TextYAlignment.Center; l.TextWrapped=false
	return f,l
end

mkSec("📍 Localização Detectada")
local seaCard=mkCard(36)
local seaTxt=World1 and "🌊 SEA 1 — First Sea" or World2 and "🌊 SEA 2 — Second Sea" or World3 and "🌊 SEA 3 — Third Sea" or "⚠️ Sea desconhecido (PlaceId: "..PID..")"
local seaColor=World1 and Color3.fromRGB(80,180,255) or World2 and Color3.fromRGB(80,255,160) or World3 and Color3.fromRGB(255,180,80) or Color3.fromRGB(255,100,100)
mkLbl(seaCard,seaTxt,13,seaColor,0,0,1,28)

mkSec("⚡ Status Atual")
local statusCard=mkCard(50)
local statusLbl=Instance.new("TextLabel",statusCard)
statusLbl.Size=UDim2.new(1,-14,1,-8); statusLbl.Position=UDim2.new(0,7,0,4); statusLbl.BackgroundTransparency=1
statusLbl.Text="⚡ Inicializando..."; statusLbl.TextColor3=Color3.fromRGB(80,255,180); statusLbl.TextSize=13
statusLbl.Font=Enum.Font.GothamBold; statusLbl.TextXAlignment=Enum.TextXAlignment.Left; statusLbl.TextWrapped=true
getgenv().TRonStatusLabel=statusLbl

mkSec("🎒 Inventário — Itens Especiais")
local invCard=mkCard(100)
local invDefs={{n="God Human",fn=hasGodHuman,x=0,r=0},{n="CDK",fn=hasCDK,x=0.5,r=0},{n="Valkiria Rip",fn=hasValkiria,x=0,r=1},{n="Mirror Fractal",fn=hasMirrorFractal,x=0.5,r=1},{n="Saber",fn=hasSaber,x=0,r=2},{n="Tushita",fn=hasTushita,x=0.5,r=2}}
local invLabels={}
for _,d in ipairs(invDefs) do
	local _f,lbl=mkBadge(invCard,(d.fn() and "✅ " or "❌ ")..d.n,d.x,d.r)
	lbl.TextColor3=d.fn() and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80)
	table.insert(invLabels,{lbl=lbl,fn=d.fn,name=d.n})
end
task.spawn(function()
	while true do task.wait(4)
		for _,d in ipairs(invLabels) do pcall(function() local h=d.fn(); d.lbl.Text=(h and "✅ " or "❌ ")..d.name; d.lbl.TextColor3=h and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80) end) end
	end
end)

mkSec("👁️ Detector de Bosses")
local bossCard=mkCard(130)
local bossDefs={{n="Dark Beard",s="darkbeard",r=0,x=0,c=Color3.fromRGB(255,100,100)},{n="Tide Keeper",s="tide keeper",r=0,x=0.5,c=Color3.fromRGB(100,200,255)},{n="Ice Admiral",s="ice admiral",r=1,x=0,c=Color3.fromRGB(180,220,255)},{n="Dough King",s="dough king",r=1,x=0.5,c=Color3.fromRGB(255,220,80)},{n="Rip Indra",s="rip_indra",r=2,x=0,c=Color3.fromRGB(200,120,255)},{n="Cake Prince",s="cake prince",r=2,x=0.5,c=Color3.fromRGB(255,160,200)},{n="Elite Boss",s="diablo",r=3,x=0,c=Color3.fromRGB(255,160,80)},{n="Skull Guitar",s="skull guitar",r=3,x=0.5,c=Color3.fromRGB(130,255,130)}}
local bossLabels={}
for _,d in ipairs(bossDefs) do
	local _f,lbl=mkBadge(bossCard,"❌ "..d.n,d.x,d.r); lbl.TextColor3=Color3.fromRGB(100,100,100)
	bossLabels[d.s]={lbl=lbl,info=d}
end
task.spawn(function()
	while true do task.wait(2.5)
		for s,d in pairs(bossLabels) do pcall(function() local found=GetEnemy(s)~=nil; d.lbl.Text=(found and "✅ " or "❌ ")..d.info.n; d.lbl.TextColor3=found and d.info.c or Color3.fromRGB(80,80,80) end) end
	end
end)

mkSec("⚗️ Materiais Skull Guitar")
local matCard=mkCard(70)
local matEctoLbl=mkLbl(matCard,"⚗️ Ectoplasm: ···/250",12,Color3.fromRGB(150,255,200),0,0,0.5,22)
local matFragLbl=mkLbl(matCard,"💎 Dark Fragment: ···/1",12,Color3.fromRGB(255,180,80),0.5,0,0.5,22)
local matBoneLbl=mkLbl(matCard,"🦴 Bone: ···/500",12,Color3.fromRGB(220,220,180),0,1,0.5,22)
local matSGLbl=mkLbl(matCard,"🎸 Skull Guitar: Pendente",12,Color3.fromRGB(200,100,255),0.5,1,0.5,22)
task.spawn(function()
	while true do task.wait(9)
		pcall(function()
			_mc.t=0; local e=checkMaterial("Ectoplasm"); local f=checkMaterial("Dark Fragment"); local b=checkMaterial("Bone")
			matEctoLbl.Text="⚗️ Ectoplasm: "..e.."/250"; matEctoLbl.TextColor3=e>=250 and Color3.fromRGB(80,255,120) or Color3.fromRGB(150,255,200)
			matFragLbl.Text="💎 Dark Fragment: "..f.."/1"; matFragLbl.TextColor3=f>=1 and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,180,80)
			matBoneLbl.Text="🦴 Bone: "..b.."/500"; matBoneLbl.TextColor3=b>=500 and Color3.fromRGB(80,255,120) or Color3.fromRGB(220,220,180)
			matSGLbl.Text=SkullGuitarDone and "🎸 Skull Guitar: ✅" or "🎸 Skull Guitar: Pendente"; matSGLbl.TextColor3=SkullGuitarDone and Color3.fromRGB(80,255,120) or Color3.fromRGB(200,100,255)
		end)
	end
end)

mkSec("🔱 Haki — Sempre Ativo")
local hakiCard=mkCard(40)
mkLbl(hakiCard,"🔱 Armamento (Buso): ATIVO via RemoteEvent Buso",12,Color3.fromRGB(255,200,80),0,0,1,18)
mkLbl(hakiCard,"👁️ Observação (Ken): ATIVO via RemoteEvent Ken",12,Color3.fromRGB(80,200,255),0,1,1,18)

mkSec("🥋 Estilos de Luta")
local styleCard=mkCard(100)
local styleDefs={{n="Black Leg",fn=function() return hasFightingStyle("Black Leg") end},{n="Electric",fn=function() return hasFightingStyle("Electric") end},{n="Sharkman Karate",fn=function() return hasFightingStyle("Sharkman Karate") end},{n="Dragon Breath",fn=function() return hasFightingStyle("Dragon Breath") end},{n="Death Step",fn=function() return hasFightingStyle("Death Step") end},{n="Electric Claw",fn=function() return hasFightingStyle("Electric Claw") end},{n="Dragon Talon",fn=function() return hasFightingStyle("Dragon Talon") end},{n="God Human",fn=hasGodHuman}}
local styleLabels={}
for i,d in ipairs(styleDefs) do
	local col=(i-1)%2; local row=math.floor((i-1)/2)
	local _f,lbl=mkBadge(styleCard,(d.fn() and "✅ " or "○ ")..d.n,col*0.5,row)
	lbl.TextColor3=d.fn() and Color3.fromRGB(80,255,120) or Color3.fromRGB(120,120,120); lbl.Font=Enum.Font.Gotham
	table.insert(styleLabels,{lbl=lbl,fn=d.fn,name=d.n})
end
task.spawn(function()
	while true do task.wait(5)
		for _,d in ipairs(styleLabels) do pcall(function() local h=d.fn(); d.lbl.Text=(h and "✅ " or "○ ")..d.name; d.lbl.TextColor3=h and Color3.fromRGB(80,255,120) or Color3.fromRGB(120,120,120) end) end
	end
end)

mkSec("⏱️ Auto Hop")
local hopCard=mkCard(44)
local hopTimerLbl=mkLbl(hopCard,"⏳ Próximo hop: calculando...",12,Color3.fromRGB(180,140,255),0,0,1,36)
task.spawn(function()
	while SG and SG.Parent do
		task.wait(1)
		pcall(function()
			local interval=math.max(60,getgenv().TRonConfig.HopInterval or 1800)
			local elapsed=(tick()%interval)
			local remaining=math.floor(interval-elapsed)
			local mins=math.floor(remaining/60); local secs=remaining%60
			if getgenv().TRonConfig.AutoHop then
				hopTimerLbl.Text=string.format("⏳ Próximo hop em: %02d:%02d",mins,secs)
				hopTimerLbl.TextColor3=remaining<120 and Color3.fromRGB(255,100,80) or Color3.fromRGB(180,140,255)
			else
				hopTimerLbl.Text="🚫 Auto Hop desativado"
				hopTimerLbl.TextColor3=Color3.fromRGB(120,120,120)
			end
		end)
	end
end)

mkSec("💬 Comunidade TRon Void")
local discCard=mkCard(44)
mkLbl(discCard,"Join On TRON VOID COMMUNITY — discord.gg/f4K5sDwKkn",12,Color3.fromRGB(130,140,255),0,0,0.72,40)
local discBtn=Instance.new("TextButton",discCard); discBtn.Size=UDim2.new(0,110,0,30); discBtn.Position=UDim2.new(1,-118,0.5,-15); discBtn.BackgroundColor3=Color3.fromRGB(88,101,242); discBtn.Text="Copy Discord"; discBtn.TextColor3=Color3.fromRGB(255,255,255); discBtn.TextSize=11; discBtn.Font=Enum.Font.GothamBold; discBtn.AutoButtonColor=false; discBtn.BorderSizePixel=0
Instance.new("UICorner",discBtn).CornerRadius=UDim.new(0,8)
discBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard("https://discord.gg/f4K5sDwKkn") end); discBtn.Text="✅ Copiado!"; task.delay(2,function() discBtn.Text="Copy Discord" end) end)

mkSec("⚙️ Getgenv Config")
local genvCard=mkCard(138)
mkLbl(genvCard,"getgenv().TRonConfig = {\n  Team = \"Pirate\",     -- Pirate/Marine\n  FullFightStyles = true, -- Até God Human\n  CDK = true,           -- Quest CDK completa\n  SkyFarm = true,       -- Farm do céu\n  SkyHeight = 175,      -- Altura acima NPC\n  AutoHop = true,       -- Hop automático\n  HopInterval = 1800,   -- Segundos (1800=30min)\n  TweenSpeed = 350,     -- studs/s\n  EatFruit = true,\n  FruitToEat = \"\",\n}",10,Color3.fromRGB(160,160,255),0,0,1,126)

local dragging,dragStart,dragStartPos
TopBar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=inp.Position; dragStartPos=Main.Position end end)
TopBar.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
UIS.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then local d=inp.Position-dragStart; Main.Position=UDim2.new(dragStartPos.X.Scale,dragStartPos.X.Offset+d.X,dragStartPos.Y.Scale,dragStartPos.Y.Offset+d.Y) end end)

local HideBtn=Instance.new("ImageButton",SG); HideBtn.Size=UDim2.new(0,52,0,52); HideBtn.Position=UDim2.new(0,12,1,-64); HideBtn.BackgroundColor3=Color3.fromRGB(0,0,0); HideBtn.Image="rbxassetid://133779423735605"; HideBtn.ScaleType=Enum.ScaleType.Fit; HideBtn.ClipsDescendants=true; HideBtn.BorderSizePixel=0
Instance.new("UICorner",HideBtn).CornerRadius=UDim.new(1,0)
local HBS=Instance.new("UIStroke",HideBtn); HBS.Color=Color3.fromRGB(120,0,200); HBS.Thickness=2
HideBtn.MouseButton1Click:Connect(function() Main.Visible=not Main.Visible end)
local hdrag,hdragStart,hdragPos
HideBtn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then hdrag=true; hdragStart=inp.Position; hdragPos=HideBtn.Position end end)
HideBtn.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then hdrag=false end end)
UIS.InputChanged:Connect(function(inp) if hdrag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then local d=inp.Position-hdragStart; HideBtn.Position=UDim2.new(hdragPos.X.Scale,hdragPos.X.Offset+d.X,hdragPos.Y.Scale,hdragPos.Y.Offset+d.Y) end end)

task.spawn(function()
	local hue=0
	while SG and SG.Parent do
		task.wait(0.05); hue=(hue+0.008)%1
		local c=Color3.fromHSV(hue,1,0.9)
		pcall(function() MS.Color=c; HBS.Color=c; LFS.Color=c; TopAccent.BackgroundColor3=c end)
	end
end)

setStatus("TRon Void Hub Kaitun [BETA] — Pronto! | "..LP.Name)
