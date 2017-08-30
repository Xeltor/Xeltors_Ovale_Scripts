local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_guardian"
	local desc = "[Xel][7.1] Druid: Guardian"
	local code = [[
# Based on SimulationCraft profile "Druid_Guardian_T19P".
#	class=druid
#	spec=guardian
#	talents=3323323
	
Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

Define(travel_form 783)
Define(travel_form_buff 783)

# Guardian
AddIcon specialization=3 help=main
{
	# Pre-combat stuff
	if not mounted() and HealthPercent() > 1
	{
		#mark_of_the_wild,if=!aura.str_agi_int.up
		# if not BuffPresent(str_agi_int_buff any=1) Spell(mark_of_the_wild)
		# CHANGE: Cast Healing Touch to gain Bloodtalons buff if less than 20s remaining on the buff.
		#healing_touch,if=talent.bloodtalons.enabled
		#if Talent(bloodtalons_talent) Spell(healing_touch)
		# if Talent(bloodtalons_talent) and BuffRemaining(bloodtalons_buff) < 20 and not InCombat() and Speed() == 0 Spell(healing_touch)
		if target.Present() and target.Exists() and not target.IsFriend()
		{
			#bear_form
			if not BuffPresent(bear_form) Spell(bear_form)
		}
	}
	
	# Interrupt
	if InCombat() InterruptActions()
	
	# Rotation
	if target.InRange(mangle) and HasFullControl() and target.Present()
	{
		# AOE for threat!
		if target.DebuffExpires(thrash_bear_debuff) Spell(thrash_bear)
		
		# Cooldowns
		GuardianDefaultCdActions()
		
		# Short Cooldowns
		GuardianDefaultShortCdActions()
		
		# Default Actions
		GuardianDefaultMainActions()
	}
	
	if InCombat() and target.Present() and not target.IsFriend() and not target.InRange(mangle) and target.InRange(wild_charge) and { TimeInCombat() < 6 or Falling() } Spell(wild_charge)
	Travel()
}
# AddCheckBox(aoe "AoE 3+")

# Travel!
AddFunction Travel
{
	if not BuffPresent(travel_form) and not Indoors() and wet() Spell(travel_form)
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(skull_bash) Spell(skull_bash)
		if not target.Classification(worldboss)
		{
			if target.InRange(mighty_bash) Spell(mighty_bash)
			if target.Distance(less 18) Spell(typhoon)
			if target.InRange(maim) Spell(maim)
			if target.InRange(maim) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction GuardianDefaultMainActions
{
	#ironfur,if=buff.ironfur.down|rage.deficit<25
	if BuffExpires(ironfur_buff) or RageDeficit() < 25 Spell(ironfur)
	#frenzied_regeneration,if=!ticking&incoming_damage_6s%health.max>0.25+(2-charges_fractional)*0.15
	if not BuffPresent(frenzied_regeneration_buff) and IncomingDamage(6) / MaxHealth() > 0.25 + { 2 - Charges(frenzied_regeneration count=0) } * 0.15 Spell(frenzied_regeneration)
	#pulverize,cycle_targets=1,if=buff.pulverize.down
	if BuffExpires(pulverize_buff) and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) Spell(pulverize)
	#mangle
	Spell(mangle)
	#pulverize,cycle_targets=1,if=buff.pulverize.remains<gcd
	if BuffRemaining(pulverize_buff) < GCD() and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) Spell(pulverize)
	#thrash_bear,if=active_enemies>=2
	if Enemies(tagged=1) >= 2 Spell(thrash_bear)
	#pulverize,cycle_targets=1,if=buff.pulverize.remains<3.6
	if BuffRemaining(pulverize_buff) < 3.6 and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) Spell(pulverize)
	#thrash_bear,if=talent.pulverize.enabled&buff.pulverize.remains<3.6
	if Talent(pulverize_talent) and BuffRemaining(pulverize_buff) < 3.6 Spell(thrash_bear)
	#moonfire,cycle_targets=1,if=!ticking
	if not target.DebuffPresent(moonfire_debuff) Spell(moonfire)
	#moonfire,cycle_targets=1,if=remains<3.6
	if target.DebuffRemaining(moonfire_debuff) < 3.6 Spell(moonfire)
	#moonfire,cycle_targets=1,if=remains<7.2
	if target.DebuffRemaining(moonfire_debuff) < 7.2 Spell(moonfire)
	#moonfire
	Spell(moonfire)
}

AddFunction GuardianDefaultMainPostConditions
{
}

AddFunction GuardianDefaultShortCdActions
{
	#auto_attack
	# GuardianGetInMeleeRange()
	#barkskin
	Spell(barkskin)
	#bristling_fur,if=buff.ironfur.remains<2&rage<40
	if BuffRemaining(ironfur_buff) < 2 and Rage() < 40 Spell(bristling_fur)

	unless { BuffExpires(ironfur_buff) or RageDeficit() < 25 } and Spell(ironfur) or not BuffPresent(frenzied_regeneration_buff) and IncomingDamage(6) / MaxHealth() > 0.25 + { 2 - Charges(frenzied_regeneration count=0) } * 0.15 and Spell(frenzied_regeneration) or BuffExpires(pulverize_buff) and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Spell(mangle) or BuffRemaining(pulverize_buff) < GCD() and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize)
	{
		#lunar_beam
		Spell(lunar_beam)
	}
}

AddFunction GuardianDefaultShortCdPostConditions
{
	{ BuffExpires(ironfur_buff) or RageDeficit() < 25 } and Spell(ironfur) or not BuffPresent(frenzied_regeneration_buff) and IncomingDamage(6) / MaxHealth() > 0.25 + { 2 - Charges(frenzied_regeneration count=0) } * 0.15 and Spell(frenzied_regeneration) or BuffExpires(pulverize_buff) and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Spell(mangle) or BuffRemaining(pulverize_buff) < GCD() and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Enemies(tagged=1) >= 2 and Spell(thrash_bear) or BuffRemaining(pulverize_buff) < 3.6 and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Talent(pulverize_talent) and BuffRemaining(pulverize_buff) < 3.6 and Spell(thrash_bear) or not target.DebuffPresent(moonfire_debuff) and Spell(moonfire) or target.DebuffRemaining(moonfire_debuff) < 3.6 and Spell(moonfire) or target.DebuffRemaining(moonfire_debuff) < 7.2 and Spell(moonfire) or Spell(moonfire)
}

AddFunction GuardianDefaultCdActions
{
	#skull_bash
	# GuardianInterruptActions()
	#blood_fury
	Spell(blood_fury_apsp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_energy)
	#use_item,slot=trinket2
	# GuardianUseItemActions()

	unless { BuffExpires(ironfur_buff) or RageDeficit() < 25 } and Spell(ironfur) or not BuffPresent(frenzied_regeneration_buff) and IncomingDamage(6) / MaxHealth() > 0.25 + { 2 - Charges(frenzied_regeneration count=0) } * 0.15 and Spell(frenzied_regeneration) or BuffExpires(pulverize_buff) and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Spell(mangle) or BuffRemaining(pulverize_buff) < GCD() and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Spell(lunar_beam)
	{
		#incarnation
		Spell(incarnation_son_of_ursoc)
	}
}

AddFunction GuardianDefaultCdPostConditions
{
	{ BuffExpires(ironfur_buff) or RageDeficit() < 25 } and Spell(ironfur) or not BuffPresent(frenzied_regeneration_buff) and IncomingDamage(6) / MaxHealth() > 0.25 + { 2 - Charges(frenzied_regeneration count=0) } * 0.15 and Spell(frenzied_regeneration) or BuffExpires(pulverize_buff) and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Spell(mangle) or BuffRemaining(pulverize_buff) < GCD() and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Spell(lunar_beam) or Enemies(tagged=1) >= 2 and Spell(thrash_bear) or BuffRemaining(pulverize_buff) < 3.6 and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or Talent(pulverize_talent) and BuffRemaining(pulverize_buff) < 3.6 and Spell(thrash_bear) or not target.DebuffPresent(moonfire_debuff) and Spell(moonfire) or target.DebuffRemaining(moonfire_debuff) < 3.6 and Spell(moonfire) or target.DebuffRemaining(moonfire_debuff) < 7.2 and Spell(moonfire) or Spell(moonfire)
}

### actions.precombat

AddFunction GuardianPrecombatMainActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=azshari_salad
	#bear_form
	# Spell(bear_form)
}

AddFunction GuardianPrecombatMainPostConditions
{
}

AddFunction GuardianPrecombatShortCdActions
{
}

AddFunction GuardianPrecombatShortCdPostConditions
{
	# Spell(bear_form)
}

AddFunction GuardianPrecombatCdActions
{
}

AddFunction GuardianPrecombatCdPostConditions
{
	# Spell(bear_form)
}
]]
	OvaleScripts:RegisterScript("DRUID", "guardian", name, desc, code, "script")
end
