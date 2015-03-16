--[[ 
Complete Troops Transport Script (CTTS) including logistics v1.04
Based on original HueyDrop script idea by Deck and modified by Angel(Geloxo)

Modified again by Ciribob 11.03.2015 

BUG FIX:

- Fixed nil leader bug in FindNearestGroup & FindNearestLogGroup
	- GetUnits returned an empty table so indexing the first unit crashed the script
		- Rewritten for safer logic against insane ED bugs
- Better FindNearestEnemy Logic
- Fixed LogisticsSuppliers loading / unloading


TROOPS TRANSPORTATION:

- Script is compatible with both air and ground transports controlled by players or AI
- Transports will drop troops types based on the coalition they belong to and the number of previously loaded troops
- Typically the troops are loaded inside a pickup trigger and dropped d their colours configured
- To enable a UNIT to use the transport script set its UNITinside a drop trigger, but usage of triggers is not mandatory
- Pickup and drop smoke markers can be enabled, disabled anNAME in the list of transports names or use any of the predefined ones in your mission
- To manually define a GROUP as extractable add its GROUPNAME to the list of extractable groups or use any of the predefined ones in your mission
- Dropped troops will stay close to drop point or go to closest enemy position (default 2000m)

- Human players need to use F10 radio action to load/unload troops or to check the cargo status
- Players can only load troops inside the pickup trigger or alternatively load any pre-defined extractable group or spawned group everywhere. In both cases you can drop them everywhere
- Troops can be extracted by players if transport is near their current position (default 50m)
- Troops can be returned to pick zones by players (acting as Medevacs, for instance)

- AI transports will automatically load troops only when inside the pickup triggers. AI transports won´t extract any unit automatically (to avoid interferences with human players)
- AI transports will automatically unload troops only if they are close enough to drop triggers center (default 500m for ground units and 10km for air units). This allows AI ground units to enter triggers without dropping
- Ground Commander take control of AI transports via Combined Arms module and manually load and unload troops with them (this will disable the auto load/unload feature for the AI transport) 
- Ground Commander can move any of the deployed troops manually in the field

LOGISTICS:

- Human players can load equipment when close to any logistics supplier group from their coalition and deploy it everywhere
- Any human controlled transport enabled for troops transportation will be automatically enabled for logistics as well (AI transports do not support logistics, cause it´s useless in this case)
- To manually define a GROUP as logistics supplier add its GROUPNAME to the list of logistics groups or use any of the predefined ones in your mission
- An extractable group of troops can be used as logistics as well (by setting the same name in both lists)
- Deployed logistic items can be transported by any coalition (you can steal the enemy ones)
- There´s no need to define logistic items in mission. You need to spawn them with the standalone function (this is used to keep consistency between cargo 3D models)


IMPORTANT NOTES:

1. It´s NOT MANDATORY to place in mission any pickup or drop triggers as you can always use extractable units instead or pre-load transports with troops manually. 
   ONLY if you are using AI transports you need at least ONE DROP trigger to perform the automatic unload.
   You can use any of the predefined names for triggers or use your own ones.

2. Predefined extractable groups can be used to trigger actions during mission as their groupnames will be kept during the mission when transported by human players

3. To pre-load units with troops during mission call at least 10s after mission started via DoScript action the following standalone function:
			LoadTransport("unitName", number)
	Where:
	- "unitname" = the name of the transport
	- number = optionally the number of troops. 
	
	Examples:
  	a. LoadTransport("helicargo1") This will load with default number of troops the unit "helicargo1"
	b. LoadTransport("helicargo1",4) This will load it with 4 troops

	As an alternative to this you can always use a AI transport that enters a pickzone to load them automatically

4. You can generate groups of extractable units during mission, that will search for enemy as well, using the following standalone function:
			CallSpawn("groupside", number, "triggerName", radius)
	Where:
	- "groupside" = "ins" for insurgents, "red" for Russia and "blue" for USA
	- number = number of groups to spawn
	- "triggerName" = trigger to use as spawn
	- radius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)

	Example: CallSpawn("red", 2, "spawn1", 1000) This will spawn 2 groups of russians at trigger "spawn1" and they will search for enemy or move randomly withing 1000m
	
5. You can check the amount of extracted units inside a particular trigger using the following standalone function:
			CountExtracted("triggerName", flagBlue, flagRed)

	Where:
	"triggerName" = name of trigger to supervise
	flagBlue = userflag to count the number of blue units inside trigger
	flagRed = userflag to count the number of red units inside trigger

	Example: CountExtracted("trigger1", 200, 201) this will count the units inside "trigger1" and store the values in the flags 200 and 201 (which can be accessed during mission)
	
6. You can generate logistic items on the field during mission using the following standalone function:
			CallSpawnLogistics("groupside", number, "triggerName", radius)

	Where:
	"groupside" = "ins" for insurgents, "red" for Russia "blue" for USA
	number = number of items to spawn
	"triggerName" = trigger name in mission editor between commas
	radius = separation between items

	Example: CallSpawnLogistics("blue", 2, "spawn1", 30) this example will spawn 2 cargo items for USA at trigger "spawn1" separated 30m	
	
7. You can check the amount of logistics dropped items inside a particular trigger using the following standalone function:
			CountLogistics("triggerName",flagLog)

	Where:

	"triggerName" = name of trigger to supervise
	flagLog = userflag to count the number of logistic items inside trigger

	Example: CountLogistics("trigger1",300) this will count the items inside "trigger1" and store the values in the flag 300 (which can be accessed by mission)

8. Always RELOAD SCRIPT in mission after any changes on its configuration

--]]


-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************

-- set variables to false to disable all smoke markers types quickly
-- set variables to false to disable all smoke markers types quickly
smokepick = true
smokedrop = false

-- ***************** Pickup and dropoff zones *****************

-- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",

-- Use any of the predefined names or set your own ones

PickZones = {

"pickzone1", "blue",
"pickzone2", "blue",
"pickzone3", "none",
"pickzone4", "none",
"pickzone5", "none",
"pickzone6", "none",
"pickzone7", "none",
"pickzone8", "none",
"pickzone9", "none",
"pickzone10", "none",

}

DropZones = {

"dropzone1", "orange",
"dropzone2", "green",
"dropzone3", "none",
"dropzone4", "none",
"dropzone5", "red",
"dropzone6", "red",
"dropzone7", "red",
"dropzone8", "red",
"dropzone9", "red",
"dropzone10", "red",

}

-- ******************** Transports names **********************

-- Use any of the predefined names or set your own ones

TransportsNames = {

--"MEDEVAC #1",
--"MEDEVAC #2",
--"MEDEVAC #3",
--"MEDEVAC #4",
"helicargo1",
"helicargo2",
"helicargo3",
"helicargo4",
"helicargo5",
"helicargo6",
"helicargo7",
"helicargo8",
"helicargo9",
"helicargo10",

"helicargo11",
"helicargo12",
"helicargo13",
"helicargo14",
"helicargo15",
"helicargo16",
"helicargo17",
"helicargo18",
"helicargo19",
"helicargo20",

"helicargo21",
"helicargo22",
"helicargo23",
"helicargo24",
"helicargo25",

-- *** AI transports names (different names only to ease identification in mission) ***

-- Use any of the predefined names or set your own ones

"transport1",
"transport2",
"transport3",
"transport4",
"transport5",
"transport6",
"transport7",
"transport8",
"transport9",
"transport10",

"transport11",
"transport12",
"transport13",
"transport14",
"transport15",
"transport16",
"transport17",
"transport18",
"transport19",
"transport20",

"transport21",
"transport22",
"transport23",
"transport24",
"transport25",	

}

-- *************** Optional Extractable GROUPS *****************

-- Use any of the predefined names or set your own ones

ExtGroups = {

"extract1",
"extract2",
"extract3",
"extract4",
"extract5",
"extract6",
"extract7",
"extract8",
"extract9",
"extract10",

"extract11",
"extract12",
"extract13",
"extract14",
"extract15",
"extract16",
"extract17",
"extract18",
"extract19",
"extract20",

"extract21",
"extract22",
"extract23",
"extract24",
"extract25",

}

-- ************** Optional Logistics GROUPS ******************

-- Use any of the predefined names or set your own ones

LogisticsSuppliers = {

"logistic1",
"logistic2",
"logistic3",
"logistic4",
"logistic5",
"logistic6",
"logistic7",
"logistic8",
"logistic9",
"logistic10",

}

-- ******************  GENERAL SCRIPT CONFIG ********************

maxDistExt = 150 	-- max distance from vehicle to troops to allow a group extraction
maxDistLog = 50 	-- max distance from vehicle to logistics to allow a loading operation
maxDistEnemy = 2500 -- max distance for troops to search for enemy
maxDistDrop = 500 	-- max distance for troops to move from drop point if no enemy is nearby
minDistAir = 10000  -- min distance needed to trigger auto unload for AI air units
minDistGround = 500 -- min distance needed to trigger auto unload for AI ground units
defCargoNum = 10 	-- default number of troops to load on a transport
defCountSpawn = 10	-- default number of troops used on a standalone spawned group

logisticItemModel = "FARP Tent" -- model used to spawn a logistic item

cargoSpawn = true -- adds special spawn cargo crate option to the menu
cargoCrateMassKG = 450 -- mass of the cargo crate in Kilograms

radioTime = 30	-- time duration for AM/FM messages
radioLoop = 60	-- time for re-setting radio beacons for JIP

-- ***************************************************************
-- ****************  DON´T EDIT BELOW THIS ***********************
-- ***************************************************************





-----------------------------------------------------------------
------------------- SETUP BASED ON CONFIGURATION ----------------
-----------------------------------------------------------------

j = nil
k = nil
PickupZones = {}
DropoffZones = {}

DroppedGroupBlue = {}
DroppedGroupRed = {}
groupCounter = 10000
unitCounter = 10000
logcargoCounter = 10000
logcargoCrateCounter = 20000

LogisticBlue = {}
LogisticRed = {}
DroppedObjects = {}

RadioCommandTable = {}
local radiotext1 = "Load/Unload Troops"
local radiotext2 = "Use Cargo Bay"
local radiotext3 = "Check Cargo Status"
local radiotext4 = "Spawn Cargo"

UnitLoadTable = {}
UnitAutoAction = {}
UnitCargoCount = {}
UnitCargoName = {}
UnitCargoItem = {}

UnitCargoBayTable = {}

-- Compose trigger matrix

for i=1,(#PickZones/2) do
	j = 2 * i
	k = j - 1

	PickupZones[i] = {}
	PickupZones[i].ZoneName = {}
	PickupZones[i].SmokeColor = {}
	PickupZones[i].ZoneName = PickZones[k]
		
	if PickZones[j] == "green" then
		PickupZones[i].SmokeColor = trigger.smokeColor.Green
	elseif PickZones[j] == "red" then
		PickupZones[i].SmokeColor = trigger.smokeColor.Red
	elseif PickZones[j] == "white" then
		PickupZones[i].SmokeColor = trigger.smokeColor.White
	elseif PickZones[j] == "orange" then
		PickupZones[i].SmokeColor = trigger.smokeColor.Orange
	elseif PickZones[j] == "blue" then
		PickupZones[i].SmokeColor = trigger.smokeColor.Blue		
	else	
		PickupZones[i].SmokeColor = nil
	end	
end

for i=1,(#DropZones/2) do
	j = 2 * i
	k = j - 1

	DropoffZones[i] = {}
	DropoffZones[i].ZoneName = {}
	DropoffZones[i].SmokeColor = {}
	DropoffZones[i].ZoneName = DropZones[k]
	
	if DropZones[j] == "green" then
		DropoffZones[i].SmokeColor = trigger.smokeColor.Green
	elseif DropZones[j] == "red" then
		DropoffZones[i].SmokeColor = trigger.smokeColor.Red
	elseif DropZones[j] == "white" then
		DropoffZones[i].SmokeColor = trigger.smokeColor.White
	elseif DropZones[j] == "orange" then
		DropoffZones[i].SmokeColor = trigger.smokeColor.Orange
	elseif DropZones[j] == "blue" then
		DropoffZones[i].SmokeColor = trigger.smokeColor.Blue		
	else	
		DropoffZones[i].SmokeColor = nil
	end
end

-- Compose extractable groups list

function AddExtGroups()
	local groupside = nil
	local group = nil
	for i=1,#ExtGroups do
		group = Group.getByName(ExtGroups[i])
		if group ~= nil then
			groupside = group:getCoalition()
			if groupside == 2 then -- adds new group to the list of dropped ones
				if CheckInTable (DroppedGroupBlue, ExtGroups[i]) == false then
					table.insert(DroppedGroupBlue, ExtGroups[i])
				end
			elseif groupside == 1 then
				if CheckInTable (DroppedGroupRed, ExtGroups[i]) == false then
					table.insert(DroppedGroupRed, ExtGroups[i])
				end
			end
		end
	end
 		
    return
end

-- Compose logistics list

function AddLogGroups()
	local groupside = nil
	local group = nil
	for i=1,#LogisticsSuppliers do
		group = Group.getByName(LogisticsSuppliers[i])
		if group ~= nil then
			groupside = group:getCoalition()
			if groupside == 2 then -- adds new group to the list of logistics
				if CheckInTable (LogisticBlue, LogisticsSuppliers[i]) == false then
					table.insert(LogisticBlue, LogisticsSuppliers[i])
				end
			elseif groupside == 1 then
				if CheckInTable (LogisticRed, LogisticsSuppliers[i]) == false then
					table.insert(LogisticRed, LogisticsSuppliers[i])
				end
			end
		end
	end
 		
    return
end

-----------------------------------------------------------------
------------------------ SMOKE MARKERS --------------------------
-----------------------------------------------------------------

-- Trigger smoke markers

function SpawnSmoke(smokeX, smokeY, SmokeColor)
    local pos2 = { x = smokeX, y = smokeY }
    local alt = land.getHeight(pos2)
    local pos3 = {x=pos2.x, y=alt, z=pos2.y}
	if (SmokeColor ~= nil) then
		trigger.action.smoke(pos3, SmokeColor)
	end
end

function SmokeTimer(arg, time)
	if smokepick == true then
		for i=1,#PickupZones do
			local zone = trigger.misc.getZone(PickupZones[i].ZoneName)
			if zone ~= nil then 
				SpawnSmoke(zone.point.x, zone.point.z, PickupZones[i].SmokeColor)
			end
		end
	end
    
	if smokedrop == true then
		for i=1,#DropoffZones do
			local zone = trigger.misc.getZone(DropoffZones[i].ZoneName)
			if zone ~= nil then
				SpawnSmoke(zone.point.x, zone.point.z, DropoffZones[i].SmokeColor)
			end
		end
    end
	
    return time + 270
end

-----------------------------------------------------------------
------------------------ DROP FUNCTION --------------------------
-----------------------------------------------------------------

-- Spawn a group from vehicle

function DropoffGroupDirect(count, radius, xCenter, yCenter, xDest, yDest, groupside, loadedGroup)
	local name = "GroupName" .. groupCounter
	
	if loadedGroup ~= nil then	-- check if spawn group was an extractable group
		for i=1,#ExtGroups do
			if ExtGroups[i] == loadedGroup then
				name = loadedGroup
			end
		end
	end
	
    local group = {
        ["visible"] = false,
        ["taskSelected"] = true,
        ["groupId"] = groupCounter,
        ["hidden"] = false,
        ["units"] = {},
        ["y"] = yCenter,
        ["x"] = xCenter,
        ["name"] = name,
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
        ["route"] = {
            ["points"] = 
            {
                [1] = 
                {
                    ["alt"] = 41,
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["alt_type"] = "BARO",
                    ["formation_template"] = "",
                    ["y"] = yCenter,
                    ["x"] = xCenter,
                    ["ETA_locked"] = true,
                    ["speed"] = 5.5555555555556,
                    ["action"] = "Diamond",
                    ["task"] = 
                    {
                        ["id"] = "ComboTask",
                        ["params"] = 
                        {
                            ["tasks"] = 
                            {
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                    ["speed_locked"] = false,
                }, -- end of [1]
                [2] = 
                {
                    ["alt"] = 54,
                    ["type"] = "Turning Point",
                    ["ETA"] = 52.09716824195,
                    ["alt_type"] = "BARO",
                    ["formation_template"] = "",
                    ["y"] = yDest,
                    ["x"] = xDest,
                    ["ETA_locked"] = false,
                    ["speed"] = 5.5555555555556,
                    ["action"] = "Diamond",
                    ["task"] = 
                    {
                        ["id"] = "ComboTask",
                        ["params"] = 
                        {
                            ["tasks"] = 
                            {
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                    ["speed_locked"] = false,
                }, -- end of [2]
            }, -- end of ["points"]
        }, -- end of ["route"]
    }
	
	if groupside == 2 then -- adds new group to the list of dropped ones
		if CheckInTable (DroppedGroupBlue, name) == false then
			table.insert(DroppedGroupBlue, name)
		end
	elseif groupside == 1 then
		if CheckInTable (DroppedGroupRed, name) == false then
			table.insert(DroppedGroupRed, name)
		end
	end
	
    groupCounter = groupCounter + 1
    
    for i = 1,count do  
        local angle = math.pi * 2 * (i-1) / count
        local xofs = math.cos(angle) * radius
        local yofs = math.sin(angle) * radius
		
		local unitType = "Soldier AK"
				
		if groupside == 2 then 
			unitType = "Soldier M4"
			if i <= 2 then
				unitType = "Soldier M249"
			end
		elseif groupside == 1 then
			unitType = "Infantry AK"
			if i <= 4 then
				unitType = "Paratrooper RPG-16"
			end
			if i <= 2 then
				unitType = "Paratrooper AKS-74"
			end
		end
		
		group.units[i] = NewSoldierUnit(xCenter + xofs, yCenter + yofs, angle, unitType)
        
    end
	
	ConfigGroup (group, groupside)		    
    return group
end

-----------------------------------------------------------------

-- Add soldier to group

function NewSoldierUnit(x, y, heading, unitType)
	local name = "Unitname" .. unitCounter
    local unit = {
        ["y"] = y,
        ["type"] = unitType,
        ["name"] = name,
        ["unitId"] = unitCounter,
        ["heading"] = heading,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = x,
    }
    
    unitCounter = unitCounter + 1    
    return unit    
end

-----------------------------------------------------------------

-- Add structure for logistics

function NewStructure(angle, radius, xCenter, yCenter, groupside, loadedItem)
	local name = "LogCargoItem" .. logcargoCounter
	
	local objtype = logisticItemModel
	
	if loadedItem ~= nil then	-- check if spawn item was an existing one
		for i=1,#DroppedObjects do
			if DroppedObjects[i] == loadedItem then
				name = loadedItem
			end
		end
	end

    local xofs = math.cos(angle) * radius
    local yofs = math.sin(angle) * radius

    local static = nil

	static = {
	        ["type"] = objtype,
	        ["unitId"] = logcargoCounter,
	        ["y"] = yCenter + yofs,
	        ["x"] = xCenter + xofs,
	        ["name"] = name,
	        ["category"] = "Fortifications",
	        ["heading"] = angle,
	}

	-- adds new object to the list of dropped objects
	if CheckInTable (DroppedObjects, name) == false then
		table.insert(DroppedObjects, name)
	end
    
    logcargoCounter = logcargoCounter + 1  
	
	ConfigObject (static, groupside)
    return static  
end

-----------------------------------------------------------------

-- Add structure for logistics

function NewCargoCrate(angle, radius, xCenter, yCenter, groupside)
	local name = "LogCargoCrate" .. logcargoCrateCounter

    local xofs = math.cos(angle) * radius
    local yofs = math.sin(angle) * radius

    local static = nil

	static = {
		["category"] = "Cargo",
    	["shape_name"] = "ab-212_cargo", 
    	["type"] = "Cargo1",
    	["unitId"] = logcargoCounter,
    	["y"] = yCenter + yofs,
    	["x"] = xCenter + xofs,
		["mass"] = cargoCrateMassKG,
    	["name"] = name,
		["canCargo"] = true,		
    	["heading"] = angle,
	}
    
    logcargoCrateCounter = logcargoCrateCounter + 1  
	
	ConfigObject (static, groupside)
    return static  
end




-----------------------------------------------------------------

-- Add group to coalitions

function ConfigGroup (newGroup, groupside)
	if groupside == 2 then 
		coalition.addGroup(country.id.USA, Group.Category.GROUND, newGroup)
	elseif groupside == 1 then
		coalition.addGroup(country.id.RUSSIA, Group.Category.GROUND, newGroup)
	else 
		coalition.addGroup(country.id.INSURGENTS, Group.Category.GROUND, newGroup)
	end
	
	return
end

-- Add dropped object to coalitions

function ConfigObject (newObject, groupside)
	if groupside == 2 then
		coalition.addStaticObject(country.id.USA, newObject)
	elseif groupside == 1 then
		coalition.addStaticObject(country.id.RUSSIA, newObject)
	else 
		coalition.addStaticObject(country.id.INSURGENTS, newObject)
	end
	
	return
end

-----------------------------------------------------------------

-- Find nearest dropped or extractable group

function FindNearestGroup(unit, groupside)
    local minDist = maxDistExt
    local droppedGroup = "NONE"
    local unitpos = unit:getPoint()	
	local group = nil
	local units = nil
	local leader = nil
	local leaderpos = nil
	local dist = nil
	
	if groupside == 2 then
	    for i=1,#DroppedGroupBlue do
			if DroppedGroupBlue[i] ~= nil then
				group = Group.getByName(DroppedGroupBlue[i])
				if group ~= nil then
					
					units = group:getUnits()

					if units ~= nil and #units > 0 then

						for x = 1, #units do
							if units[x]:getLife() > 0 then
								leader = units[x]
								break
							end
						end

						if leader ~= nil then
							leaderpos = leader:getPoint()
							dist = GetDistance(unitpos.x, unitpos.z, leaderpos.x, leaderpos.z)
							if dist < minDist then
								minDist = dist -- use this to keep always the already shortest distance found in the series as new limit
								droppedGroup = DroppedGroupBlue[i]
							end
						end

					end
				
				end

			end
        end
					
	elseif groupside == 1 then
	    for i=1,#DroppedGroupRed do
			if DroppedGroupRed[i] ~= nil then
				group = Group.getByName(DroppedGroupRed[i])
				if group ~= nil then
					units = group:getUnits()
					if units ~= nil and #units > 0 then
						
						for x = 1, #units do
							if units[x]:getLife() > 0 then
								leader = units[x]
								break
							end
						end

						if leader ~= nil then
							leaderpos = leader:getPoint()
							dist = GetDistance(unitpos.x, unitpos.z, leaderpos.x, leaderpos.z)
							if dist < minDist then
								minDist = dist -- use this to keep always the already shortest distance found in the series as new limit
								droppedGroup = DroppedGroupRed[i]
							end
						end
					
					end
				end
			end
		end
	end
    
    return droppedGroup    
end

-----------------------------------------------------------------
-- Find nearest logistic group

function FindNearestLogGroup(unit, groupside)
    local minDist = maxDistLog
    local logisticGroup = "NONE"
    local unitpos = unit:getPoint()	
	local group = nil
	local units = nil
	local leader = nil
	local leaderpos = nil
	local dist = nil
	
	if groupside == 2 then
	    for i=1,#LogisticBlue do
			if LogisticBlue[i] ~= nil then
				group = Group.getByName(LogisticBlue[i])
				if group ~= nil then
					units = group:getUnits()

					if units ~= nil and #units > 0 then
						
						for x = 1, #units do
							if units[x]:getLife() > 0 then
								leader = units[x]
								break
							end
						end

						if leader ~= nil then
							leaderpos = leader:getPoint()
							dist = GetDistance(unitpos.x, unitpos.z, leaderpos.x, leaderpos.z)
							if dist < minDist then
								minDist = dist -- use this to keep always the already shortest distance found in the series as new limit
								logisticGroup = LogisticBlue[i]
							end
						end
					
					end
				end
			end
        end
					
	elseif groupside == 1 then
	    for i=1,#LogisticRed do
			if LogisticRed[i] ~= nil then
				group = Group.getByName(LogisticRed[i])
				if group ~= nil then
					units = group:getUnits()

					if units ~= nil and #units > 0 then
						for x = 1, #units do
							if units[x]:getLife() > 0 then
								leader = units[x]
								break
							end
						end

						if leader ~= nil then
							leaderpos = leader:getPoint()
							dist = GetDistance(unitpos.x, unitpos.z, leaderpos.x, leaderpos.z)
							if dist < minDist then
								minDist = dist -- use this to keep always the already shortest distance found in the series as new limit
								logisticGroup = LogisticRed[i]
							end
						end
					end
				end
			end
		end
	end
    
    return logisticGroup    
end


-- Find nearest enemy to coalition according to a reference position

function FindNearestEnemy(refpos, radius, groupside)
    local minDist = maxDistEnemy

	if radius == 0 then
		minDist = 50
	end

    local EnemyPos = nil
	local destination = nil
	local xdest = nil
	local ydest = nil
	local selected = nil
	local group = nil
	local groupName = nil
	local units = nil
	local leader = nil
	local leaderpos = nil
	local dist = nil
	local RedList = coalition.getGroups(1, Group.Category.GROUND)
	local BlueList = coalition.getGroups(2, Group.Category.GROUND)
	local tbl = nil

	if groupside == 2 then
		tbl = RedList
	elseif groupside == 1 then
		tbl = BlueList
	end

    for i = 1, #tbl do
		if tbl[i] ~= nil then
			groupName = tbl[i]:getName()
			group = Group.getByName(groupName)
			if group ~= nil then
				units = group:getUnits()
				if units ~= nil and #units > 0 then
					for x = 1, #units do
						if units[x]:getLife() > 0 then
							leader = units[x]
							break
						end
					end
					if leader ~= nil then
						leaderpos = leader:getPoint()
						dist = GetDistance(refpos.x, refpos.z, leaderpos.x, leaderpos.z)
						if dist < minDist then
							minDist = dist
							EnemyPos = leaderpos
						end
					end
				end
			end
		end
	end

	if EnemyPos ~= nil then
		xdest = EnemyPos.x + math.random(100, 200) - math.random(100, 200)
		ydest = EnemyPos.z + math.random(100, 200) - math.random(100, 200)
	else
		xdest = refpos.x + math.random(0, radius) - math.random(0, radius)
		ydest = refpos.z + math.random(0, radius) - math.random(0, radius)
	end

	local destination = {
		x = xdest,
		y = ydest,
	}

    return destination
end
-----------------------------------------------------------------

-- Find nearest dropped cargo item

function FindNearestLogItem(unit)
    local minDist = maxDistLog
    local droppedItem = "NONE"
    local unitpos = unit:getPoint()	

	local item = nil
	local itempos = nil
	local dist = nil

	for i=1,#DroppedObjects do
		if DroppedObjects[i] ~= nil then
			item = StaticObject.getByName(DroppedObjects[i])
			if item ~= nil then
				itempos = item:getPoint()
				dist = GetDistance(unitpos.x, unitpos.z, itempos.x, itempos.z)
				if dist < minDist then
					minDist = dist -- use this to keep always the already shortest distance found in the series as new limit
					droppedItem = DroppedObjects[i]
				end
			end
		end
    end
    
    return droppedItem   
end

-----------------------------------------------------------------
--------------- RADIO COMMAND AND AUTOCOMMAND -------------------
-----------------------------------------------------------------

-- Add actions to transports

function AddRadioCommands(arg, time)
	for i=1,#TransportsNames do
		AddRadioCommand(TransportsNames[i])
	end

    return time + 5
end

-- Radio command for players (F10 Menu)

function AddRadioCommand(unitName)
    if RadioCommandTable[unitName] == nil then
		local unit = Unit.getByName(unitName)  
        if unit == nil then
            return
        end
 
		local group = unit:getGroup()
        if group == nil then
            return
        end
		
		-- default values
        UnitLoadTable[unitName] = false
		UnitAutoAction[unitName] = true
		UnitCargoCount[unitName] = defCargoNum
		UnitCargoName[unitName] = "CargoGroup"
		UnitCargoBayTable[unitName] = false
		UnitCargoItem[unitName] = "CargoItem"
        		
        local gid = group:getID()        
        missionCommands.addCommandForGroup(gid, radiotext1, nil, UnitTroopsCommand, unitName)
		missionCommands.addCommandForGroup(gid, radiotext2, nil, UnitCargobayCommand, unitName)
		missionCommands.addCommandForGroup(gid, radiotext3, nil, UnitCheckCargo, unitName)


		if cargoSpawn == true then
			missionCommands.addCommandForGroup(gid, radiotext4, nil, SpawnSlingloadCargo, unitName)
		end
		
        RadioCommandTable[unitName] = true
	end
end

-----------------------------------------------------------------
----------------------- LOAD/UNLOAD ACTIONS ---------------------
-----------------------------------------------------------------

-- Check cargo status

function UnitCheckCargo(unitName)
	local unit = Unit.getByName(unitName)  
	
    if unit == nil then
        return
    end
 
	local group = unit:getGroup()
    if group == nil then
        return
    end
        		
    local gid = group:getID()

	if UnitLoadTable[unitName] == true and UnitCargoBayTable[unitName] == true then
		trigger.action.outTextForGroup(gid, "Your vehicle is loaded with " .. UnitCargoCount[unitName] .. " troops and with equipment too", 5)		
		if UnitAutoAction[unitName] == true then
			trigger.action.outTextForGroup(gid, "Your vehicle is loaded with " .. UnitCargoCount[unitName] .. " troops and with equipment too. Auto-Unload is ACTIVE", 5)
		end
	elseif UnitLoadTable[unitName] == true and UnitCargoBayTable[unitName] == false then
		trigger.action.outTextForGroup(gid, "Your vehicle is loaded with " .. UnitCargoCount[unitName] .. " troops", 5)		
		if UnitAutoAction[unitName] == true then
			trigger.action.outTextForGroup(gid, "Your vehicle is loaded with " .. UnitCargoCount[unitName] .. " troops. Auto-Unload is ACTIVE", 5)
		end
	elseif UnitLoadTable[unitName] == false and UnitCargoBayTable[unitName] == true then
		trigger.action.outTextForGroup(gid, "Your cargo bay is loaded with equipment", 5)		
	else
		trigger.action.outTextForGroup(gid, "Your vehicle is empty", 5)
		if UnitAutoAction[unitName] == true then
			trigger.action.outTextForGroup(gid, "Your vehicle is empty. Auto-Load is ACTIVE", 5)
		end
	end
	
	return
end

-----------------------------------------------------------------

-- Manual load/unload for players

function UnitTroopsCommand(unitName)
	local radius = maxDistDrop
    local unit = Unit.getByName(unitName)
    
    if unit == nil then
        return
    end
    
	local unitpos = unit:getPoint()
    local unitId = unit:getID()
    local group = unit:getGroup()
    local groupName = group:getName()
	local groupside = group:getCoalition()
	local newGroup = nil	
	local destination = nil	
	local gid = group:getID()	
	local flying = unit:inAir()	
    local playerName = unit:getPlayerName()
	
	if playerName == nil then
        playerName = "Ground Commander"
    end 
 		    
    local pickupZone = UnitInAnyPickupZone(unit)
	local nearestGroup = FindNearestGroup(unit, groupside)
	local extgroup = nil

	UnitAutoAction[unitName] = false -- disables auto load/unload for AI when action has been activated by player	
	
    if pickupZone ~= nil then
		if UnitLoadTable[unitName] == false then
			trigger.action.outTextForCoalition(groupside, playerName .. " loaded troops at pickup zone", 5)
			
			UnitLoadTable[unitName] = true
			UnitCargoCount[unitName] = defCargoNum
									
			if nearestGroup ~= "NONE" then -- if there´s a spawned group nearby deletes it
				extgroup = Group.getByName(nearestGroup)
				UnitCargoCount[unitName] = #extgroup:getUnits()
				UnitCargoName[unitName] = nearestGroup
				extgroup:destroy()
			end
		else
			trigger.action.outTextForCoalition(groupside, playerName .. " returned troops to base", 5)
			
			UnitLoadTable[unitName] = false
			
			destination = FindNearestEnemy(unitpos, radius, groupside)
			newGroup = DropoffGroupDirect(UnitCargoCount[unitName], 15, unitpos.x, unitpos.z, destination.x, destination.y, groupside, UnitCargoName[unitName]) -- spawns a group
		
		end		
    else
		if flying == false then
            if UnitLoadTable[unitName] == true then
				trigger.action.outTextForCoalition(groupside, playerName .. " dropped troops", 5)
				
				UnitLoadTable[unitName] = false
				
				destination = FindNearestEnemy(unitpos, radius, groupside)
				newGroup = DropoffGroupDirect(UnitCargoCount[unitName], 15, unitpos.x, unitpos.z, destination.x, destination.y, groupside, UnitCargoName[unitName]) -- spawns a group
				
            else
				if nearestGroup ~= "NONE" then -- if there´s a spawned group nearby deletes it
					trigger.action.outTextForCoalition(groupside, playerName .. " extracted troops", 5)
					
					UnitLoadTable[unitName] = true
					
					extgroup = Group.getByName(nearestGroup)
					UnitCargoCount[unitName] = #extgroup:getUnits()
					UnitCargoName[unitName] = nearestGroup
					extgroup:destroy()					
				else
					trigger.action.outTextForGroup(gid, "You don't have any extractable troops or pickup zone nearby", 5)					
				end				
            end
		end
    end      	
end

-----------------------------------------------------------------

-- Automatic load/unload for AI

function UnitTroopsCommandAI(unitName)
	local radius = maxDistDrop
    local unit = Unit.getByName(unitName)
    
    if unit == nil then
        return
    end
					
    local unitpos = unit:getPoint()
    local unitId = unit:getID()
    local group = unit:getGroup()
    local groupName = group:getName()
	local groupside = group:getCoalition()
	local newGroup = nil	
	local destination = nil
    
    local pickupZone = UnitInAnyPickupZone(unit)
    local dropoffZone = UnitInAnyDropoffZone(unit)
	local neardropZone = CheckDropDistance(unit)
    
    if pickupZone ~= nil then -- AI transport loads troops at pickup zone
		if UnitAutoAction[unitName] == true then
			UnitLoadTable[unitName] = true
			UnitCargoCount[unitName] = defCargoNum
		end		
    else
        if (dropoffZone ~= nil and neardropZone ~= nil and UnitAutoAction[unitName] == true) then -- AI transport drops troops if auto unload is active
            if UnitLoadTable[unitName] == true then			
				UnitLoadTable[unitName] = false

				destination = FindNearestEnemy(unitpos, radius, groupside)
				newGroup = DropoffGroupDirect(UnitCargoCount[unitName], 15, unitpos.x, unitpos.z, destination.x, destination.y, groupside) -- spawns a group
            end
        end
    end       
end

-----------------------------------------------------------------

-- Cargo bay loading (logistics)

function UnitCargobayCommand(unitName)

    local unit = Unit.getByName(unitName)
    
    if unit == nil then
        return
    end
	
	local position = unit:getPosition()
	local unitpos = unit:getPoint()
    local group = unit:getGroup()
	local groupside = group:getCoalition()
	local gid = group:getID()
	local flying = unit:inAir()	
	local groupside = group:getCoalition()
	local playerName = unit:getPlayerName()
	
	if playerName == nil then
        playerName = "Ground Commander"
    end 

	local nearestGroup = FindNearestLogGroup(unit, groupside)
	local nearestCargo = FindNearestLogItem(unit)

	local newObject = nil
	local item = nil
	
	local angle = math.atan2(position.x.z, position.x.x)
	
	if nearestGroup ~= "NONE" then 
		if UnitCargoBayTable[unitName] == false then
			trigger.action.outTextForCoalition(groupside, playerName .. " loaded equipment on its cargo bay", 5)	
			
			UnitCargoBayTable[unitName] = true
			UnitCargoItem[unitName] = "CargoItem"
			
			if nearestCargo ~= "NONE" then -- if there´s a spawned cargo item nearby deletes it
				item = StaticObject.getByName(nearestCargo)
				UnitCargoItem[unitName] = nearestCargo
				item:destroy()
			end
			
		else
			trigger.action.outTextForCoalition(groupside, playerName .. " returned equipment to logistics group", 5)
			
			UnitCargoBayTable[unitName] = false
						
			newObject = NewStructure(angle, 20, unitpos.x, unitpos.z, groupside, UnitCargoItem[unitName])
		end
	else
		if flying == false then
			if UnitCargoBayTable[unitName] == true then
				trigger.action.outTextForCoalition(groupside, playerName .. " dropped equipment on the field", 5)
				
				UnitCargoBayTable[unitName] = false
				
				newObject = NewStructure(angle, 20, unitpos.x, unitpos.z, groupside, UnitCargoItem[unitName])			

			else
				if nearestCargo ~= "NONE" then
					trigger.action.outTextForCoalition(groupside, playerName .. " recovered equipment from the field", 5)
					
					UnitCargoBayTable[unitName] = true
					
					item = StaticObject.getByName(nearestCargo)
					UnitCargoItem[unitName] = nearestCargo
					item:destroy()
				else
					trigger.action.outTextForGroup(gid, "You don´t have any logistics group or equipment nearby", 5)
				end
			end
		end
	end
	
	return
	
end

function SpawnSlingloadCargo(unitName)

	local unit = Unit.getByName(unitName)
    
    if unit == nil then
        return
    end
	
	local newObject = nil
	local position = unit:getPosition()
	local unitpos = unit:getPoint()
	local group = unit:getGroup()
	local groupside = group:getCoalition()
	local gid = group:getID()
	local flying = unit:inAir()	
	local groupside = group:getCoalition()
	local playerName = unit:getPlayerName()
	
	if playerName == nil then
        playerName = "Ground Commander"
    end 

    local angle = math.atan2(position.x.z, position.x.x)
	
	if flying == false then
		trigger.action.outTextForCoalition(groupside, playerName .. " spawned Cargo Crate!", 5)
				
		newObject = NewCargoCrate(angle, 20, unitpos.x, unitpos.z, groupside )		
	end	

end
	

-----------------------------------------------------------------
-------------------- GENERAL FUNCTIONS --------------------------
-----------------------------------------------------------------

-- Distance measurement between two positions

function GetDistance(xUnit, yUnit, xZone, yZone)
    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone
    return math.sqrt(xDiff * xDiff + yDiff * yDiff)    
end

-- Check table for existing value

function CheckInTable (tableName, value)
	for i=1, #tableName do
		if tableName[i] == value then
			return true
		end
	end
	return false
end

-----------------------------------------------------------------
-------------- DETECTION OF UNITS IN TRIGGERS -------------------
-----------------------------------------------------------------

-- Detection of units inside trigger

function UnitInZone(unit, zone)
    if unit:inAir() then
        return false
    end
    
    local triggerZone = trigger.misc.getZone(zone.ZoneName)
	if triggerZone == nil then -- used in case the selected trigger doesn´t exist
		return false
	end
	
    local group = unit:getGroup()
    local groupid = group:getID()
    local unitpos = unit:getPoint()
    local xDiff = unitpos.x - triggerZone.point.x
    local yDiff = unitpos.z - triggerZone.point.z
    local dist = math.sqrt(xDiff * xDiff + yDiff * yDiff)
    
    if dist > triggerZone.radius then
        return false
    end
    
    return true
end

-----------------------------------------------------------------

-- Unit in a pickzone

function UnitInAnyPickupZone(unit)
    for i=1,#PickupZones do
        if UnitInZone(unit, PickupZones[i]) then
            return PickupZones[i]
        end
    end
    
    return nil
end

-----------------------------------------------------------------

-- Unit in a dropzone

function UnitInAnyDropoffZone(unit)
    for i=1,#DropoffZones do
        if UnitInZone(unit, DropoffZones[i]) then
            return DropoffZones[i]
        end
    end
    
    return nil
end

-----------------------------------------------------------------

-- Find nearest dropzone for AI transports auto unload

function CheckDropDistance(unit)	
    local minZone = nil
    local unitpos = unit:getPoint()	
	local group = unit:getGroup()
	local gtype = group:getCategory()	
	local minDist = minDistAir
	
	if gtype == 2 then -- min distance to trigger auto dropping for AI ground vehicles
		minDist = minDistGround
	end
    
    for i=1,#DropoffZones do
        local zone = DropoffZones[i]
        local triggerZone = trigger.misc.getZone(zone.ZoneName)
		if triggerZone ~= nil then
			local dist = GetDistance(unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
			if dist < minDist then
				minDist = dist -- use this to keep always the already shortest distance found in the series as new limit
				minZone = zone
			end
		end
    end
    
    return minZone    
end

-- ************************************************************************
-- ******************* MISSION TOOLS (STANDALONE) *************************
-- ************************************************************************

-- Pre-load a transport with troops. Usage:

--			LoadTransport("unitname", number)

-- Variables:
-- "unitname" = name of unit (must be enabled for transport before)
-- number = number of troops to load

function LoadTransport(unitName, count)
	for i=1,#TransportsNames do
		if unitName == TransportsNames[i] then
			UnitLoadTable[unitName] = true
			UnitAutoAction[unitName] = true
		end
	end

	if count == nil then
		UnitCargoCount[unitName] = defCargoNum
	else
		UnitCargoCount[unitName] = count
	end
	
	return
end

-----------------------------------------------------------------

-- Spawn group at a trigger and sets them as extractable. Usage:

-- 			CallSpawn("groupside", number, "triggerName", radius)

-- Variables:
-- "groupside" = "ins" for insurgents, "red" for Russia "blue" for USA
-- number = number of groups to spawn
-- "triggerName" = trigger name in mission editor between commas
-- radius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)

-- Example: CallSpawn("red", 2, "spawn1", 1000)
-- This example will spawn 2 groups of russians at trigger "spawn1" and they will search for enemy or move randomly withing 1000m

function CallSpawn(groupside, number, triggerName, radius)
	local SpawnTrigger = trigger.misc.getZone(triggerName) -- trigger to use as reference position
	
	if SpawnTrigger == nil then
		trigger.action.outText("CTTS.lua ERROR: not existing trigger used for spawn troops(" .. triggerName .. ")", 10)	
		return
	end

	if groupside == "red" then
		groupside = 1
	elseif groupside == "blue" then
		groupside = 2
	else
		groupside = 0
	end
	
	if number < 1 then
		number = 1
	end
	
	if radius < 0 then
		radius = 0
	end

	local count = defCountSpawn
	local xpos = SpawnTrigger.point.x
	local ypos = SpawnTrigger.point.z
	
	local refpos = {
		x = xpos, 
		y = 0, 
		z = ypos 
	}
	
	local destination = nil
	local xdest = nil
	local ydest = nil
	
	for i=1, number do
		local newGroup = nil
		local offset = -15*i
		local xpos = offset + SpawnTrigger.point.x
		local ypos = SpawnTrigger.point.z
		
		destination = FindNearestEnemy(refpos, radius, groupside)
		newGroup = DropoffGroupDirect(count, 15, xpos, ypos, destination.x, destination.y, groupside) -- spawn group
	end	
end

-----------------------------------------------------------------------------

-- Continuous count of extracted units inside a trigger

--		CountExtracted("triggerName",flagBlue,flagRed)

-- Variables:

-- "triggerName" = name of trigger to supervise
-- flagBlue = userflag to count the number of blue units inside trigger
-- flagRed = userflag to count the number of red units inside trigger

-- Example: CountExtracted("trigger1",200,201) this will count the units inside "trigger1" and store the values in the flags 200 and 201 (which can be accessed by mission)

function CountExtractedTable(arg)
	local triggerName = arg[1]
	local flagBlue = arg[2]
	local flagRed = arg[3]
	
	CountExtracted(triggerName, flagBlue, flagRed)
	
	return	
end

function CountExtracted(triggerName, FBlue, FRed)
	local triggerZone = trigger.misc.getZone(triggerName) -- trigger to use as reference position
	
	local flagBlue = tostring(FBlue)
	local flagRed = tostring(FRed)
	
	if triggerZone == nil then
		trigger.action.outText("CTTS.lua ERROR: not existing trigger used for troops supervision (" .. triggerName .. ")", 10)	
		return nil
	end
	
	local countblue = 0
	local countred = 0
	local group = nil
	local units = nil
	local unit = nil
	local unitpos = nil
	local dist = nil
	
	for i=1,#DroppedGroupBlue do
		group = Group.getByName(DroppedGroupBlue[i])
		if group ~= nil then
			units = group:getUnits()
				
			for j=1,#units do
				unit = units[j]
				unitpos = unit:getPoint()
				dist = GetDistance(unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
			
				if dist < triggerZone.radius then
					countblue = countblue + 1
				end
			end
		end
	end
	
	for i=1,#DroppedGroupRed do
		group = Group.getByName(DroppedGroupRed[i])
		if group ~= nil then
			units = group:getUnits()
				
			for j=1,#units do
				unit = units[j]
				unitpos = unit:getPoint()
				dist = GetDistance(unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
			
				if dist < triggerZone.radius then
					countred = countred + 1
				end
			end
		end
	end
	
	local newarg = {triggerName, flagBlue, flagRed}	-- schedules a continuous check
	timer.scheduleFunction(CountExtractedTable, newarg, timer.getTime() + 5)
	
	trigger.action.setUserFlag(flagBlue, countblue) -- sets user flags with values
	trigger.action.setUserFlag(flagRed, countred)
	
	--trigger.action.outText("Blue units: " .. countblue .. " (" .. #DroppedGroupBlue .. " total groups). // Red units: " .. countred .. " (" .. #DroppedGroupRed .. " total groups)", 3)
	--trigger.action.outText("Blue units: " .. trigger.misc.getUserFlag(flagBlue) .. " (" .. #DroppedGroupBlue .. " total groups). // Red units: " .. trigger.misc.getUserFlag(flagRed) .. " (" .. #DroppedGroupRed .. " total groups)", 3)
	
    return
end

-----------------------------------------------------------------

-- Spawn logistic items at a trigger. Usage:

-- 			CallSpawnLogistics("groupside", number, "triggerName", radius)

-- Variables:
-- "groupside" = "ins" for insurgents, "red" for Russia "blue" for USA
-- number = number of items to spawn
-- "triggerName" = trigger name in mission editor between commas
-- radius = separarion between items

-- Example: CallSpawnLogistics("blue", 2, "spawn1", 30)
-- This example will spawn 2 cargo items for USA at trigger "spawn1" separated 30m

function CallSpawnLogistics(groupside, number, triggerName, radius)
	local SpawnTrigger = trigger.misc.getZone(triggerName) -- trigger to use as reference position
	
	if SpawnTrigger == nil then
		trigger.action.outText("CTTS.lua ERROR: not existing trigger used for spawn logistic items(" .. triggerName .. ")", 10)	
		return
	end
	
	if groupside == "red" then
		groupside = 1
	elseif groupside == "blue" then
		groupside = 2
	else
		groupside = 0
	end
	
	if number < 1 then
		number = 1
	end
	
	if radius < 20 then
		radius = 20
	end

	local newObject = nil
	local xpos = SpawnTrigger.point.x
	local ypos = SpawnTrigger.point.z
	
	for i=1, number do
		local newGroup = nil
		local offset = -15*i
		local xpos = offset + SpawnTrigger.point.x
		local ypos = SpawnTrigger.point.z
		
		newObject = NewStructure(0, i*radius, xpos, ypos, groupside) -- spawn item
	end	
end

-----------------------------------------------------------------------------

-- Continuous count of dropped logistic items inside a trigger

--		CountLogistics("triggerName",flagLog)

-- Variables:

-- "triggerName" = name of trigger to supervise
-- flagLog = userflag to count the number of logistic items inside trigger

-- Example: CountLogistics("trigger1",300) this will count the items inside "trigger1" and store the values in the flag 300 (which can be accessed by mission)

function CountLogisticsTable(arg)
	local triggerName = arg[1]
	local flagLog = arg[2]
	
	CountLogistics(triggerName, flagLog)
	
	return	
end

function CountLogistics(triggerName, FLog)
	local triggerZone = trigger.misc.getZone(triggerName) -- trigger to use as reference position
	
	local flagLog = tostring(FLog)
	
	if triggerZone == nil then
		trigger.action.outText("CTTS.lua ERROR: not existing trigger used for logistics supervision (" .. triggerName .. ")", 10)	
		return nil
	end
	
	local countlog = 0
	local item = nil
	local itempos = nil
	local dist = nil
	
	for i=1,#DroppedObjects do
		item = StaticObject.getByName(DroppedObjects[i])
		if item ~= nil then
			itempos = item:getPoint()
			dist = GetDistance(itempos.x, itempos.z, triggerZone.point.x, triggerZone.point.z)
			if dist < triggerZone.radius then
				countlog = countlog + 1
			end
		end
	end
	
	
	local newarg = {triggerName, flagLog}	-- schedules a continuous check
	timer.scheduleFunction(CountLogisticsTable, newarg, timer.getTime() + 5)
	
	trigger.action.setUserFlag(flagLog, countlog) -- sets user flags with values
	
    return
end

-- ************************************************************************
-- ********************** Radio AM/FM & Beacons ***************************
-- ************************************************************************

-- Radio AM/FM Transmission Configuration.
-- Script made by Geloxo

-- Use it to configure radio beacons with periodical recall for JIP or to send messages without any group configuration

-- Examples:
-- RadioAM("huey1", 226, "Atmospheric.ogg", "Information") this will send a message with subtitles "Information" from huey1 on freq 226 AM (UHF)
-- RadioFM("huey1", 30, "Atmospheric.ogg", "Information") this will send a message with subtitles "Information" from huey1 on freq 30 FM
-- BeaconAM("huey1", 117, "Atmospheric.ogg") this will set an AM beacon on huey1 on freq 117 AM (VHF)
-- BeaconFM("huey1", 40, "Atmospheric.ogg") this will set a FM beacon on huey1 on freq 40 FM
-- RadioHQ("huey1", 118, "Atmospheric.ogg", "Information") this will send a periodical message with subtitles "Information" from huey1 on freq 118 FM

function RadioGen(groupName, freq, filename, text, radBand, loop, mesDuration)

	-- modulation: 0 --> AM // 1 --> FM
	-- freq: 119400000 --> 119.4 MHz

	local group = Group.getByName(groupName)
	if group == nil then
		return
	end
	
	local groupcontroller = group:getController()
	local freqMHz = freq * 1000000
	
	if filename == nil then
		return
	end
	
	local radioset = {
		[1] = {
			["enabled"] = true,
			["auto"] = false,
			["id"] = "WrappedAction",
			["number"] = 1, -- first task
			["params"] = {
				["action"] = {
					["id"] = "SetFrequency",
					["params"] = {
						["modulation"] = radBand,
						["frequency"] = freqMHz,
					},
				},
			},
		},
	}
	
	local radiotrans = {
		[1] = {
            ["enabled"] = true,
            ["auto"] = false,
            ["id"] = "WrappedAction",
            ["number"] = 2, -- second task
            ["params"] = {
                ["action"] = {
					["id"] = "TransmitMessage",
                    ["params"] = {
                        ["loop"] = loop,
                        ["subtitle"] = text,
                        ["duration"] = mesDuration,
                        ["file"] = filename,
                    },
                },
            },
        },
	}	

	Controller.setTask(groupcontroller, radioset[1])
	Controller.setTask(groupcontroller, radiotrans[1])
	
	return
end

-----------------------------------------------------------------------------

-- Send single message on AM

function RadioAM(groupName, freq, filename, text)

	-- modulation: 0 --> AM // 1 --> FM
	-- freq: 119400000 --> 119.4 MHz

	local group = Group.getByName(groupName)
	if group == nil then
		return
	end
	
	local groupcontroller = group:getController()
	local freqMHz = freq * 1000000
	
	if filename == nil then
		trigger.action.outText("CTTS.lua ERROR: missing filename for AM radio sound", 10)
		return
	end
	
	RadioGen(groupName, freq, filename, text, 0, false, radioTime)
		
	return
end

-- Send single message on FM

function RadioFM(groupName, freq, filename, text)

	local group = Group.getByName(groupName)
	if group == nil then
		return
	end
	
	local groupcontroller = group:getController()
	local freqMHz = freq * 1000000
		
	if filename == nil then
		trigger.action.outText("CTTS.lua ERROR: missing filename for FM radio sound", 10)
		return
	end
	
	RadioGen(groupName, freq, filename, text, 1, false, radioTime)
	
	return
end

-----------------------------------------------------------------------------

-- Beacons (loops)

function BeaconAMTable(arg)
	BeaconAM(arg[1], arg[2], arg[3])
	
	return	
end

function BeaconFMTable(arg)
	BeaconFM(arg[1], arg[2], arg[3])
	
	return	
end

function RadioHQTable(arg)
	RadioHQ(arg[1], arg[2], arg[3], arg[4])
	
	return	
end

-- AM Beacon: localizer loop on AM

function BeaconAM(groupName, freq, filename)

	local group = Group.getByName(groupName)
	if group == nil then
		return
	end
	
	local groupcontroller = group:getController()
	local freqMHz = freq * 1000000
		
	if filename == nil then
		trigger.action.outText("CTTS.lua ERROR: missing filename for AM radio beacon", 10)
		return
	end
	
	RadioGen(groupName, freq, filename, "", 0, true, 5)
	
	local newarg = {groupName, freq, filename}
	timer.scheduleFunction(BeaconAMTable, newarg, timer.getTime() + radioLoop)	
	
	return

end

-- FM Beacon: localizer loop on FM

function BeaconFM(groupName, freq, filename)

	local group = Group.getByName(groupName)
	if group == nil then
		return
	end
	
	local groupcontroller = group:getController()
	local freqMHz = freq * 1000000
		
	if filename == nil then
		trigger.action.outText("CTTS.lua ERROR: missing filename for FM radio beacon", 10)
		return
	end
	
	RadioGen(groupName, freq, filename, "", 1, true, 5)
	
	local newarg = {groupName, freq, filename}
	timer.scheduleFunction(BeaconFMTable, newarg, timer.getTime() + radioLoop)	
	
	return

end

-- ATIS: Send message information periodically on AM

function RadioHQ(groupName, freq, filename, text) -- AM message repetition with subtitles

	local group = Group.getByName(groupName)
	if group == nil then
		return
	end
	
	local groupcontroller = group:getController()
	local freqMHz = freq * 1000000
		
	if filename == nil then
		trigger.action.outText("CTTS.lua ERROR: missing filename for ATIS", 10)
		return
	end
	
	RadioGen(groupName, freq, filename, text, 0, false, radioTime)
	
	local newarg = {groupName, freq, filename, text}
	timer.scheduleFunction(RadioHQTable, newarg, timer.getTime() + radioLoop)	
	
	return

end

-- ************************************************************************
-- *************** THREADS AND SCHEDULED **********************************
-- ************************************************************************

-- Continuous checking of units status

function CheckStatus()
	for i=1,#TransportsNames do
		local unitName = TransportsNames[i]
		local unit = Unit.getByName(unitName)
		
		if unit == nil then
			UnitLoadTable[unitName] = false -- if unit is dead or player respawns set unit as unloaded
			UnitCargoName[unitName] = "CargoGroup"
			UnitCargoBayTable[unitName] = false
			UnitCargoItem[unitName] = "CargoItem"
		else
			local playerName = unit:getPlayerName()
			if playerName == nil then -- It´s Ground Commander or a unit not controlled by players
				timer.scheduleFunction(UnitTroopsCommandAI, unitName, timer.getTime() + 2) -- performs auto load/unload on any AI unit
			else
				UnitAutoAction[unitName] = false -- disables auto action for units controlled by players
			end
		end
	end
	
	timer.scheduleFunction(CheckStatus, nil, timer.getTime() + 2)	-- re-check status
	
	return
end

-----------------------------------------------------------------

-- Scheduled functions (run once)

timer.scheduleFunction(AddExtGroups, nil, timer.getTime() + 5)
timer.scheduleFunction(AddLogGroups, nil, timer.getTime() + 5)

-- Scheduled functions (run cyclically)
 
timer.scheduleFunction(SmokeTimer, nil, timer.getTime() + 5)
timer.scheduleFunction(AddRadioCommands, nil, timer.getTime() + 5)
timer.scheduleFunction(CheckStatus, nil, timer.getTime() + 2)

-- ************************************************************************
