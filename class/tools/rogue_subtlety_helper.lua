local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "ROGUESHANKY"
	local desc = "[Xel][7.x] Spellhelper: Shanky (Subtlety)"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_backstab) # Backstab
	Texture(ability_rogue_shadowstrike) # Shadowstrike
	Texture(ability_rogue_eviscerate) # Eviscerate
	Texture(ability_rogue_nightblade) # Nightblade
	Texture(ability_rogue_shurikenstorm) # Shuriken Storm
	Texture(ability_kick) # Kick
	Texture(ability_rogue_kidneyshot) # Kidney Shot
	Texture(ability_cheapshot) # Cheap Shot
	Texture(spell_shadow_mindsteal) # Blind

	# Buffs
	Texture(ability_stealth) # Stealth
	Texture(ability_rogue_shadowstep) # Shadowstep
	Texture(spell_shadow_rune) # Symbols of Death
	Texture(ability_rogue_crimsonvial) # Crimson Vial
	Texture(ability_rogue_tricksofthetrade) # Tricks of the Trade
	Texture(ability_rogue_shadowdance) # Shadow Dance
	Texture(ability_vanish) # Vanish
	Texture(inv_knife_1h_grimbatolraid_d_03) # Shadow Blades

	# Artifact
	Texture(inv_knife_1h_artifactfangs_d_01) # Goremaw's Bite
	
	# Talents
	Texture(ability_ironmaidens_convulsiveshadows) # Gloomblade (T1) (Replaces Backstab)
	Texture(ability_rogue_envelopingshadows) # Enveloping Shadows (T6)
	Texture(achievement_bg_killingblow_berserker) # Marked for Death (T7)
	Texture(spell_rogue_deathfromabove) # Death from Above (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
	
	### Required symbols
	# ambush
	# anticipation_buff
	# anticipation_talent
	# arcane_torrent_energy
	# archmages_greater_incandescence_agi_buff
	# backstab
	# berserking
	# blood_fury_ap
	# cheap_shot
	# crimson_tempest
	# deadly_poison
	# deadly_throw
	# death_from_above
	# death_from_above_talent
	# draenic_agility_potion
	# eviscerate
	# fan_of_knives
	# find_weakness_debuff
	# garrote_debuff
	# hemorrhage
	# hemorrhage_debuff
	# honor_among_thieves_cooldown_buff
	# kick
	# kidney_shot
	# lethal_poison_buff
	# marked_for_death
	# marked_for_death_talent
	# master_of_subtlety_buff
	# premeditation
	# preparation
	# quaking_palm
	# rupture
	# rupture_debuff
	# shadow_dance
	# shadow_dance_buff
	# shadow_focus_talent
	# shadow_reflection
	# shadow_reflection_buff
	# shadow_reflection_talent
	# shadowmeld
	# shadowstep
	# shuriken_toss
	# slice_and_dice
	# slice_and_dice_buff
	# stealth
	# subterfuge_buff
	# subterfuge_talent
	# vanish
	# vanish_buff
}
]]

	OvaleScripts:RegisterScript("ROGUE", "subtlety", name, desc, code, "script")
end
