# DCS-CTTS
Complete Combat Troop Drop for DCS

##TROOPS TRANSPORTATION:

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

- AI transports will automatically load troops only when inside the pickup triggers. AI transports won't extract any unit automatically (to avoid interferences with human players)
- AI transports will automatically unload troops only if they are close enough to drop triggers center (default 500m for ground units and 10km for air units). This allows AI ground units to enter triggers without dropping
- Ground Commander take control of AI transports via Combined Arms module and manually load and unload troops with them (this will disable the auto load/unload feature for the AI transport) 
- Ground Commander can move any of the deployed troops manually in the field

##LOGISTICS:

- Human players can load equipment when close to any logistics supplier group from their coalition and deploy it everywhere
- Any human controlled transport enabled for troops transportation will be automatically enabled for logistics as well (AI transports do not support logistics, cause it's useless in this case)
- To manually define a GROUP as logistics supplier add its GROUPNAME to the list of logistics groups or use any of the predefined ones in your mission
- An extractable group of troops can be used as logistics as well (by setting the same name in both lists)
- Deployed logistic items can be transported by any coalition (you can steal the enemy ones)
- There´s no need to define logistic items in mission. You need to spawn them with the standalone function (this is used to keep consistency between cargo 3D models)


#IMPORTANT NOTES:

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