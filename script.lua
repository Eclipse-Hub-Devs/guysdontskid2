if getgenv().TRonVoidKaitun then
	pcall(function()
		for _,v in ipairs(game.CoreGui:GetChildren()) do
			if v.Name:find("TRonVoidKaitun") then v:Destroy() end
		end
	end)
end
getgenv().TRonVoidKaitun = true

getgenv().TRonConfig = getgenv().TRonConfig or {
	Team              = "Pirate",
	FullFightStyles   = true,
	CDK               = true,
	StayS2ForDarkFragment = false,
	FixLag            = false,
	TweenSpeed        = 0.35,
	EatFruit          = true,
	FruitToEat        = "",
}

task.spawn(function()
	local P = game:GetService("Players").LocalPlayer
	repeat task.wait() until game:IsLoaded()
	repeat task.wait() until P and P.Character
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhDangNhoEm/TuanAnhIOS/refs/heads/main/koby"))()
	end)
end)

local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local RunSvc     = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local VIM        = game:GetService("VirtualInputManager")
local RS         = game:GetService("ReplicatedStorage")
local LP         = Players.LocalPlayer

repeat task.wait(0.5) until game:IsLoaded()
repeat task.wait(0.5) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

local PID = game.PlaceId
World1 = PID==2753915549 or PID==85211729168715
World2 = PID==4442272183 or PID==79091703265657
World3 = PID==7449423635 or PID==100117331123089

local function CommF_(...)
	local ok,res = pcall(function() return RS.Remotes.CommF_:InvokeServer(...) end)
	return ok and res or nil
end

local function CommE_(...)
	pcall(function() RS.Remotes.CommE:FireServer(...) end)
end

local function getLevel()
	return LP.Data and LP.Data.Level and LP.Data.Level.Value or 1
end

local function getBeli()
	local ls = LP:FindFirstChild("leaderstats")
	return ls and ls:FindFirstChild("Beli") and ls.Beli.Value or 0
end

local function getMastery(styleName)
	local m = 0
	pcall(function()
		local d = LP.Data.FightingStyles
		for _,v in ipairs(d:GetChildren()) do
			if v.Name:lower():find(styleName:lower()) then
				m = v.Value or 0
			end
		end
	end)
	return m
end

local function hasItem(name)
	local found = false
	pcall(function()
		for _,t in ipairs(LP.Backpack:GetChildren()) do
			if t.Name:lower():find(name:lower()) then found=true end
		end
		if not found and LP.Character then
			for _,t in ipairs(LP.Character:GetChildren()) do
				if t.Name:lower():find(name:lower()) then found=true end
			end
		end
	end)
	return found
end

local function checkMaterial(name)
	local count = 0
	pcall(function()
		local inv = CommF_("getInventory")
		if inv then
			for _,v in ipairs(inv) do
				if v.Name and v.Name:lower():find(name:lower()) then
					count = (v.Count or v.Amount or 1)
				end
			end
		end
	end)
	return count
end

local function hasGodHuman()  return hasItem("God Human") end
local function hasCDK()       return hasItem("Cursed Dual Katana") end
local function hasValkiria()  return hasItem("Valkiria") or hasItem("Valkirie") end
local function hasMirrorFractal() return hasItem("Mirror Fractal") end

getgenv().TRonStatus = "Inicializando..."
getgenv().TRonStatusLabel = nil

local function setStatus(s)
	getgenv().TRonStatus = s
	pcall(function()
		if getgenv().TRonStatusLabel then
			getgenv().TRonStatusLabel.Text = "⚡ " .. tostring(s)
		end
	end)
end

local StopTweenFlag = false
local function TweenPlayer(cf)
	StopTweenFlag = false
	pcall(function()
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local speed = getgenv().TRonConfig.TweenSpeed or 0.35
		local dist = (hrp.Position - cf.Position).Magnitude
		local t = math.clamp(dist / 800, 0.05, 4) * (speed / 0.35)
		local tw = TweenSvc:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
		tw:Play()
		local elapsed = 0
		while tw.PlaybackState ~= Enum.PlaybackState.Completed do
			task.wait(0.05)
			elapsed = elapsed + 0.05
			if StopTweenFlag or elapsed > 10 then tw:Cancel() break end
		end
	end)
end

local function TeleportInstant(v3)
	pcall(function()
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(v3) end
	end)
	task.wait(0.1)
end

local function TeleportCF(cf)
	pcall(function()
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = cf end
	end)
	task.wait(0.1)
end

local function AutoHaki()
	pcall(function()
		local char = LP.Character
		if not char then return end
		local buso = char:FindFirstChild("Buso") or char:FindFirstChild("BusoHaki")
		if not buso or buso.Value ~= true then
			VIM:SendKeyEvent(true,"J",false,game)
			task.wait(0.08)
			VIM:SendKeyEvent(false,"J",false,game)
		end
		local ken = char:FindFirstChild("KenHaki") or char:FindFirstChild("Observation")
		if not ken or ken.Value ~= true then
			VIM:SendKeyEvent(true,"L",false,game)
			task.wait(0.08)
			VIM:SendKeyEvent(false,"L",false,game)
		end
	end)
end

local function Attack()
	pcall(function()
		local cfg = getgenv().HoldSkillConfig or {Z=true,X=true,C=true,V=false,F=false}
		local keys = {}
		if cfg.Z then table.insert(keys,"Z") end
		if cfg.X then table.insert(keys,"X") end
		if cfg.C then table.insert(keys,"C") end
		if cfg.V then table.insert(keys,"V") end
		if cfg.F then table.insert(keys,"F") end
		if #keys == 0 then keys = {"Z","X","C"} end
		for _,k in ipairs(keys) do
			pcall(function()
				VIM:SendKeyEvent(true,k,false,game)
				task.wait(0.07)
				VIM:SendKeyEvent(false,k,false,game)
				task.wait(0.04)
			end)
		end
	end)
end

local function GetEnemy(name)
	local found = nil
	pcall(function()
		local ef = workspace:FindFirstChild("Enemies")
		if ef then
			for _,v in ipairs(ef:GetChildren()) do
				if v.Name:lower():find(name:lower()) and v:FindFirstChild("Humanoid") and v.Humanoid.Health>0 then
					found = v
					return
				end
			end
		end
	end)
	return found
end

local function IsAlive(mob)
	return mob and mob.Parent and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0
end

local Pos = CFrame.new(0, 0, 3.5)

local function KillMob(mob, flag)
	if not IsAlive(mob) then return end
	repeat
		pcall(function()
			AutoHaki()
			TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
			Attack()
		end)
		task.wait(0.15)
	until not IsAlive(mob) or (flag ~= nil and not flag)
end

local function Hop()
	pcall(function()
		local TS = game:GetService("TeleportService")
		local replicated = RS
		for i = math.random(1,40), 100, 1 do
			local e = pcall(function()
				return replicated.__ServerBrowser:InvokeServer(i)
			end)
			if e then
				for id, sv in next, (function()
					local ok,r = pcall(function() return replicated.__ServerBrowser:InvokeServer(i) end)
					return ok and r or {}
				end)() do
					if tonumber(sv.Count) and tonumber(sv.Count) < 12 then
						TS:TeleportToPlaceInstance(game.PlaceId, id)
						return
					end
				end
			end
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(0.5)
		AutoHaki()
	end
end)

task.spawn(function()
	while true do
		task.wait(10)
		if not getgenv().TRonConfig.FixLag then continue end
		pcall(function()
			local L = game:GetService("Lighting")
			L.GlobalShadows = false
			L.FogEnd = 9e9
			for _,v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
					v.Enabled = false
				end
			end
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(60)
		pcall(function()
			VIM:SendKeyEvent(true,"Space",false,game)
			task.wait(0.5)
			VIM:SendKeyEvent(false,"Space",false,game)
		end)
	end
end)

local codes = {
	"ADMIN","BIGNEWS","BLOXFRUITS","CRYSTAL_1","SUB2GAMERROBOT_RESET1",
	"FUDD10","FUDD10_V2","STRAWHATMAINE","1MLIKES","THEGREATACE",
	"GIVEAWAYTIME","KITTGAMING","ENYU_IS_PRO","MISSOINARIE",
	"MAGICTIMENOW","ONEPIECELOVER","SEATWO","THIRDSEA",
	"SubToMikey786","SubToFlamingoYT","SubToRFedora","Jcwk","Jcwk2",
	"Bluxxy","STAVBER","DEVSCOOKING","NOOB_BOAT","BIGNEWS2",
	"ICREATEDBLOXFRUITS","ADMINNEW","DOUBLE_BELI","ICEADMIRAL",
	"GAMER_ROBOT_1M","SECRET_ADMIN","CAKEBAR","BLOX_FRUIT",
	"RESET_5TIMES","MIRRORQUEST","WELCOMEBACK","PRIDE","RAINBOW",
	"Update17Part3","Update_17_3","Sub2OfficialNoobie","TantaiGaming",
	"StrawHatMaine","Enyu_is_pro","instagramscripts","instagramscripts2",
}
task.spawn(function()
	task.wait(5)
	for _,code in ipairs(codes) do
		pcall(function() CommF_("Redeem",code) end)
		task.wait(0.4)
	end
end)

task.spawn(function()
	task.wait(4)
	pcall(function()
		local team = getgenv().TRonConfig.Team == "Marine" and "Marines" or "Pirates"
		CommF_("SetTeam", team)
	end)
end)

local Mon, NameQuest, LevelQuest, CFrameQuest, CFrameMon
Qdata=nil; Qname=nil; PosQ=nil; PosM=nil; MonFarm=nil

local function CheckQuest()
	local I = getLevel()
	if World1 and I > 699 then I = 650 end
	if World2 and I > 1499 then I = 1450 end
	if World1 then
		if I<=9 then
			Mon="Bandit";LevelQuest=1;NameQuest="BanditQuest1"
			CFrameQuest=CFrame.new(1059,17,1546);CFrameMon=CFrame.new(943,45,1562)
		elseif I<=14 then
			Mon="Monkey";LevelQuest=1;NameQuest="JungleQuest"
			CFrameQuest=CFrame.new(-1598,37,153);CFrameMon=CFrame.new(-1524,50,37)
		elseif I<=29 then
			Mon="Gorilla";LevelQuest=2;NameQuest="JungleQuest"
			CFrameQuest=CFrame.new(-1598,37,153);CFrameMon=CFrame.new(-1128,40,-451)
		elseif I<=39 then
			Mon="Pirate";LevelQuest=1;NameQuest="BuggyQuest1"
			CFrameQuest=CFrame.new(-1140,4,3829);CFrameMon=CFrame.new(-1262,40,3905)
		elseif I<=59 then
			Mon="Brute";LevelQuest=2;NameQuest="BuggyQuest1"
			CFrameQuest=CFrame.new(-1140,4,3829);CFrameMon=CFrame.new(-976,55,4304)
		elseif I<=74 then
			Mon="Desert Bandit";LevelQuest=1;NameQuest="DesertQuest"
			CFrameQuest=CFrame.new(897,6,4389);CFrameMon=CFrame.new(924,7,4482)
		elseif I<=89 then
			Mon="Desert Officer";LevelQuest=2;NameQuest="DesertQuest"
			CFrameQuest=CFrame.new(897,6,4389);CFrameMon=CFrame.new(1608,9,4371)
		elseif I<=99 then
			Mon="Snow Bandit";LevelQuest=1;NameQuest="SnowQuest"
			CFrameQuest=CFrame.new(1385,87,-1298);CFrameMon=CFrame.new(1362,120,-1531)
		elseif I<=119 then
			Mon="Snowman";LevelQuest=2;NameQuest="SnowQuest"
			CFrameQuest=CFrame.new(1385,87,-1298);CFrameMon=CFrame.new(1243,140,-1437)
		elseif I<=149 then
			Mon="Chief Petty Officer";LevelQuest=1;NameQuest="MarineQuest2"
			CFrameQuest=CFrame.new(-5035,29,4326);CFrameMon=CFrame.new(-4881,23,4274)
		elseif I<=174 then
			Mon="Sky Bandit";LevelQuest=1;NameQuest="SkyQuest"
			CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-4953,296,-2899)
		elseif I<=189 then
			Mon="Dark Master";LevelQuest=2;NameQuest="SkyQuest"
			CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-5260,391,-2229)
		elseif I<=209 then
			Mon="Prisoner";LevelQuest=1;NameQuest="PrisonerQuest"
			CFrameQuest=CFrame.new(5306,2,477);CFrameMon=CFrame.new(5099,0,474)
		elseif I<=249 then
			Mon="Dangerous Prisoner";LevelQuest=2;NameQuest="PrisonerQuest"
			CFrameQuest=CFrame.new(5306,2,477);CFrameMon=CFrame.new(5655,16,866)
		elseif I<=274 then
			Mon="Toga Warrior";LevelQuest=1;NameQuest="ColosseumQuest"
			CFrameQuest=CFrame.new(-1581,7,-2982);CFrameMon=CFrame.new(-1820,51,-2741)
		elseif I<=299 then
			Mon="Gladiator";LevelQuest=2;NameQuest="ColosseumQuest"
			CFrameQuest=CFrame.new(-1581,7,-2982);CFrameMon=CFrame.new(-1268,30,-2996)
		elseif I<=324 then
			Mon="Military Soldier";LevelQuest=1;NameQuest="MagmaQuest"
			CFrameQuest=CFrame.new(-5319,12,8515);CFrameMon=CFrame.new(-5335,46,8638)
		elseif I<=374 then
			Mon="Military Spy";LevelQuest=2;NameQuest="MagmaQuest"
			CFrameQuest=CFrame.new(-5319,12,8515);CFrameMon=CFrame.new(-5803,86,8829)
		elseif I<=399 then
			Mon="Fishman Warrior";LevelQuest=1;NameQuest="FishmanQuest"
			CFrameQuest=CFrame.new(61122,18,1567);CFrameMon=CFrame.new(60998,50,1534)
			CommF_("requestEntrance",Vector3.new(61163.85,11.67,1819.78))
		elseif I<=424 then
			Mon="Fishman Commando";LevelQuest=2;NameQuest="FishmanQuest"
			CFrameQuest=CFrame.new(61122,18,1567);CFrameMon=CFrame.new(61560,22,1799)
			CommF_("requestEntrance",Vector3.new(61163.85,11.67,1819.78))
		elseif I<=449 then
			Mon="Kilo Soldier";LevelQuest=1;NameQuest="LowerSkyQuest"
			CFrameQuest=CFrame.new(-12076,927,-9459);CFrameMon=CFrame.new(-11835,962,-9398)
		elseif I<=474 then
			Mon="Kilo Commander";LevelQuest=2;NameQuest="LowerSkyQuest"
			CFrameQuest=CFrame.new(-12076,927,-9459);CFrameMon=CFrame.new(-12294,960,-9701)
		elseif I<=499 then
			Mon="Galley Captain";LevelQuest=2;NameQuest="SkyPirateQuest"
			CFrameQuest=CFrame.new(-5082,2286,-11810);CFrameMon=CFrame.new(-4879,2253,-11938)
		elseif I<=524 then
			Mon="Sky Pirate";LevelQuest=1;NameQuest="UpperSkyQuest"
			CFrameQuest=CFrame.new(-7398,2608,-11390);CFrameMon=CFrame.new(-7277,2600,-11494)
		elseif I<=549 then
			Mon="Impostors";LevelQuest=2;NameQuest="UpperSkyQuest"
			CFrameQuest=CFrame.new(-7398,2608,-11390);CFrameMon=CFrame.new(-7631,2617,-11159)
		elseif I<=624 then
			Mon="Thunder God";LevelQuest=1;NameQuest="GodQuest"
			CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-4953,296,-2899)
		else
			Mon="Wystern Soldier";LevelQuest=2;NameQuest="GodQuest"
			CFrameQuest=CFrame.new(-4844,718,-2621);CFrameMon=CFrame.new(-5260,391,-2229)
		end
	elseif World2 then
		if I<=699 then
			Mon="Croc";LevelQuest=1;NameQuest="CrocQuest1"
			CFrameQuest=CFrame.new(889,15,3980);CFrameMon=CFrame.new(717,43,4195)
		elseif I<=724 then
			Mon="Mob Captain";LevelQuest=2;NameQuest="CrocQuest1"
			CFrameQuest=CFrame.new(889,15,3980);CFrameMon=CFrame.new(1226,41,4261)
		elseif I<=774 then
			Mon="Rebel Soldier";LevelQuest=1;NameQuest="DesertQuest2"
			CFrameQuest=CFrame.new(-5300,25,2800);CFrameMon=CFrame.new(-5200,50,2900)
		elseif I<=824 then
			Mon="Rebel Officer";LevelQuest=2;NameQuest="DesertQuest2"
			CFrameQuest=CFrame.new(-5300,25,2800);CFrameMon=CFrame.new(-5600,50,3100)
		elseif I<=874 then
			Mon="Marine Lieutenant";LevelQuest=1;NameQuest="Snow2Quest1"
			CFrameQuest=CFrame.new(1128,14,-3205);CFrameMon=CFrame.new(940,21,-3354)
		elseif I<=924 then
			Mon="Marine Captain";LevelQuest=2;NameQuest="Snow2Quest1"
			CFrameQuest=CFrame.new(1128,14,-3205);CFrameMon=CFrame.new(1402,21,-3248)
		elseif I<=974 then
			Mon="Zombie";LevelQuest=1;NameQuest="GraveyardQuest1"
			CFrameQuest=CFrame.new(3899,22,-4100);CFrameMon=CFrame.new(3731,22,-4210)
		elseif I<=1024 then
			Mon="Demonic Soul";LevelQuest=2;NameQuest="GraveyardQuest1"
			CFrameQuest=CFrame.new(3899,22,-4100);CFrameMon=CFrame.new(4200,22,-4300)
		elseif I<=1074 then
			Mon="Cocoa Warrior";LevelQuest=1;NameQuest="CandyQuest1"
			CFrameQuest=CFrame.new(-2200,14,-14500);CFrameMon=CFrame.new(-2100,45,-14600)
		elseif I<=1124 then
			Mon="Chocolate Bar Battler";LevelQuest=2;NameQuest="CandyQuest1"
			CFrameQuest=CFrame.new(-2200,14,-14500);CFrameMon=CFrame.new(-1800,45,-14500)
		elseif I<=1174 then
			Mon="Candy Rebel";LevelQuest=1;NameQuest="CandyQuest2"
			CFrameQuest=CFrame.new(-1148,14,-14446);CFrameMon=CFrame.new(-1371,70,-14405)
		elseif I<=1224 then
			Mon="Snow Demon";LevelQuest=2;NameQuest="CandyQuest2"
			CFrameQuest=CFrame.new(-1148,14,-14446);CFrameMon=CFrame.new(-836,70,-14326)
		elseif I<=1274 then
			Mon="Lava Pirate";LevelQuest=1;NameQuest="HotAndColdQuest1"
			CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-5600,30,-5100)
		elseif I<=1324 then
			Mon="Ice Pack";LevelQuest=2;NameQuest="HotAndColdQuest1"
			CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-5200,30,-5400)
		elseif I<=1374 then
			Mon="Arctic Warrior";LevelQuest=1;NameQuest="HotAndColdQuest2"
			CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-5100,30,-5600)
		elseif I<=1424 then
			Mon="Snow Lurker";LevelQuest=2;NameQuest="HotAndColdQuest2"
			CFrameQuest=CFrame.new(-5478,16,-5247);CFrameMon=CFrame.new(-4800,30,-5300)
		else
			Mon="Lab Subordinate";LevelQuest=1;NameQuest="LabQuest1"
			CFrameQuest=CFrame.new(-6438,15,-4500);CFrameMon=CFrame.new(-6300,30,-4600)
		end
	elseif World3 then
		if I<=1574 then
			Mon="Forest Pirate";LevelQuest=1;NameQuest="ForestQuest1"
			CFrameQuest=CFrame.new(5060,30,-8400);CFrameMon=CFrame.new(5200,50,-8300)
		elseif I<=1624 then
			Mon="Mythological Pirate";LevelQuest=2;NameQuest="ForestQuest1"
			CFrameQuest=CFrame.new(5060,30,-8400);CFrameMon=CFrame.new(5400,50,-8500)
		elseif I<=1674 then
			Mon="Yeti";LevelQuest=1;NameQuest="IceQuest1"
			CFrameQuest=CFrame.new(-14700,60,-12800);CFrameMon=CFrame.new(-14500,80,-12900)
		elseif I<=1724 then
			Mon="Snow Wolf";LevelQuest=2;NameQuest="IceQuest1"
			CFrameQuest=CFrame.new(-14700,60,-12800);CFrameMon=CFrame.new(-14900,80,-12700)
		elseif I<=1774 then
			Mon="Pipe Pirate";LevelQuest=1;NameQuest="MainIsland3Quest"
			CFrameQuest=CFrame.new(-12364,364,-7508);CFrameMon=CFrame.new(-12200,380,-7600)
		elseif I<=1824 then
			Mon="Possessed Mummy";LevelQuest=1;NameQuest="HauntedCastleQuest1"
			CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5400,35,-3300)
		elseif I<=1874 then
			Mon="Reaper";LevelQuest=2;NameQuest="HauntedCastleQuest1"
			CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5700,35,-3100)
		elseif I<=1924 then
			Mon="Cursed Skeleton";LevelQuest=1;NameQuest="HauntedCastleQuest2"
			CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5600,40,-3400)
		elseif I<=1974 then
			Mon="Demonic Soul";LevelQuest=2;NameQuest="HauntedCastleQuest2"
			CFrameQuest=CFrame.new(5500,22,-3200);CFrameMon=CFrame.new(5300,40,-3200)
		elseif I<=2024 then
			Mon="Captain Elephant";LevelQuest=1;NameQuest="FunkyQuest1"
			CFrameQuest=CFrame.new(5440,25,4540);CFrameMon=CFrame.new(5520,60,4500)
		elseif I<=2074 then
			Mon="Beautiful Pirate";LevelQuest=2;NameQuest="FunkyQuest1"
			CFrameQuest=CFrame.new(5440,25,4540);CFrameMon=CFrame.new(5700,60,4600)
		elseif I<=2124 then
			Mon="Surfer";LevelQuest=1;NameQuest="SurfQuest1"
			CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-3500,30,-13500)
		elseif I<=2174 then
			Mon="Fishman Raider";LevelQuest=2;NameQuest="SurfQuest1"
			CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-3800,30,-13300)
		elseif I<=2224 then
			Mon="Fishman Champion";LevelQuest=1;NameQuest="SurfQuest2"
			CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-3900,30,-13600)
		elseif I<=2274 then
			Mon="Terrorshark";LevelQuest=2;NameQuest="SurfQuest2"
			CFrameQuest=CFrame.new(-3600,14,-13400);CFrameMon=CFrame.new(-4100,30,-13200)
		elseif I<=2324 then
			Mon="Dragonite";LevelQuest=1;NameQuest="DragonQuest1"
			CFrameQuest=CFrame.new(-16300,14,-16300);CFrameMon=CFrame.new(-16200,30,-16400)
		elseif I<=2374 then
			Mon="Dragon Crew";LevelQuest=2;NameQuest="DragonQuest1"
			CFrameQuest=CFrame.new(-16300,14,-16300);CFrameMon=CFrame.new(-16500,30,-16200)
		elseif I<=2424 then
			Mon="Candy Pirate";LevelQuest=1;NameQuest="CandyQuest3"
			CFrameQuest=CFrame.new(150,25,-12777);CFrameMon=CFrame.new(17,80,-12962)
		elseif I<=2449 then
			Mon="Snow Demon";LevelQuest=2;NameQuest="CandyQuest3"
			CFrameQuest=CFrame.new(-1148,14,-14446);CFrameMon=CFrame.new(-836,70,-14326)
		elseif I<=2474 then
			Mon="Isle Outlaw";LevelQuest=1;NameQuest="TikiQuest1"
			CFrameQuest=CFrame.new(-16547,56,-172);CFrameMon=CFrame.new(-16431,90,-223)
		elseif I<=2499 then
			Mon="Island Boy";LevelQuest=2;NameQuest="TikiQuest1"
			CFrameQuest=CFrame.new(-16547,56,-172);CFrameMon=CFrame.new(-16668,70,-243)
		elseif I<=2524 then
			Mon="Sun-kissed Warrior";LevelQuest=1;NameQuest="TikiQuest2"
			CFrameQuest=CFrame.new(-16540,56,1051);CFrameMon=CFrame.new(-16345,80,1004)
		elseif I<=2549 then
			Mon="Isle Champion";LevelQuest=2;NameQuest="TikiQuest2"
			CFrameQuest=CFrame.new(-16540,56,1051);CFrameMon=CFrame.new(-16634,85,1106)
		elseif I<=2574 then
			Mon="Serpent Hunter";LevelQuest=1;NameQuest="TikiQuest3"
			CFrameQuest=CFrame.new(-16665,105,1580);CFrameMon=CFrame.new(-16542,146,1529)
		elseif I<=2599 then
			Mon="Skull Slayer";LevelQuest=2;NameQuest="TikiQuest3"
			CFrameQuest=CFrame.new(-16665,105,1580);CFrameMon=CFrame.new(-16849,147,1640)
		elseif I<=2624 then
			Mon="Reef Bandit";LevelQuest=1;NameQuest="SubmergedQuest1"
			CFrameQuest=CFrame.new(10882,-2086,10034);CFrameMon=CFrame.new(10736,-2087,9338)
			CommF_("requestEntrance",Vector3.new(10882,-2086,10034))
		elseif I<=2649 then
			Mon="Coral Pirate";LevelQuest=2;NameQuest="SubmergedQuest1"
			CFrameQuest=CFrame.new(10882,-2086,10034);CFrameMon=CFrame.new(10965,-2158,9177)
			CommF_("requestEntrance",Vector3.new(10882,-2086,10034))
		elseif I<=2674 then
			Mon="Sea Chanter";LevelQuest=1;NameQuest="SubmergedQuest2"
			CFrameQuest=CFrame.new(10882,-2086,10034);CFrameMon=CFrame.new(10621,-2087,10102)
			CommF_("requestEntrance",Vector3.new(10882,-2086,10034))
		elseif I<=2699 then
			Mon="Ocean Prophet";LevelQuest=2;NameQuest="SubmergedQuest2"
			CFrameQuest=CFrame.new(10882,-2086,10034);CFrameMon=CFrame.new(11056,-2001,10117)
			CommF_("requestEntrance",Vector3.new(10882,-2086,10034))
		elseif I<=2724 then
			Mon="High Disciple";LevelQuest=1;NameQuest="SubmergedQuest3"
			CFrameQuest=CFrame.new(9636,-1992,9609);CFrameMon=CFrame.new(9828,-1940,9693)
			CommF_("requestEntrance",Vector3.new(10882,-2086,10034))
		else
			Mon="Grand Devotee";LevelQuest=2;NameQuest="SubmergedQuest3"
			CFrameQuest=CFrame.new(9636,-1992,9609);CFrameMon=CFrame.new(9557,-1928,9859)
			CommF_("requestEntrance",Vector3.new(10882,-2086,10034))
		end
	end
	Qdata=LevelQuest; Qname=NameQuest; PosQ=CFrameQuest; PosM=CFrameMon; MonFarm=Mon
end

local FarmActive = false
local SaberDone  = false
local TushitaDone = false
local CDKDone    = false
local SkullGuitarDone = false
local TyrantDone = false
local BlackLegBought = false
local ElectricBought = false
local SharkmanV1Bought = false
local HakiBought = false

local function AutoFarmLevel()
	if not FarmActive then return end
	pcall(function()
		CheckQuest()
		if not CFrameQuest or not CFrameMon or not Mon then return end
		setStatus("Farmando Nível ["..getLevel().."] | "..tostring(Mon))
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local qGui = LP.PlayerGui:FindFirstChild("Main")
		local hasQuest = qGui and qGui:FindFirstChild("Quest") and qGui.Quest.Visible
		if not hasQuest then
			TweenPlayer(CFrameQuest)
			task.wait(0.5)
			CommF_("StartQuest", Qname, Qdata)
			task.wait(0.5)
		end
		local mob = GetEnemy(Mon)
		if mob and IsAlive(mob) then
			TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
			AutoHaki()
			Attack()
		else
			TweenPlayer(CFrameMon)
		end
	end)
end

local FruitGrabbing = false
local legendaryFruits = {"Quake","Love","Creation","Spider","Sound","Phoenix","Leopard","Dragon","Spirit","Kitsune"}

local function FindSpawnedFruit()
	local best = nil
	local bestDist = math.huge
	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	pcall(function()
		for _,v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Tool") and v.ToolTip == "Fruit" then
				if v.Parent and v.Parent:IsA("Model") then
					local h = v.Parent:FindFirstChild("Handle") or v:FindFirstChild("Handle")
					if h then
						local d = (h.Position - hrp.Position).Magnitude
						if d < bestDist then
							bestDist = d
							best = v
						end
					end
				elseif v.Parent == workspace or v.Parent == workspace:FindFirstChild("AppleSpawner") then
					local h = v:FindFirstChild("Handle")
					if h then
						local d = (h.Position - hrp.Position).Magnitude
						if d < bestDist then
							bestDist = d
							best = v
						end
					end
				end
			end
		end
	end)
	return best, bestDist
end

local function IsLegendary(fruitTool)
	if not fruitTool then return false end
	for _,f in ipairs(legendaryFruits) do
		if fruitTool.Name:lower():find(f:lower()) then return true end
	end
	return false
end

task.spawn(function()
	while true do
		task.wait(1.5)
		if not getgenv().TRonConfig.EatFruit then continue end
		pcall(function()
			local fruit, dist = FindSpawnedFruit()
			if fruit and dist and dist < 10000 then
				local prevStatus = getgenv().TRonStatus
				FruitGrabbing = true
				StopTweenFlag = true
				task.wait(0.2)
				setStatus("Pegando Fruta: "..fruit.Name)
				local h = fruit:FindFirstChild("Handle")
				if h then
					TeleportInstant(h.Position + Vector3.new(0,3,0))
					task.wait(0.5)
					local pp = fruit:FindFirstChildWhichIsA("ProximityPrompt") or (fruit.Parent and fruit.Parent:FindFirstChildWhichIsA("ProximityPrompt"))
					if pp then pcall(function() fireproximityprompt(pp) end) end
				end
				task.wait(1)
				FruitGrabbing = false
				StopTweenFlag = false
				setStatus(prevStatus)
			end
		end)
	end
end)

local function BuyFightingStyle(styleName)
	pcall(function() CommF_("BuyFightingStyle", styleName) end)
	task.wait(0.5)
end

local function AutoStatPoints()
	pcall(function()
		local pts = LP.Data and LP.Data.Points and LP.Data.Points.Value or 0
		if pts <= 0 then return end
		local melee = LP.Data.Stats and LP.Data.Stats.Melee and LP.Data.Stats.Melee.Value or 0
		local defense = LP.Data.Stats and LP.Data.Stats.Defense and LP.Data.Stats.Defense.Value or 0
		local sword2 = LP.Data.Stats and LP.Data.Stats.Sword and LP.Data.Stats.Sword.Value or 0
		if melee < 2800 then
			CommF_("AddPoint","Melee",pts)
		elseif defense < 2800 then
			CommF_("AddPoint","Defense",pts)
		elseif sword2 < 2800 then
			CommF_("AddPoint","Sword",pts)
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(3)
		AutoStatPoints()
	end
end)

local chestPos = {
	Vector3.new(977,25,1570), Vector3.new(-1250,25,900), Vector3.new(200,25,-1500),
	Vector3.new(-2000,25,-2500), Vector3.new(1800,25,-800), Vector3.new(500,120,2000),
	Vector3.new(-500,25,2800), Vector3.new(2500,25,0), Vector3.new(-800,25,-400),
	Vector3.new(1500,25,3200), Vector3.new(-3200,25,1200), Vector3.new(0,25,500),
}

local chestTimer = 0
local function FarmChestsSea1()
	setStatus("Farmando Baús Sea 1 | Timer: "..tostring(10-math.floor(chestTimer)).."s")
	for _,pos in ipairs(chestPos) do
		if FruitGrabbing then break end
		TeleportInstant(pos)
		task.wait(0.2)
		pcall(function()
			for _,v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") and
					(v.Parent.Name:lower():find("chest") or v.Parent.Parent and v.Parent.Parent.Name:lower():find("chest")) then
					if (v.Parent.Position and (v.Parent.Position - pos).Magnitude < 30) then
						fireproximityprompt(v)
					end
				end
			end
		end)
	end
	chestTimer = chestTimer + 1
	if chestTimer >= 10 then
		chestTimer = 0
		setStatus("Resetando Baús - 10s completados")
	end
end

local function DoSaberQuest()
	if SaberDone or hasItem("Saber") then SaberDone=true return end
	setStatus("Fazendo Quest da Saber Expert")
	pcall(function()
		TweenPlayer(CFrame.new(-1401.85,29.97,8.81))
		task.wait(1)
		local mob = GetEnemy("Saber Expert")
		if mob and IsAlive(mob) then
			KillMob(mob, true)
			task.wait(1)
			CommF_("ProQuestProgress","PlaceRelic")
			task.wait(30)
			if hasItem("Saber") then SaberDone = true end
		else
			TweenPlayer(CFrame.new(-1401.85,29.97,8.81))
		end
	end)
end

local function DoTushitaQuest()
	if TushitaDone then return end
	setStatus("Fazendo Quest Tushita (Hydra Island)")
	pcall(function()
		CommF_("requestEntrance",Vector3.new(-12386.9,364.3,-7590.2))
		task.wait(0.5)
		TweenPlayer(CFrame.new(-12386.9,364.3,-7590.2))
		task.wait(1)
		CommF_("StartQuest","TushitaQuest",1)
		task.wait(5)
		local mob = GetEnemy("Longma") or GetEnemy("Tushita")
		if mob and IsAlive(mob) then KillMob(mob, true) end
		task.wait(3)
		TushitaDone = true
	end)
end

local function DoCDKQuest()
	if CDKDone or hasCDK() then CDKDone=true return end
	setStatus("Fazendo Quest CDK (Cursed Dual Katana)")
	pcall(function()
		local yama = hasItem("Yama")
		local tushita = hasItem("Tushita")
		if not yama then
			setStatus("CDK: Farmando Yama (mastery 350)")
			CommF_("StartQuest","CDKQuest","Yama")
		elseif not tushita then
			setStatus("CDK: Farmando Tushita (mastery 350)")
			CommF_("StartQuest","CDKQuest","Tushita")
		else
			setStatus("CDK: Obtendo CDK!")
			CommF_("GetCDK")
			task.wait(3)
			if hasCDK() then CDKDone = true end
		end
	end)
end

local function AutoRaidSea3()
	pcall(function()
		local frags = LP.Data and LP.Data.Fragments and LP.Data.Fragments.Value or 0
		if frags >= 5000 then return end
		setStatus("Fazendo Raid - Fragmentos: "..frags.."/5000")
		local hasChip = hasItem("Special Microchip")
		if not hasChip then
			local fruit = CommF_("getInventoryFruits")
			if fruit then
				for _,v in ipairs(fruit) do
					if v.Price and v.Price < 1000000 then
						CommF_("RaidsNpc","Select","Flame")
						break
					end
				end
			else
				CommF_("RaidsNpc","Select","Flame")
			end
		else
			CommF_("requestEntrance",Vector3.new(-5097.93,316.44,-3142.66))
			task.wait(0.5)
			TweenPlayer(CFrame.new(-5033.50,315.01,-2947.77))
			task.wait(0.5)
			pcall(function()
				fireclickdetector(workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
			end)
		end
	end)
end

local function CheckAndBuyBuso()
	pcall(function()
		local beli = getBeli()
		if beli >= 1000 then
			CommF_("BuyHaki","Buso")
		end
		if beli >= 2000 then
			CommF_("KenTalk","Buy")
			CommF_("BuyHaki","Geppo")
			CommF_("BuyHaki","Soru")
			HakiBought = true
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(30)
		CheckAndBuyBuso()
	end
end)

local function DoSkullGuitarQuest()
	if SkullGuitarDone then return end
	local ecto  = checkMaterial("Ectoplasm")
	local frag  = checkMaterial("Dark Fragment")
	local bones = checkMaterial("Bone")
	if ecto >= 250 and frag >= 1 and bones >= 500 then
		setStatus("Fazendo Quest Skull Guitar!")
		pcall(function() CommF_("StartQuest","SkullGuitarQuest",1) end)
		task.wait(5)
		SkullGuitarDone = true
	elseif frag < 1 then
		setStatus("Skull Guitar: Procurando Dark Beard para Dark Fragment")
		local db = GetEnemy("Darkbeard") or GetEnemy("Dark Beard")
		if db and IsAlive(db) then
			KillMob(db, true)
		else
			TweenPlayer(CFrame.new(3798.45,13.82,-3399.80))
		end
	elseif ecto < 250 then
		setStatus("Skull Guitar: Farmando Ectoplasm no Navio Assombrado ("..ecto.."/250)")
		local mob = GetEnemy("Zombie") or GetEnemy("Demonic Soul") or GetEnemy("Cursed Skeleton")
		if mob and IsAlive(mob) then
			TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
			AutoHaki(); Attack()
		else
			TweenPlayer(CFrame.new(3898,22,-4100))
		end
	elseif bones < 500 then
		setStatus("Skull Guitar: Farmando Bones no Castelo Assombrado ("..bones.."/500)")
		local mob = GetEnemy("Possessed Mummy") or GetEnemy("Reaper") or GetEnemy("Cursed Skeleton")
		if mob and IsAlive(mob) then
			TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
			AutoHaki(); Attack()
		else
			TweenPlayer(CFrame.new(5500,22,-3200))
		end
	end
end

local function DoTyrantOfSkies()
	if TyrantDone then return end
	setStatus("Quest Tirant of Skies - Farmando 400 NPCs Tiki")
	pcall(function()
		CommF_("SummonBoss","TyrantOfSkies")
		task.wait(2)
		local tyrant = GetEnemy("Tyrant") or GetEnemy("Tyranted") or GetEnemy("TyrantOfSkies")
		if tyrant and IsAlive(tyrant) then
			setStatus("Derrotando Tirant of Skies!")
			KillMob(tyrant, true)
			TyrantDone = true
		else
			local npcs = {"Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion","Serpent Hunter","Skull Slayer"}
			for _,nname in ipairs(npcs) do
				local mob = GetEnemy(nname)
				if mob and IsAlive(mob) then
					TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
					AutoHaki(); Attack()
					break
				end
			end
			TweenPlayer(CFrame.new(-16547,56,-172))
		end
	end)
end

local fightStyleProgress = 0
local function AdvanceFightStyle()
	if not getgenv().TRonConfig.FullFightStyles then return false end
	local lv = getLevel()
	local beli = getBeli()
	if World1 then
		if not hasItem("Black Leg") and not BlackLegBought then
			if beli >= 150000 then
				setStatus("Comprando Black Leg Style")
				TweenPlayer(CFrame.new(-2030,200,-2200))
				task.wait(1)
				BuyFightingStyle("Black Leg")
				BlackLegBought = true
				return true
			end
		end
	elseif World2 then
		if not hasItem("Electric") and not ElectricBought then
			if getMastery("Black Leg") >= 400 and beli >= 500000 then
				setStatus("Comprando Electric Style (Hot & Cold)")
				TweenPlayer(CFrame.new(-5478,16,-5247))
				task.wait(1)
				BuyFightingStyle("Electric")
				ElectricBought = true
				return true
			end
		elseif not hasItem("Sharkman Karate") and not SharkmanV1Bought then
			if getMastery("Electric") >= 400 then
				setStatus("Comprando Sharkman Karate V1")
				TweenPlayer(CFrame.new(1000,120,4000))
				task.wait(1)
				BuyFightingStyle("Sharkman Karate")
				SharkmanV1Bought = true
				return true
			end
		end
	elseif World3 then
		if not hasItem("Dragon Breath") then
			if getMastery("Sharkman Karate") >= 400 then
				setStatus("Comprando Dragon Breath")
				TweenPlayer(CFrame.new(4530,656,-131))
				task.wait(1)
				BuyFightingStyle("Dragon Breath")
				return true
			end
		elseif not hasItem("Death Step") then
			if getMastery("Dragon Breath") >= 400 then
				setStatus("Comprando Death Step")
				TweenPlayer(CFrame.new(-2370,74,3875))
				task.wait(1)
				BuyFightingStyle("Death Step")
				return true
			end
		elseif not hasItem("Sharkman Karate V2") and not hasItem("Fishman Karate V2") then
			if getMastery("Death Step") >= 400 then
				setStatus("Comprando Sharkman Karate V2")
				TweenPlayer(CFrame.new(1000,120,4000))
				task.wait(1)
				BuyFightingStyle("Sharkman Karate V2")
				return true
			end
		elseif not hasItem("Electric Claw") then
			if getMastery("Sharkman Karate V2") >= 400 then
				setStatus("Comprando Electric Claw")
				TweenPlayer(CFrame.new(216,126,-12599))
				task.wait(1)
				CommF_("BuyElectricClaw")
				return true
			end
		elseif not hasItem("Dragon Talon") and getMastery("Electric Claw") >= 400 then
			setStatus("Farmando Bones para Cursed Essence")
			local bones = checkMaterial("Bone")
			if bones >= 500 then
				CommF_("SpinCursedEssence")
			else
				local mob = GetEnemy("Possessed Mummy") or GetEnemy("Reaper")
				if mob and IsAlive(mob) then
					TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
					AutoHaki(); Attack()
				else
					TweenPlayer(CFrame.new(5500,22,-3200))
				end
			end
			return true
		elseif not hasGodHuman() and hasItem("Dragon Talon") and getMastery("Dragon Talon") >= 400 then
			setStatus("Obtendo God Human!")
			CommF_("BuyGodHuman")
			return true
		end
	end
	return false
end

local function FindLegendaryFruit()
	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local found = nil
	pcall(function()
		for _,v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Tool") and v.ToolTip == "Fruit" then
				for _,f in ipairs(legendaryFruits) do
					if v.Name:lower():find(f:lower()) then
						found = v
						return
					end
				end
			end
		end
	end)
	return found
end

local MainLoopActive = true

task.spawn(function()
	task.wait(6)
	CheckAndBuyBuso()
	while MainLoopActive do
		task.wait(0.3)
		pcall(function()
			if FruitGrabbing then return end
			local lv   = getLevel()
			local beli = getBeli()
			local frags = LP.Data and LP.Data.Fragments and LP.Data.Fragments.Value or 0

			if World1 then
				local db = GetEnemy("Darkbeard") or GetEnemy("Dark Beard")
				if db and IsAlive(db) then
					setStatus("⚔️ DARK BEARD SEA1! Derrotando!")
					KillMob(db, MainLoopActive)
					return
				end
				if lv <= 1 and beli < 150000 then
					FarmChestsSea1()
				elseif beli >= 150000 and not hasItem("Black Leg") then
					AdvanceFightStyle()
				elseif lv < 5 then
					setStatus("Farmando até Nível 5 | Lv:"..lv)
					CheckQuest()
					local mob = GetEnemy(Mon or "Bandit")
					if mob and IsAlive(mob) then
						TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
						AutoHaki(); Attack()
					elseif CFrameQuest then
						TweenPlayer(CFrameQuest)
					end
				elseif lv >= 5 and lv < 200 then
					if lv < 150 then
						setStatus("Farmando Sky Island (NPCs Lv150) | Lv:"..lv)
						local mob = GetEnemy("Sky Bandit") or GetEnemy("Dark Master") or GetEnemy("Galley Captain")
						if mob and IsAlive(mob) then
							TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
							AutoHaki(); Attack()
						else
							TweenPlayer(CFrame.new(-4953,296,-2899))
						end
					else
						AutoFarmLevel()
					end
				elseif lv >= 200 and not SaberDone then
					DoSaberQuest()
				elseif beli >= 750000 and not HakiBought then
					setStatus("Comprando Haki Observação")
					TweenPlayer(CFrame.new(-1785,25,-75))
					task.wait(1)
					CommF_("KenTalk","Buy")
					HakiBought = true
				else
					AdvanceFightStyle()
					if not FruitGrabbing then AutoFarmLevel() end
				end

			elseif World2 then
				local db = GetEnemy("Darkbeard") or GetEnemy("Dark Beard")
				local tk = GetEnemy("Tide Keeper") or GetEnemy("Tidekeeper")
				local ia = GetEnemy("Ice Admiral")
				if db and IsAlive(db) then
					setStatus("⚔️ DARK BEARD SPAWNOU! Prioridade!")
					KillMob(db, MainLoopActive)
					local frag = checkMaterial("Dark Fragment")
					if frag >= 1 then setStatus("Dark Fragment obtido!") end
					return
				elseif tk and IsAlive(tk) then
					setStatus("⚔️ TIDE KEEPER SPAWNOU! Derrotando!")
					KillMob(tk, MainLoopActive)
					task.wait(2)
					local key = hasItem("Key") or hasItem("Tidekeeper Key")
					if key then
						TweenPlayer(CFrame.new(1000,120,4000))
						task.wait(1)
						CommF_("StartQuest","SharkmanQuest","V2")
					end
					return
				elseif ia and IsAlive(ia) then
					setStatus("⚔️ ICE ADMIRAL SPAWNOU! Derrotando!")
					TweenPlayer(CFrame.new(1128,14,-3205))
					KillMob(ia, MainLoopActive)
					task.wait(2)
					local key = hasItem("Key") or hasItem("IceCastle Key")
					if key then
						CommF_("OpenPassage","Death Step")
						CommF_("OpenPassage","Rengoku")
					end
					return
				end
				if getgenv().TRonConfig.StayS2ForDarkFragment then
					local ecto  = checkMaterial("Ectoplasm")
					local frag  = checkMaterial("Dark Fragment")
					if frag < 1 then
						setStatus("Sea2: Procurando Darkbeard para Dark Fragment")
						TweenPlayer(CFrame.new(3798.45,13.82,-3399.80))
					elseif ecto < 250 then
						setStatus("Sea2: Farmando Ectoplasm no Navio Assombrado ("..ecto.."/250)")
						local mob = GetEnemy("Zombie") or GetEnemy("Demonic Soul")
						if mob and IsAlive(mob) then
							TweenPlayer(mob.HumanoidRootPart.CFrame * Pos)
							AutoHaki(); Attack()
						else
							TweenPlayer(CFrame.new(3898,22,-4100))
						end
					else
						setStatus("Dark Fragment e Ectoplasm obtidos! Pronto para Sea 3")
					end
					return
				end
				if lv >= 1500 then
					local legFruit = FindLegendaryFruit()
					if legFruit then
						setStatus("Pegando Fruta Lendária para missão Sea 3!")
						local h = legFruit:FindFirstChild("Handle")
						if h then
							TeleportInstant(h.Position + Vector3.new(0,3,0))
							local pp = legFruit:FindFirstChildWhichIsA("ProximityPrompt")
							if pp then pcall(function() fireproximityprompt(pp) end) end
							task.wait(1)
						end
					else
						setStatus("Lv1500+: Procurando Frutas Lendárias no mapa ou hopando")
						Hop()
					end
					return
				end
				AdvanceFightStyle()
				if not FruitGrabbing then AutoFarmLevel() end

			elseif World3 then
				local dough = GetEnemy("Dough King") or GetEnemy("Katakuri")
				local rip   = GetEnemy("Rip_Indra") or GetEnemy("Rip Indra")
				local cake  = GetEnemy("Cake Prince")
				local elite = GetEnemy("Elite Boss") or GetEnemy("Diablo") or GetEnemy("Urban") or GetEnemy("Deandre")
				if dough and IsAlive(dough) then
					setStatus("⚔️ DOUGH KING - PRIORIDADE MÁXIMA! Derrotando!")
					KillMob(dough, MainLoopActive)
					task.wait(2)
					if hasMirrorFractal() then setStatus("Mirror Fractal obtido!") end
					return
				elseif rip and IsAlive(rip) then
					if not TushitaDone then
						DoTushitaQuest()
					else
						setStatus("⚔️ RIP INDRA! Derrotando a qualquer custo!")
						KillMob(rip, MainLoopActive)
						task.wait(2)
						if hasValkiria() then setStatus("Valkiria do Rip Indra obtida!") end
					end
					return
				elseif cake and IsAlive(cake) then
					setStatus("⚔️ CAKE PRINCE SPAWNOU! Derrotando!")
					KillMob(cake, MainLoopActive)
					return
				elseif elite and IsAlive(elite) then
					setStatus("⚔️ ELITE BOSS! Derrotando!")
					CommF_("EliteHunter")
					TweenPlayer(elite.HumanoidRootPart.CFrame * Pos)
					KillMob(elite, MainLoopActive)
					return
				end

				if lv >= 2600 and not TyrantDone then
					DoTyrantOfSkies()
					return
				end

				if lv >= 2300 and not SkullGuitarDone then
					DoSkullGuitarQuest()
					return
				end

				if getgenv().TRonConfig.CDK and not CDKDone and not hasCDK() then
					if hasItem("Yama") and hasItem("Tushita") then
						DoCDKQuest()
						return
					end
				end

				if frags < 5000 then
					AutoRaidSea3()
					return
				end

				if getgenv().TRonConfig.FullFightStyles then
					local styled = AdvanceFightStyle()
					if styled then return end
				end

				AutoFarmLevel()
			end
		end)
	end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "TRonVoidKaitunGUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.DisplayOrder = 9999
pcall(function() SG.Parent = game.CoreGui end)
if not SG.Parent or not SG:IsDescendantOf(game) then
	SG.Parent = LP:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 600, 0, 700)
Main.Position = UDim2.new(0.5,-300,0.5,-350)
Main.BackgroundColor3 = Color3.fromRGB(0,0,0)
Main.BorderSizePixel = 0
Main.Parent = SG
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,16)
local MainStroke = Instance.new("UIStroke",Main)
MainStroke.Color = Color3.fromRGB(120,0,200)
MainStroke.Thickness = 2
local MainGrad = Instance.new("UIGradient",Main)
MainGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(5,0,18)),
	ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(12,0,28)),
})
MainGrad.Rotation = 135

local TopAccent = Instance.new("Frame",Main)
TopAccent.Size = UDim2.new(1,0,0,3)
TopAccent.BackgroundColor3 = Color3.fromRGB(120,0,200)
TopAccent.BorderSizePixel = 0
local TopAccGrad = Instance.new("UIGradient",TopAccent)
TopAccGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(0.4,Color3.fromRGB(120,0,200)),
	ColorSequenceKeypoint.new(0.6,Color3.fromRGB(200,80,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
})

local TopBar = Instance.new("Frame",Main)
TopBar.Size = UDim2.new(1,0,0,58)
TopBar.BackgroundColor3 = Color3.fromRGB(4,0,14)
TopBar.BorderSizePixel = 0
Instance.new("UICorner",TopBar).CornerRadius = UDim.new(0,14)
local TBStroke = Instance.new("UIStroke",TopBar)
TBStroke.Color = Color3.fromRGB(80,0,140)
TBStroke.Thickness = 1

local LogoImg = Instance.new("ImageLabel",TopBar)
LogoImg.Size = UDim2.new(0,44,0,44)
LogoImg.Position = UDim2.new(0,8,0.5,-22)
LogoImg.BackgroundTransparency = 1
LogoImg.Image = "rbxassetid://133779423735605"
LogoImg.ScaleType = Enum.ScaleType.Fit
Instance.new("UICorner",LogoImg).CornerRadius = UDim.new(1,0)
local LGStroke = Instance.new("UIStroke",LogoImg)
LGStroke.Color = Color3.fromRGB(150,0,255)
LGStroke.Thickness = 1.5

local TitleLbl = Instance.new("TextLabel",TopBar)
TitleLbl.Size = UDim2.new(1,-130,1,0)
TitleLbl.Position = UDim2.new(0,62,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "TRon Void Hub Kaitun [BETA]"
TitleLbl.TextColor3 = Color3.fromRGB(200,120,255)
TitleLbl.TextSize = 17
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.RichText = true

local SubTitleLbl = Instance.new("TextLabel",TopBar)
SubTitleLbl.Size = UDim2.new(1,-130,0,16)
SubTitleLbl.Position = UDim2.new(0,62,1,-18)
SubTitleLbl.BackgroundTransparency = 1
SubTitleLbl.Text = "Blox Fruits | Full Auto | Kaitun Support"
SubTitleLbl.TextColor3 = Color3.fromRGB(120,80,180)
SubTitleLbl.TextSize = 11
SubTitleLbl.Font = Enum.Font.Gotham
SubTitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton",TopBar)
CloseBtn.Size = UDim2.new(0,34,0,34)
CloseBtn.Position = UDim2.new(1,-42,0.5,-17)
CloseBtn.BackgroundColor3 = Color3.fromRGB(100,0,160)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 15
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,8)
local CBStroke = Instance.new("UIStroke",CloseBtn)
CBStroke.Color = Color3.fromRGB(180,0,255)
CBStroke.Thickness = 1
CloseBtn.MouseButton1Click:Connect(function()
	MainLoopActive = false
	SG:Destroy()
end)
CloseBtn.MouseEnter:Connect(function()
	TweenSvc:Create(CloseBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(180,0,60)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenSvc:Create(CloseBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,0,160)}):Play()
end)

local Scroll = Instance.new("ScrollingFrame",Main)
Scroll.Size = UDim2.new(1,-6,1,-66)
Scroll.Position = UDim2.new(0,3,0,63)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(120,0,200)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.BorderSizePixel = 0
local ListLayout = Instance.new("UIListLayout",Scroll)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0,7)
local UIPad = Instance.new("UIPadding",Scroll)
UIPad.PaddingLeft = UDim.new(0,8)
UIPad.PaddingRight = UDim.new(0,8)
UIPad.PaddingTop = UDim.new(0,8)
UIPad.PaddingBottom = UDim.new(0,8)

local function mkSection(txt)
	local f = Instance.new("Frame",Scroll)
	f.Size = UDim2.new(1,0,0,28)
	f.BackgroundColor3 = Color3.fromRGB(35,0,65)
	f.BorderSizePixel = 0
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
	local s = Instance.new("UIStroke",f)
	s.Color = Color3.fromRGB(100,0,180)
	s.Thickness = 1
	local l = Instance.new("TextLabel",f)
	l.Size = UDim2.new(1,-12,1,0)
	l.Position = UDim2.new(0,10,0,0)
	l.BackgroundTransparency = 1
	l.Text = "▸  "..txt
	l.TextColor3 = Color3.fromRGB(210,140,255)
	l.TextSize = 13
	l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	return f
end

local function mkCard(h)
	local f = Instance.new("Frame",Scroll)
	f.Size = UDim2.new(1,0,0,h)
	f.BackgroundColor3 = Color3.fromRGB(6,0,16)
	f.BorderSizePixel = 0
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
	local s = Instance.new("UIStroke",f)
	s.Color = Color3.fromRGB(50,0,90)
	s.Thickness = 1
	return f
end

local function mkLabel(parent, txt, size, color, x, y, w, h)
	local l = Instance.new("TextLabel",parent)
	l.Size = UDim2.new(w or 1,-16,0,h or 20)
	l.Position = UDim2.new(x or 0,8,y or 0,4)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = color or Color3.fromRGB(200,200,200)
	l.TextSize = size or 13
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	return l
end

local function mkBtn(parent, txt, x, y, w, h, color)
	local b = Instance.new("TextButton",parent)
	b.Size = UDim2.new(w or 0,160,0,h or 28)
	b.Position = UDim2.new(x or 0,8,y or 0,6)
	b.BackgroundColor3 = color or Color3.fromRGB(70,0,120)
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.BorderSizePixel = 0
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
	local s = Instance.new("UIStroke",b)
	s.Color = Color3.fromRGB(160,0,255)
	s.Thickness = 1
	b.MouseEnter:Connect(function()
		TweenSvc:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(110,0,180)}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenSvc:Create(b,TweenInfo.new(0.12),{BackgroundColor3=color or Color3.fromRGB(70,0,120)}):Play()
	end)
	return b
end

mkSection("Localização Detectada")
local seaCard = mkCard(44)
local seaName = World1 and "🌊 SEA 1 — First Sea" or World2 and "🌊 SEA 2 — Second Sea" or World3 and "🌊 SEA 3 — Third Sea" or "⚠️ Sea Desconhecido (PlaceId: "..PID..")"
local seaClr  = World1 and Color3.fromRGB(80,200,255) or World2 and Color3.fromRGB(80,255,160) or World3 and Color3.fromRGB(255,180,80)
mkLabel(seaCard, seaName, 14, seaClr or Color3.fromRGB(200,200,200), 0, 0, 1, 36)

mkSection("⚡ Status Atual")
local statusCard = mkCard(56)
local statusLabel = Instance.new("TextLabel", statusCard)
statusLabel.Size = UDim2.new(1,-16,1,-8)
statusLabel.Position = UDim2.new(0,8,0,4)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚡ Inicializando..."
statusLabel.TextColor3 = Color3.fromRGB(100,255,190)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextWrapped = true
getgenv().TRonStatusLabel = statusLabel

mkSection("Inventário — Itens Especiais")
local invCard = mkCard(108)

local itemChecks = {
	{name="God Human",    fn=hasGodHuman,      x=0,    y=0,  tx=0.5, ty=0},
	{name="CDK",          fn=hasCDK,           x=0.5,  y=0,  tx=0,   ty=0},
	{name="Valkiria Rip", fn=hasValkiria,      x=0,    y=2,  tx=0.5, ty=2},
	{name="Mirror Fractal",fn=hasMirrorFractal,x=0.5,  y=2,  tx=0,   ty=2},
}

local itemLabels = {}
for _, ic in ipairs(itemChecks) do
	local lbl = Instance.new("TextLabel",invCard)
	lbl.Size = UDim2.new(0.5,-10,0,24)
	lbl.Position = UDim2.new(ic.x, ic.x==0 and 8 or 2, 0, ic.y*26+8)
	lbl.BackgroundColor3 = Color3.fromRGB(10,0,22)
	lbl.BackgroundTransparency = 0
	lbl.BorderSizePixel = 0
	Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,6)
	local ss = Instance.new("UIStroke",lbl)
	ss.Color = Color3.fromRGB(60,0,100)
	ss.Thickness = 1
	local has = ic.fn()
	lbl.Text = (has and "✅ " or "❌ ")..ic.name
	lbl.TextColor3 = has and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80)
	lbl.TextSize = 12
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	table.insert(itemLabels, {lbl=lbl, fn=ic.fn, name=ic.name})
end

task.spawn(function()
	while true do
		task.wait(3)
		for _, ic in ipairs(itemLabels) do
			pcall(function()
				local has = ic.fn()
				ic.lbl.Text = (has and "✅ " or "❌ ")..ic.name
				ic.lbl.TextColor3 = has and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80)
			end)
		end
	end
end)

mkSection("Detector de Bosses Importantes")
local bossCard = mkCard(136)
local bossInfo = {
	{name="Dark Beard",   search="darkbeard",    pri="1",  clr=Color3.fromRGB(255,100,100)},
	{name="Tide Keeper",  search="tide keeper",  pri="2",  clr=Color3.fromRGB(100,200,255)},
	{name="Ice Admiral",  search="ice admiral",  pri="3",  clr=Color3.fromRGB(180,220,255)},
	{name="Dough King",   search="dough king",   pri="1",  clr=Color3.fromRGB(255,210,80)},
	{name="Rip Indra",    search="rip_indra",    pri="2",  clr=Color3.fromRGB(200,120,255)},
	{name="Cake Prince",  search="cake prince",  pri="3",  clr=Color3.fromRGB(255,160,200)},
}
local bossLabels = {}
for i, bi in ipairs(bossInfo) do
	local col = (i-1) % 2
	local row = math.floor((i-1) / 2)
	local bl = Instance.new("TextLabel",bossCard)
	bl.Size = UDim2.new(0.5,-10,0,22)
	bl.Position = UDim2.new(col*0.5, col==0 and 8 or 2, 0, row*28+8)
	bl.BackgroundColor3 = Color3.fromRGB(8,0,20)
	bl.BackgroundTransparency = 0
	bl.BorderSizePixel = 0
	Instance.new("UICorner",bl).CornerRadius = UDim.new(0,6)
	local bs = Instance.new("UIStroke",bl)
	bs.Color = Color3.fromRGB(50,0,90)
	bs.Thickness = 1
	bl.Text = "❌ "..bi.name
	bl.TextColor3 = Color3.fromRGB(120,120,120)
	bl.TextSize = 11
	bl.Font = Enum.Font.Gotham
	bl.TextXAlignment = Enum.TextXAlignment.Center
	bl.TextYAlignment = Enum.TextYAlignment.Center
	bossLabels[bi.search] = {lbl=bl, info=bi}
end

task.spawn(function()
	while true do
		task.wait(2)
		for search, data in pairs(bossLabels) do
			pcall(function()
				local found = GetEnemy(search) ~= nil
				data.lbl.Text = (found and "✅ " or "❌ ")..data.info.name
				data.lbl.TextColor3 = found and data.info.clr or Color3.fromRGB(100,100,100)
				if found then
					TweenSvc:Create(data.lbl,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(30,0,50)}):Play()
				else
					TweenSvc:Create(data.lbl,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(8,0,20)}):Play()
				end
			end)
		end
	end
end)

mkSection("Materiais Skull Guitar (Sea 2→3)")
local matCard = mkCard(80)
local matEctoLbl = mkLabel(matCard,"⚗️ Ectoplasm: ···/250",12,Color3.fromRGB(150,255,200),0,0,0.5,22)
local matFragLbl = mkLabel(matCard,"💎 Dark Fragment: ···/1",12,Color3.fromRGB(255,180,80),0.5,0,0.5,22)
local matBoneLbl = mkLabel(matCard,"🦴 Bone: ···/500",12,Color3.fromRGB(220,220,180),0,2,0.5,22)
local matFlagLbl = mkLabel(matCard,"🎸 Skull Guitar: Pendente",12,Color3.fromRGB(200,100,255),0.5,2,0.5,22)
task.spawn(function()
	while true do
		task.wait(5)
		pcall(function()
			local e = checkMaterial("Ectoplasm")
			local f = checkMaterial("Dark Fragment")
			local b = checkMaterial("Bone")
			matEctoLbl.Text = "⚗️ Ectoplasm: "..e.."/250"
			matEctoLbl.TextColor3 = e>=250 and Color3.fromRGB(80,255,120) or Color3.fromRGB(150,255,200)
			matFragLbl.Text = "💎 Dark Fragment: "..f.."/1"
			matFragLbl.TextColor3 = f>=1 and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,180,80)
			matBoneLbl.Text = "🦴 Bone: "..b.."/500"
			matBoneLbl.TextColor3 = b>=500 and Color3.fromRGB(80,255,120) or Color3.fromRGB(220,220,180)
			matFlagLbl.Text = SkullGuitarDone and "🎸 Skull Guitar: ✅" or "🎸 Skull Guitar: Pendente"
			matFlagLbl.TextColor3 = SkullGuitarDone and Color3.fromRGB(80,255,120) or Color3.fromRGB(200,100,255)
		end)
	end
end)

mkSection("Haki (Auto-Ativo)")
local hakiCard = mkCard(44)
mkLabel(hakiCard,"🔱 Armamento (Buso): AUTO ATIVO — Tecla J",12,Color3.fromRGB(255,200,80),0,0,1,20)
mkLabel(hakiCard,"👁️ Observação (Ken): AUTO ATIVO — Tecla L",12,Color3.fromRGB(80,200,255),0,1.2,1,20)

mkSection("Estilos de Luta — Progresso")
local styleCard = mkCard(108)
local styleLabels = {}
local styleList = {
	"Black Leg","Electric","Sharkman Karate",
	"Dragon Breath","Death Step","Electric Claw","God Human",
}
for i, sn in ipairs(styleList) do
	local col = (i-1) % 2
	local row = math.floor((i-1) / 2)
	local sl = Instance.new("TextLabel",styleCard)
	sl.Size = UDim2.new(0.5,-10,0,22)
	sl.Position = UDim2.new(col*0.5, col==0 and 8 or 2, 0, row*26+8)
	sl.BackgroundColor3 = Color3.fromRGB(8,0,20)
	sl.BorderSizePixel = 0
	Instance.new("UICorner",sl).CornerRadius = UDim.new(0,6)
	local ss2 = Instance.new("UIStroke",sl)
	ss2.Color = Color3.fromRGB(50,0,90)
	ss2.Thickness = 1
	local has = hasItem(sn)
	sl.Text = (has and "✅ " or "○ ")..sn
	sl.TextColor3 = has and Color3.fromRGB(80,255,120) or Color3.fromRGB(150,150,150)
	sl.TextSize = 11
	sl.Font = Enum.Font.Gotham
	sl.TextXAlignment = Enum.TextXAlignment.Center
	sl.TextYAlignment = Enum.TextYAlignment.Center
	table.insert(styleLabels, {lbl=sl, name=sn})
end
task.spawn(function()
	while true do
		task.wait(4)
		for _,sd in ipairs(styleLabels) do
			pcall(function()
				local h = hasItem(sd.name)
				sd.lbl.Text = (h and "✅ " or "○ ")..sd.name
				sd.lbl.TextColor3 = h and Color3.fromRGB(80,255,120) or Color3.fromRGB(150,150,150)
			end)
		end
	end
end)

mkSection("Comunidade TRon Void")
local discCard = mkCard(50)
mkLabel(discCard,"💬 TRON VOID COMMUNITY — discord.gg/f4K5sDwKkn",12,Color3.fromRGB(130,140,255),0,0,0.65,42)
local discBtn = mkBtn(discCard,"Join Discord",0.66,0,0,34,Color3.fromRGB(88,101,242))
discBtn.Size = UDim2.new(0,130,0,34)
discBtn.Position = UDim2.new(1,-138,0.5,-17)
discBtn.MouseButton1Click:Connect(function()
	pcall(function() setclipboard("https://discord.gg/f4K5sDwKkn") end)
	local orig = discBtn.Text
	discBtn.Text = "✅ Copiado!"
	task.delay(2, function() discBtn.Text = orig end)
end)

mkSection("Getgenv Config — Edite no Loadstring")
local genvCard = mkCard(160)
local genvText = [[getgenv().TRonConfig = {
  Team = "Pirate",            -- "Pirate" ou "Marine"
  FullFightStyles = true,     -- Evoluir estilos até God Human
  CDK = true,                 -- Fazer quest CDK
  StayS2ForDarkFragment = false,  -- Ficar S2 para Dark Fragment
  FixLag = false,             -- Remover efeitos/lag
  TweenSpeed = 0.35,          -- 0.30 a 0.35
  EatFruit = true,            -- Pegar frutas spawnadas
  FruitToEat = "",            -- Nome da fruta para comer
}]]
mkLabel(genvCard, genvText, 10, Color3.fromRGB(180,180,255), 0, 0, 1, 150)

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)
TopBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
	   input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStart
		Main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)

local HideBtn = Instance.new("ImageButton")
HideBtn.Size = UDim2.new(0,56,0,56)
HideBtn.Position = UDim2.new(0,15,1,-71)
HideBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
HideBtn.Image = "rbxassetid://133779423735605"
HideBtn.ScaleType = Enum.ScaleType.Fit
HideBtn.ClipsDescendants = true
HideBtn.Parent = SG
Instance.new("UICorner",HideBtn).CornerRadius = UDim.new(1,0)
local HBS = Instance.new("UIStroke",HideBtn)
HBS.Color = Color3.fromRGB(120,0,200)
HBS.Thickness = 2

HideBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

local hdrag, hdragStart, hstartPos
HideBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		hdrag = true
		hdragStart = input.Position
		hstartPos = HideBtn.Position
	end
end)
HideBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		hdrag = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if hdrag and (input.UserInputType == Enum.UserInputType.MouseMovement or
	   input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - hdragStart
		HideBtn.Position = UDim2.new(
			hstartPos.X.Scale, hstartPos.X.Offset + d.X,
			hstartPos.Y.Scale, hstartPos.Y.Offset + d.Y
		)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		pcall(function()
			local ang = (tick() * 80) % 360
			MainStroke.Color = Color3.fromHSV(ang/360, 1, 0.9)
			HBS.Color = Color3.fromHSV(ang/360, 1, 0.9)
		end)
	end
end)

setStatus("TRon Void Hub Kaitun [BETA] — Pronto! "..LP.Name)
getgenv().ReadyForGuiLoaded = true
