local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_auto"
	local desc = "[Xel] Death Knight"
	local code = [[
# Common functions.
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

# Class specific functions.
Include(xeltor_blood_functions)
Include(xeltor_frost_functions)
Include(xeltor_unholy_functions)

# Blood
AddIcon specialization=1 help=main
{
	if InCombat() InterruptActions()
	
	if target.InRange(heart_strike) and HasFullControl()
    {
		if BuffStacks(dark_succor_buff) Spell(death_strike)

		if CheckBoxOn(opt_cooldowns) BloodDefaultCdActions()

		if CheckBoxOn(opt_cooldowns) BloodDefaultShortCdActions()

		BloodDefaultMainActions()
	}
}
AddCheckBox(opt_cooldowns "Use cooldowns" default specialization=blood)

# Frost
AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
    if target.InRange(obliterate) and HasFullControl()
    {
		if BuffStacks(dark_succor_buff) Spell(death_strike)
		
		# Cooldown
		if Boss() FrostDefaultCdActions()
		
		# Short Cooldown
		FrostDefaultShortCdActions()
		
		# Main rotation
		FrostDefaultMainActions()
    }
}

# Unholy
AddIcon specialization=3 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	# if 
	if target.DebuffRemaining(virulent_plague_debuff) <= GCD() * 2 and InCombat() and target.InRange(outbreak) and target.HealthPercent() < 100 Spell(outbreak)
	
    if target.InRange(festering_strike) and HasFullControl()
    {
		if not pet.Present() Spell(raise_dead)
		if BuffStacks(dark_succor_buff) Spell(death_strike)
		
		# Cooldown
		if Boss() UnholyDefaultCdActions()

		# Short cooldown
		UnholyDefaultShortCdActions()
		
		# Rotation
		if target.DebuffRemaining(virulent_plague_debuff) <= GCD() * 2 Spell(outbreak)
		UnholyDefaultMainActions()
	}
}

# Common functions.
AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } or { Enemies(tagged=1) >= 6 and target.Classification(elite) }
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(mind_freeze) Spell(mind_freeze)
		if not target.Classification(worldboss)
		{
			if target.InRange(asphyxiate) Spell(asphyxiate)
			# if target.InRange(strangulate) Spell(strangulate)
			if target.Distance(less 12) Spell(blinding_sleet)
			if target.Distance(less 8) Spell(arcane_torrent_runicpower)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}
]]
	OvaleScripts:RegisterScript("DEATHKNIGHT", "all", name, desc, code, "script")
end
