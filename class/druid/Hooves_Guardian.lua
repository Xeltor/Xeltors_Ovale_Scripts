local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "hooves_guardian"
	local desc = "[Hooves][7.1] Druid: Guardian"
	local code = [[
# Based on SimulationCraft profile "Druid_Guardian_T19P".
#	class=druid
#	spec=guardian
#	talents=3323323
	
Include(ovale_common)

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
			#if not BuffPresent(bear_form) Spell(bear_form)
		}
	}
	
	# Activate cat form when this checkbox is on.
	if CheckBoxOn(catweave) and InCombat() CatWeaving()
	
	# Rotation
	if InCombat() and not Stance(1) Spell(bear_form)
	if Stance(1) and target.InRange(mangle) and HasFullControl() and target.Present()
	{
		# AOE for threat!
		if target.DebuffExpires(thrash_bear_debuff) Spell(thrash_bear)
		if Boss()
		{
			GuardianDefaultCdActions()
		}
	
		# Short Cooldowns
		GuardianDefaultShortCdActions()
	
		# Default Actions
		GuardianDefaultMainActions()
	}
	# Interrupt
	if InCombat() InterruptActions()

	if InCombat() and target.Present() and not target.IsFriend() and not target.InRange(mangle) and target.InRange(wild_charge) and { TimeInCombat() < 6 or Falling() } Spell(wild_charge)
	Travel()
}
	
# AddCheckBox(aoe "AoE 3+")
AddCheckBox(magical "Magical?")
AddCheckBox(catweave "Catweave")
# Travel!
AddFunction Travel
{
	if not BuffPresent(travel_form) and not Indoors() and wet() Spell(travel_form)
}

AddFunction CatWeaving
{
	# Enter catform.
	if TimeToMaxEnergy() <= GCD() and not Stance(2) Spell(cat_form)
	# Low energy drop out of cat form.
	if Energy() < EnergyCost(rake) and not Stance(1) Spell(bear_form)
	
	# Cat rotation.
	if Stance(2) and target.InRange(shred) and HasFullControl() and target.Present()
	{
		if ComboPoints() >= 5 Spell(rip)
		if ComboPoints() < 5 and not target.DebuffPresent(rake_debuff) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) Spell(rake)
		if ComboPoints() < 5 Spell(shred)
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
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
	#frenzied_regeneration,if=incoming_damage_5s%health.max>=0.5|health<=health.max*0.4
	if (IncomingDamage(5) / MaxHealth() >= MaxHealth() * 0.3 or Health() <= MaxHealth() * 0.7  and not BuffPresent(frenzied_regeneration_buff)) Spell(frenzied_regeneration)
	#ironfur,if=(buff.ironfur.up=0)|(buff.gory_fur.up=1)|(rage>=80)
	if (CheckBoxOn(magical))
	{
		if BuffPresent(mark_of_ursol_buff) == 0 or BuffPresent(gory_fur_buff) == 1 or Rage() >= 80 Spell(mark_of_ursol)
	}
	if (CheckBoxOff(magical))
	{
		if BuffPresent(ironfur_buff) == 0 or BuffPresent(gory_fur_buff) == 1 or Rage() >= 80 Spell(ironfur)
	}
	#moonfire,if=buff.incarnation.up=1&dot.moonfire.remains<=4.8
	if BuffPresent(incarnation_son_of_ursoc_buff) == 1 and target.DebuffRemaining(moonfire_debuff) <= 4.8 Spell(moonfire)
	#thrash_bear,if=buff.incarnation.up=1&dot.thrash.remains<=4.5
	if BuffPresent(incarnation_son_of_ursoc_buff) == 1 and target.DebuffRemaining(thrash_bear_debuff) <= 4.5 Spell(thrash_bear)
	#mangle
	Spell(mangle)
	#thrash_bear
	Spell(thrash_bear)
	#pulverize,if=buff.pulverize.up=0|buff.pulverize.remains<=6
	if { BuffPresent(pulverize_buff) == 0 or BuffRemaining(pulverize_buff) <= 6 } and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) Spell(pulverize)
	#moonfire,if=buff.galactic_guardian.up=1&(!ticking|dot.moonfire.remains<=4.8)
	if BuffPresent(galactic_guardian_buff) == 1 and { not target.DebuffPresent(moonfire_debuff) or target.DebuffRemaining(moonfire_debuff) <= 4.8 } Spell(moonfire)
	#moonfire,if=buff.galactic_guardian.up=1
	if BuffPresent(galactic_guardian_buff) == 1 Spell(moonfire)
	#moonfire,if=dot.moonfire.remains<=4.8
	if target.DebuffRemaining(moonfire_debuff) <= 4.8 Spell(moonfire)
	#swipe_bear
	Spell(swipe_bear)
}
AddFunction GuardianDefaultMainPostConditions
{
}
AddFunction GuardianDefaultShortCdActions
{
	#auto_attack
	# GuardianGetInMeleeRange()
	#rage_of_the_sleeper
	Spell(rage_of_the_sleeper)
	#lunar_beam
	#Spell(lunar_beam)
	#unless { IncomingDamage(5) / MaxHealth() >= 0.5 or Health() <= MaxHealth() * 0.7 } and Spell(frenzied_regeneration)
	#{
		#bristling_fur,if=buff.ironfur.stack=1|buff.ironfur.down
		#if BuffStacks(ironfur_buff) == 1 or BuffExpires(ironfur_buff) Spell(bristling_fur)
	#}
}
AddFunction GuardianDefaultShortCdPostConditions
{
	 if IncomingDamage(5) / MaxHealth() >= MaxHealth() * 0.3 or Health() <= MaxHealth() * 0.7 and not BuffPresent(frenzied_regeneration_buff)  Spell(frenzied_regeneration) or {BuffPresent(ironfur_buff) == 0 or BuffPresent(gory_fur_buff) == 1 or Rage() >= 80 } and Spell(ironfur) or BuffPresent(incarnation_son_of_ursoc_buff) == 1 and target.DebuffRemaining(moonfire_debuff) <= 4.8 and Spell(moonfire) or BuffPresent(incarnation_son_of_ursoc_buff) == 1 and target.DebuffRemaining(thrash_bear_debuff) <= 4.5 and Spell(thrash_bear) or Spell(mangle) or Spell(thrash_bear) or { BuffPresent(pulverize_buff) == 0 or BuffRemaining(pulverize_buff) <= 6 } and target.DebuffGain(thrash_bear_debuff) <= BaseDuration(thrash_bear_debuff) and Spell(pulverize) or BuffPresent(galactic_guardian_buff) == 1 and { not target.DebuffPresent(moonfire_debuff) or target.DebuffRemaining(moonfire_debuff) <= 4.8 } and Spell(moonfire) or BuffPresent(galactic_guardian_buff) == 1 and Spell(moonfire) or target.DebuffRemaining(moonfire_debuff) <= 4.8 and Spell(moonfire) or Spell(swipe_bear)
}
AddFunction GuardianDefaultCdActions
{
	#blood_fury
	Spell(blood_fury_apsp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_energy)
	#use_item,slot=trinket2
	# GuardianUseItemActions()
	#incarnation
	#Spell(incarnation_son_of_ursoc)
}
AddFunction GuardianDefaultCdPostConditions
{
	
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
