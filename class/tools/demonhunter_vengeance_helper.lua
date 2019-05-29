local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "DMVENGEANCEhelper"
	local desc = "[Xel][7.2] Spellhelper: Vengeance"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_demonhunter_hatefulstrike) # Shear
	Texture(ability_demonhunter_manabreak) # Sever (Shear during Metamorphosis)
	Texture(ability_demonhunter_soulcleave) # Soul Cleave
	Texture(ability_demonhunter_throwglaive) # Throw Glaive
	Texture(ability_demonhunter_immolation) # Immolation Aura
	Texture(ability_demonhunter_sigilofinquisition) # Sigil of Flame
	Texture(ability_demonhunter_fierybrand) # Fiery Brand
	Texture(ability_demonhunter_infernalstrike1) # Infernal Strike
	
	# Cast interrupters
	Texture(ability_demonhunter_consumemagic) # Consume Magic
	Texture(ability_demonhunter_sigilofsilence) # Sigil of Silence
	Texture(ability_demonhunter_sigilofmisery) # Sigil of Misery
	Texture(ability_demonhunter_imprison) # Imprison

	# Buffs
	Texture(ability_demonhunter_demonspikes) # Demon Spikes
	Texture(ability_demonhunter_empowerwards) # Empower Wards
	Texture(ability_demonhunter_metamorphasistank) # Metamorphosis
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro

	# Talents
	Texture(ability_demonhunter_felblade) # Felblade (T3)
	Texture(ability_bossfellord_felspike) # Fel Eruption (T3) (Used as interrupt)
	Texture(ability_creature_felsunder) # Fracture (T4)
	Texture(ability_demonhunter_sigilofchains) # Sigil of Chains (T5) (Used as interrupt)
	Texture(ability_demonhunter_feldevastation) # Fel Devastation (T6)
	Texture(inv_icon_shadowcouncilorb_purple) # Spirit Bomb (T6)
	Texture(ability_demonhunter_netherbond) # Nether Bond (T7)
	Texture(inv_glaive_1h_artifactaldrochi_d_05) # Soul Barrier (T7)

	# Racials
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_ambush) # Shadowmeld (Night elf)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end
