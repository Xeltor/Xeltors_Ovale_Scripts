local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "presdec_restoration"
	local desc = "[Presdec] Shaman: Restoration"
	local code = [[
Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)

Define(flame_shock 188838)
    SpellInfo(flame_shock cd=6)
    SpellAddTargetDebuff(flame_shock_debuff flame_shock=18)
Define(flame_shock_debuff 188838)
	SpellInfo(flame_shock_debuff duration=21 haste=spell tick=3)	
Define(lava_burst 51505)
	SpellInfo(lava_burst cd=8 travel_time=1)
	SpellRequire(lava_burst cd 0=buff,lava_burst_no_cooldown_buff)
	SpellAddBuff(lava_burst lava_surge_buff=0)
Define(lava_surge_buff 77756)
	SpellInfo(lava_surge_buff duration=10)
Define(lightning_bolt 188196)

AddIcon help=main specialization=3
{
	if target.InRange(lightning_bolt) and HasFullControl() and InCombat()
    {
		# Default rotation
		if StandingStill() RestoDpsDefaultMainActions()
		
		#lava_burst,moving=1
		if not StandingStill() and Enemies(tagged=1) == 1 Spell(lava_burst)
		#flame_shock,moving=1,target_if=refreshable
		if not StandingStill() and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
		#flame_shock,moving=1
		if not StandingStill() and Enemies(tagged=1) == 1 Spell(flame_shock)
	}
}

AddFunction RestoDpsDefaultMainActions
{
    if not target.DebuffPresent(flame_shock_debuff 2) Spell(flame_shock)
    unless target.DebuffPresent(flame_shock_debuff ) >=3 and BuffPresent(lava_surge_buff) Spell(lava_burst)
    unless target.DebuffPresent(flame_shock_debuff ) >=3 and SpellCooldown(lightning_bolt) < GCDRemaining() Spell(lava_burst)
    unless target.DebuffPresent(flame_shock_debuff ) >=3 and SpellCooldown(lava_burst) < GCDRemaining() Spell(lightning_bolt)
}

AddFunction StandingStill
{
	{Speed() == 0}
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "restoration", name, desc, code, "script")
end
