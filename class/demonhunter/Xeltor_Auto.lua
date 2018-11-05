local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_auto"
	local desc = "[Xel] Demon Hunter"
	local code = [[
# Common functions.
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)

# Class specific functions.
# Include(xeltor_havoc_functions)
# Include(xeltor_vengeance_functions)

# Havoc
AddIcon specialization=1 help=main
{
	if InCombat() InterruptActions()
	
	if target.InRange(chaos_strike) and HasFullControl()
	{
		# Cooldowns
		# if Boss() HavocCooldownCdActions()
		
		# Short Cooldowns
		# HavocDefaultShortCdActions()
		
		# Default Actions
		# HavocDefaultMainActions()
	}
	
	# if InCombat() and not target.InRange(chaos_strike) and Falling() and not BuffPresent(glide_buff) Spell(glide)
}

# Vengeance
AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
    if target.InRange(shear) and HasFullControl()
    {
		# Cooldown
		# if CheckBoxOn(opt_cooldowns) VengeanceDefaultCdActions()
		
		# Short Cooldown
		# VengeanceDefaultShortCdActions()
		
		# Main rotation
		# VengeanceDefaultMainActions()
    }
	
	if InCombat() and not target.InRange(shear) and target.InRange(felblade) and Falling() Spell(felblade)
	# if InCombat() and not target.InRange(chaos_strike) and Falling() and not BuffPresent(glide_buff) Spell(glide)
}
AddCheckBox(opt_cooldowns "Use cooldowns" default specialization=vengeance)

# Common functions.
AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(consume_magic) and target.IsInterruptible() Spell(consume_magic)
		if target.InRange(fel_eruption) and not target.Classification(worldboss) Spell(fel_eruption)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_dh)
		if target.Distance(less 8) and not target.Classification(worldboss) Spell(chaos_nova)
		# if target.InRange(imprison) and not target.Classification(worldboss) and target.CreatureType(Demon Humanoid Beast) Spell(imprison)
		if target.InRange(shear)
		{
			if target.IsInterruptible() and not target.Classification(worldboss) and not SigilCharging(silence misery chains) and target.RemainingCastTime() >= 2 - Talent(quickened_sigils_talent) + GCDRemaining() Spell(sigil_of_silence)
			if not target.Classification(worldboss) and not SigilCharging(silence misery chains) and target.RemainingCastTime() >= 2 - Talent(quickened_sigils_talent) + GCDRemaining() Spell(sigil_of_misery)
			if not target.Classification(worldboss) and not SigilCharging(silence misery chains) and target.RemainingCastTime() >= 2 - Talent(quickened_sigils_talent) + GCDRemaining() Spell(sigil_of_chains)
		}
	}
}
]]
	OvaleScripts:RegisterScript("DEMONHUNTER", "all", name, desc, code, "script")
end
