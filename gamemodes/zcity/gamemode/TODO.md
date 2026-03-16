- [x] Criar convar `zb_karma_enabled` em shared.lua (default 1)
- [x] Editar sv_guilt.lua: IsKarmaEnabled() = convar:GetBool(); early return no GuiltReg se disabled

# Hide and Seek Sub-Gamemode

## Status: [ ] In Progress

## Steps:
- [x] 1. Create gamemodes/zcity/gamemode/modes/hideandseek/shared.lua with MODE table
  - name="hideandseek", Chance=8, PrintName="Hide & Seek"
  - start_time=30, end_time=5, ROUND_TIME=240
  - RoundStart(): Balance teams (hiders team 0, seekers team 1), hiders spawn invisible/frozen, seekers delayed 30s with loadout
  - Timer 30s: Unfreeze hiders, spawn seekers with random firearm (e.g. ak74/mp5) + ammo + grenade + vest/helmet
  - RoundThink(): Check wins (seekers kill all hiders → seek win; time up → hide win)
  - EndRound(): Cleanup invis/freeze
  - Integrate CanSpawn, GetTeamSpawn, guilt/karma

- [ ] 2. Implement hider invisibility (ply:SetMaterial("models/debug/debugwhite"); net to clients for render suppression?)
- [ ] 3. Seeker loadout: hg.CreateInv + Give weapons/ammo/vest/helmet random
- [ ] 4. Test: zb_rerollchances; admin setmode hideandseek; verify phases, balance, UI

## Notes:
- Min 4 players (auto-balance).
- Weapons: lua/weapons/weapon_ak74.lua etc.
- Client HUD via cl_init.lua CurrentRound().name

