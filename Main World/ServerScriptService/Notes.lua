 --[[TOP PRIORITY:
1) Projectiles
3) Stats
4) Settings
]]--

--[[ PROJECTILES:
On the client input:
1) Click -> FireServer -> FireAll(Other)Clients
2) After firing server, render their own projectile and raycast. This is the only one used for hit detection

For each client:
1) Receives initial position, velocity, and time sent to calculate delay
2) Raycast every frame AND render a "dummy" projectile (massless and cancollide OFF).
3) Give this dummy projectile a BodyVelocity equal to the raycast "velocity"
4) Continues to raycast at the same speed as the projectile (the physical projectile is PURE VISUALS)

Server:
1) Only acts when client fires and when client declares detection
When client fires:
FireAllClients so others render their own dummy bullet (purely visual)

When client declares detection:
Shoot ray to position to confirm


]]--

--[[TO-ADD LIST
1) Work on GUI for R skills (cooldown, images, etc)
2) Stats GUI
2.5) Work on projectiles (magics, etc)
3) Make a few collectibles and their consume function
4) NPCs and Shops
5) Make mobs attack 
6) Settings
7) Chat system
8) Player list system (possibly message, ranks, etc?)
9) Redo datastore system to be secure
]]--

--[[BUGS
1) Mobs clipping into ground if they fall too fast
2) *FIXED Make sure you can not unequip weapons/skills if those skills are playing
3) *FIXED Weapons are not always raycasting/damaging
4) Billboard GUIs get clipped by some parts
]]--

--[[NOTES
------Collision Groups------
RigParts only collides with map (for bodyparts of players)
Equipment collides with NOTHING
Mobs collide with everything except themselves
Everything else collides with everything else

------When creating a new item update these modules------
ReplicatedStorage -> DisplayInfo
ServerStorage -> ModuleData -> Equips/Items (BOTH)

]]--

--[[CACHING
ONLY WAYS TO ADD TO THE CACHE ARE:
1) Mob drops
2) Dropping an item

NON-DROP ITEMS DO NOT NEED A CACHE CHECK, THEY WILL INSTEAD BE VERIFIED VIA MAGNITUDE CHECKS

]]