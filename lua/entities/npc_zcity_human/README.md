# Z-City Human NPC

The `npc_zcity_human` NPC uses Z-City's existing systems:

- Z-City appearance models, clothes, facemaps, accessories, and bodygroups
- Z-City organism and wound/bleeding health state
- Z-City inventory and loot data
- Z-City SWEP weapons, medkits, and grenades
- Z-City armor and ragdoll behavior hooks

The NPC is available in the Garry's Mod NPC spawn menu under **Z-City**.

## Spawn

```lua
lua_run local npc=ents.Create("npc_zcity_human") npc:SetPos(player.GetAll()[1]:GetEyeTrace().HitPos) npc:Spawn()
```
