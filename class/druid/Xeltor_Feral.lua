local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_feral"
	local desc = "[Xel][7.1] Druid: Feral"
	local code = [[
# Based on SimulationCraft profile "Druid_Feral_T18M".
#	class=druid
#	spec=feral
#	talents=3002002

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)


Define(travel_form 783)
Define(travel_form_buff 783)

# Feral
AddIcon specialization=2 help=main
{
	# Pre-combat stuff
	if not mounted() and not BuffPresent(travel_form)
	{
		#mark_of_the_wild,if=!aura.str_agi_int.up
		# if not BuffPresent(str_agi_int_buff any=1) Spell(mark_of_the_wild)
		# CHANGE: Cast Healing Touch to gain Bloodtalons buff if less than 20s remaining on the buff.
		#healing_touch,if=talent.bloodtalons.enabled
		#if Talent(bloodtalons_talent) Spell(healing_touch)
		# if Talent(bloodtalons_talent) and BuffRemaining(bloodtalons_buff) < 20 and not InCombat() and Speed() == 0 Spell(healing_touch)
		if target.Present() and target.Exists() and not target.IsFriend()
		{
			#cat_form
			if not BuffPresent(cat_form) Spell(cat_form)
			#prowl
			if not (BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff)) and not InCombat() Spell(prowl)
		}
	}
	
	# Interrupt
	if InCombat() and not mounted() and not BuffPresent(travel_form) InterruptActions()
	
	# Rotation
	if target.InRange(rake) and HasFullControl() and target.Present()
	{
		# Cooldowns
		if Boss()
		{
			FeralDefaultCdActions()
		}
		
		# Short Cooldowns
		FeralDefaultShortCdActions()
		
		# Default Actions
		FeralDefaultMainActions()
	}
	if InCombat() and target.Present() and not target.IsFriend() and not target.InRange(rake) and target.InRange(wild_charge) and { TimeInCombat() < 6 or Falling() } Spell(wild_charge)
	Travel()
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

# Travel!
AddFunction Travel
{
	if not InCombat() and Speed() > 0 and {not target.Present() or target.IsFriend()}
	{
		if not BuffPresent(travel_form) and not Indoors() and { Wet() or Falling() } Spell(travel_form)
	}
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
			if target.InRange(maim) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction FeralDefaultMainActions
{
	#cat_form
	# Spell(cat_form)
	#rake,if=buff.prowl.up|buff.shadowmeld.up
	if BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) Spell(rake)
	#ferocious_bite,cycle_targets=1,if=dot.rip.ticking&dot.rip.remains<3&target.time_to_die>3&(target.health.pct<25|talent.sabertooth.enabled)
	if target.DebuffPresent(rip_debuff) and target.DebuffRemaining(rip_debuff) < 3 and target.TimeToDie() > 3 and { target.HealthPercent() < 25 or Talent(sabertooth_talent) } Spell(ferocious_bite)
	#regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&(combo_points>=5|buff.predatory_swiftness.remains<1.5|(talent.bloodtalons.enabled&combo_points=2&buff.bloodtalons.down&cooldown.ashamanes_frenzy.remains<gcd)|(talent.elunes_guidance.enabled&((cooldown.elunes_guidance.remains<gcd&combo_points=0)|(buff.elunes_guidance.up&combo_points>=4))))
	if Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and { ComboPoints() >= 5 or BuffRemaining(predatory_swiftness_buff) < 1.5 or Talent(bloodtalons_talent) and ComboPoints() == 2 and BuffExpires(bloodtalons_buff) and SpellCooldown(ashamanes_frenzy) < GCD() or Talent(elunes_guidance_talent) and { SpellCooldown(elunes_guidance) < GCD() and ComboPoints() == 0 or BuffPresent(elunes_guidance_buff) and ComboPoints() >= 4 } } Spell(regrowth)
	#call_action_list,name=sbt_opener,if=talent.sabertooth.enabled&time<20
	if Talent(sabertooth_talent) and TimeInCombat() < 20 FeralSbtOpenerMainActions()

	unless Talent(sabertooth_talent) and TimeInCombat() < 20 and FeralSbtOpenerMainPostConditions()
	{
		#regrowth,if=equipped.ailuro_pouncers&talent.bloodtalons.enabled&buff.predatory_swiftness.stack>1&buff.bloodtalons.down
		if HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and BuffStacks(predatory_swiftness_buff) > 1 and BuffExpires(bloodtalons_buff) Spell(regrowth)
		#call_action_list,name=finisher
		FeralFinisherMainActions()

		unless FeralFinisherMainPostConditions()
		{
			#call_action_list,name=generator
			FeralGeneratorMainActions()
		}
	}
}

AddFunction FeralDefaultMainPostConditions
{
	Talent(sabertooth_talent) and TimeInCombat() < 20 and FeralSbtOpenerMainPostConditions() or FeralFinisherMainPostConditions() or FeralGeneratorMainPostConditions()
}

AddFunction FeralDefaultShortCdActions
{
	unless Spell(cat_form)
	{
		#wild_charge
		# FeralGetInMeleeRange()
		#displacer_beast,if=movement.distance>10
		# if 0 > 10 Spell(displacer_beast)

		unless { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake)
		{
			#auto_attack
			# FeralGetInMeleeRange()
			#potion,name=old_war,if=((buff.berserk.remains>10|buff.incarnation.remains>20)&(target.time_to_die<180|(trinket.proc.all.react&target.health.pct<25)))|target.time_to_die<=40
			#tigers_fury,if=(!buff.clearcasting.react&energy.deficit>=60)|energy.deficit>=80|(t18_class_trinket&buff.berserk.up&buff.tigers_fury.down)
			if not BuffPresent(clearcasting_buff) and EnergyDeficit() >= 60 or EnergyDeficit() >= 80 or HasTrinket(t18_class_trinket) and BuffPresent(berserk_cat_buff) and BuffExpires(tigers_fury_buff) Spell(tigers_fury)

			unless target.DebuffPresent(rip_debuff) and target.DebuffRemaining(rip_debuff) < 3 and target.TimeToDie() > 3 and { target.HealthPercent() < 25 or Talent(sabertooth_talent) } and Spell(ferocious_bite) or Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and { ComboPoints() >= 5 or BuffRemaining(predatory_swiftness_buff) < 1.5 or Talent(bloodtalons_talent) and ComboPoints() == 2 and BuffExpires(bloodtalons_buff) and SpellCooldown(ashamanes_frenzy) < GCD() or Talent(elunes_guidance_talent) and { SpellCooldown(elunes_guidance) < GCD() and ComboPoints() == 0 or BuffPresent(elunes_guidance_buff) and ComboPoints() >= 4 } } and Spell(regrowth)
			{
				#call_action_list,name=sbt_opener,if=talent.sabertooth.enabled&time<20
				if Talent(sabertooth_talent) and TimeInCombat() < 20 FeralSbtOpenerShortCdActions()

				unless Talent(sabertooth_talent) and TimeInCombat() < 20 and FeralSbtOpenerShortCdPostConditions() or HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and BuffStacks(predatory_swiftness_buff) > 1 and BuffExpires(bloodtalons_buff) and Spell(regrowth)
				{
					#call_action_list,name=finisher
					FeralFinisherShortCdActions()

					unless FeralFinisherShortCdPostConditions()
					{
						#call_action_list,name=generator
						FeralGeneratorShortCdActions()
					}
				}
			}
		}
	}
}

AddFunction FeralDefaultShortCdPostConditions
{
	Spell(cat_form) or { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake) or target.DebuffPresent(rip_debuff) and target.DebuffRemaining(rip_debuff) < 3 and target.TimeToDie() > 3 and { target.HealthPercent() < 25 or Talent(sabertooth_talent) } and Spell(ferocious_bite) or Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and { ComboPoints() >= 5 or BuffRemaining(predatory_swiftness_buff) < 1.5 or Talent(bloodtalons_talent) and ComboPoints() == 2 and BuffExpires(bloodtalons_buff) and SpellCooldown(ashamanes_frenzy) < GCD() or Talent(elunes_guidance_talent) and { SpellCooldown(elunes_guidance) < GCD() and ComboPoints() == 0 or BuffPresent(elunes_guidance_buff) and ComboPoints() >= 4 } } and Spell(regrowth) or Talent(sabertooth_talent) and TimeInCombat() < 20 and FeralSbtOpenerShortCdPostConditions() or HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and BuffStacks(predatory_swiftness_buff) > 1 and BuffExpires(bloodtalons_buff) and Spell(regrowth) or FeralFinisherShortCdPostConditions() or FeralGeneratorShortCdPostConditions()
}

AddFunction FeralDefaultCdActions
{
	#dash,if=!buff.cat_form.up
	# if not BuffPresent(cat_form_buff) Spell(dash)

	unless Spell(cat_form)
	{
		#dash,if=movement.distance&buff.displacer_beast.down&buff.wild_charge_movement.down
		# if 0 and BuffExpires(displacer_beast_buff) and True(wild_charge_movement_down) Spell(dash)

		unless { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake)
		{
			#blood_fury
			Spell(blood_fury_apsp)
			#berserking
			Spell(berserking)
			#arcane_torrent
			Spell(arcane_torrent_energy)
			#skull_bash
			# FeralInterruptActions()
			#berserk,if=buff.tigers_fury.up
			if BuffPresent(tigers_fury_buff) Spell(berserk_cat)
			#incarnation,if=cooldown.tigers_fury.remains<gcd
			if SpellCooldown(tigers_fury) < GCD() Spell(incarnation_king_of_the_jungle)
			#use_item,slot=trinket2,if=(buff.tigers_fury.up&(target.time_to_die>trinket.stat.any.cooldown|target.time_to_die<45))|buff.incarnation.remains>20
			# if BuffPresent(tigers_fury_buff) and { target.TimeToDie() > BuffCooldownDuration(trinket_stat_any_buff) or target.TimeToDie() < 45 } or BuffRemaining(incarnation_king_of_the_jungle_buff) > 20 FeralUseItemActions()
			#incarnation,if=energy.time_to_max>1&energy>=35
			if TimeToMaxEnergy() > 1 and Energy() >= 35 Spell(incarnation_king_of_the_jungle)

			unless target.DebuffPresent(rip_debuff) and target.DebuffRemaining(rip_debuff) < 3 and target.TimeToDie() > 3 and { target.HealthPercent() < 25 or Talent(sabertooth_talent) } and Spell(ferocious_bite) or Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and { ComboPoints() >= 5 or BuffRemaining(predatory_swiftness_buff) < 1.5 or Talent(bloodtalons_talent) and ComboPoints() == 2 and BuffExpires(bloodtalons_buff) and SpellCooldown(ashamanes_frenzy) < GCD() or Talent(elunes_guidance_talent) and { SpellCooldown(elunes_guidance) < GCD() and ComboPoints() == 0 or BuffPresent(elunes_guidance_buff) and ComboPoints() >= 4 } } and Spell(regrowth)
			{
				#call_action_list,name=sbt_opener,if=talent.sabertooth.enabled&time<20
				if Talent(sabertooth_talent) and TimeInCombat() < 20 FeralSbtOpenerCdActions()

				unless Talent(sabertooth_talent) and TimeInCombat() < 20 and FeralSbtOpenerCdPostConditions() or HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and BuffStacks(predatory_swiftness_buff) > 1 and BuffExpires(bloodtalons_buff) and Spell(regrowth)
				{
					#call_action_list,name=finisher
					FeralFinisherCdActions()

					unless FeralFinisherCdPostConditions()
					{
						#call_action_list,name=generator
						FeralGeneratorCdActions()
					}
				}
			}
		}
	}
}

AddFunction FeralDefaultCdPostConditions
{
	Spell(cat_form) or { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake) or target.DebuffPresent(rip_debuff) and target.DebuffRemaining(rip_debuff) < 3 and target.TimeToDie() > 3 and { target.HealthPercent() < 25 or Talent(sabertooth_talent) } and Spell(ferocious_bite) or Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and { ComboPoints() >= 5 or BuffRemaining(predatory_swiftness_buff) < 1.5 or Talent(bloodtalons_talent) and ComboPoints() == 2 and BuffExpires(bloodtalons_buff) and SpellCooldown(ashamanes_frenzy) < GCD() or Talent(elunes_guidance_talent) and { SpellCooldown(elunes_guidance) < GCD() and ComboPoints() == 0 or BuffPresent(elunes_guidance_buff) and ComboPoints() >= 4 } } and Spell(regrowth) or Talent(sabertooth_talent) and TimeInCombat() < 20 and FeralSbtOpenerCdPostConditions() or HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and BuffStacks(predatory_swiftness_buff) > 1 and BuffExpires(bloodtalons_buff) and Spell(regrowth) or FeralFinisherCdPostConditions() or FeralGeneratorCdPostConditions()
}

### actions.finisher

AddFunction FeralFinisherMainActions
{
	#pool_resource,for_next=1
	#savage_roar,if=!buff.savage_roar.up&(combo_points=5|(talent.brutal_slash.enabled&spell_targets.brutal_slash>desired_targets&action.brutal_slash.charges>0))
	if not BuffPresent(savage_roar_buff) and { ComboPoints() == 5 or Talent(brutal_slash_talent) and Enemies(tagged=1) > Enemies(tagged=1) and Charges(brutal_slash) > 0 } Spell(savage_roar)
	unless not BuffPresent(savage_roar_buff) and { ComboPoints() == 5 or Talent(brutal_slash_talent) and Enemies(tagged=1) > Enemies(tagged=1) and Charges(brutal_slash) > 0 } and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar)
	{
		#pool_resource,for_next=1
		#thrash_cat,cycle_targets=1,if=remains<=duration*0.3&spell_targets.thrash_cat>=5
		if target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 5 Spell(thrash_cat)
		unless target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 5 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat)
		{
			#pool_resource,for_next=1
			#swipe_cat,if=spell_targets.swipe_cat>=8
			if Enemies(tagged=1) >= 8 Spell(swipe_cat)
			unless Enemies(tagged=1) >= 8 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat)
			{
				#rip,cycle_targets=1,if=(!ticking|(remains<8&target.health.pct>25&!talent.sabertooth.enabled)|persistent_multiplier>dot.rip.pmultiplier)&target.time_to_die-remains>tick_time*4&combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|buff.clearcasting.react|talent.soul_of_the_forest.enabled|!dot.rip.ticking|(dot.rake.remains<1.5&spell_targets.swipe_cat<6))
				if { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) < 8 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) } and target.TimeToDie() - target.DebuffRemaining(rip_debuff) > target.TickTime(rip_debuff) * 4 and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or BuffPresent(clearcasting_buff) or Talent(soul_of_the_forest_talent) or not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rake_debuff) < 1.5 and Enemies(tagged=1) < 6 } Spell(rip)
				#savage_roar,if=(buff.savage_roar.remains<=10.5|(buff.savage_roar.remains<=7.2&!talent.jagged_wounds.enabled))&combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|buff.clearcasting.react|talent.soul_of_the_forest.enabled|!dot.rip.ticking|(dot.rake.remains<1.5&spell_targets.swipe_cat<6))
				if { BuffRemaining(savage_roar_buff) <= 10.5 or BuffRemaining(savage_roar_buff) <= 7.2 and not Talent(jagged_wounds_talent) } and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or BuffPresent(clearcasting_buff) or Talent(soul_of_the_forest_talent) or not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rake_debuff) < 1.5 and Enemies(tagged=1) < 6 } Spell(savage_roar)
				#swipe_cat,if=combo_points=5&(spell_targets.swipe_cat>=6|(spell_targets.swipe_cat>=3&!talent.bloodtalons.enabled))&combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|(talent.moment_of_clarity.enabled&buff.clearcasting.react))
				if ComboPoints() == 5 and { Enemies(tagged=1) >= 6 or Enemies(tagged=1) >= 3 and not Talent(bloodtalons_talent) } and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or Talent(moment_of_clarity_talent) and BuffPresent(clearcasting_buff) } Spell(swipe_cat)
				#ferocious_bite,max_energy=1,cycle_targets=1,if=combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|(talent.moment_of_clarity.enabled&buff.clearcasting.react))
				if Energy() >= EnergyCost(ferocious_bite max=1) and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or Talent(moment_of_clarity_talent) and BuffPresent(clearcasting_buff) } Spell(ferocious_bite)
			}
		}
	}
}

AddFunction FeralFinisherMainPostConditions
{
}

AddFunction FeralFinisherShortCdActions
{
}

AddFunction FeralFinisherShortCdPostConditions
{
	not BuffPresent(savage_roar_buff) and { ComboPoints() == 5 or Talent(brutal_slash_talent) and Enemies(tagged=1) > Enemies(tagged=1) and Charges(brutal_slash) > 0 } and Spell(savage_roar) or not { not BuffPresent(savage_roar_buff) and { ComboPoints() == 5 or Talent(brutal_slash_talent) and Enemies(tagged=1) > Enemies(tagged=1) and Charges(brutal_slash) > 0 } and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar) } and { target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 5 and Spell(thrash_cat) or not { target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 5 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { Enemies(tagged=1) >= 8 and Spell(swipe_cat) or not { Enemies(tagged=1) >= 8 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat) } and { { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) < 8 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) } and target.TimeToDie() - target.DebuffRemaining(rip_debuff) > target.TickTime(rip_debuff) * 4 and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or BuffPresent(clearcasting_buff) or Talent(soul_of_the_forest_talent) or not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rake_debuff) < 1.5 and Enemies(tagged=1) < 6 } and Spell(rip) or { BuffRemaining(savage_roar_buff) <= 10.5 or BuffRemaining(savage_roar_buff) <= 7.2 and not Talent(jagged_wounds_talent) } and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or BuffPresent(clearcasting_buff) or Talent(soul_of_the_forest_talent) or not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rake_debuff) < 1.5 and Enemies(tagged=1) < 6 } and Spell(savage_roar) or ComboPoints() == 5 and { Enemies(tagged=1) >= 6 or Enemies(tagged=1) >= 3 and not Talent(bloodtalons_talent) } and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or Talent(moment_of_clarity_talent) and BuffPresent(clearcasting_buff) } and Spell(swipe_cat) or Energy() >= EnergyCost(ferocious_bite max=1) and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or Talent(moment_of_clarity_talent) and BuffPresent(clearcasting_buff) } and Spell(ferocious_bite) } } }
}

AddFunction FeralFinisherCdActions
{
}

AddFunction FeralFinisherCdPostConditions
{
	not BuffPresent(savage_roar_buff) and { ComboPoints() == 5 or Talent(brutal_slash_talent) and Enemies(tagged=1) > Enemies(tagged=1) and Charges(brutal_slash) > 0 } and Spell(savage_roar) or not { not BuffPresent(savage_roar_buff) and { ComboPoints() == 5 or Talent(brutal_slash_talent) and Enemies(tagged=1) > Enemies(tagged=1) and Charges(brutal_slash) > 0 } and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar) } and { target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 5 and Spell(thrash_cat) or not { target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 5 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { Enemies(tagged=1) >= 8 and Spell(swipe_cat) or not { Enemies(tagged=1) >= 8 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat) } and { { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) < 8 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) } and target.TimeToDie() - target.DebuffRemaining(rip_debuff) > target.TickTime(rip_debuff) * 4 and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or BuffPresent(clearcasting_buff) or Talent(soul_of_the_forest_talent) or not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rake_debuff) < 1.5 and Enemies(tagged=1) < 6 } and Spell(rip) or { BuffRemaining(savage_roar_buff) <= 10.5 or BuffRemaining(savage_roar_buff) <= 7.2 and not Talent(jagged_wounds_talent) } and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or BuffPresent(clearcasting_buff) or Talent(soul_of_the_forest_talent) or not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rake_debuff) < 1.5 and Enemies(tagged=1) < 6 } and Spell(savage_roar) or ComboPoints() == 5 and { Enemies(tagged=1) >= 6 or Enemies(tagged=1) >= 3 and not Talent(bloodtalons_talent) } and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or Talent(moment_of_clarity_talent) and BuffPresent(clearcasting_buff) } and Spell(swipe_cat) or Energy() >= EnergyCost(ferocious_bite max=1) and ComboPoints() == 5 and { TimeToMaxEnergy() < 1 or BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) or BuffPresent(elunes_guidance_buff) or SpellCooldown(tigers_fury) < 3 or ArmorSetBonus(T18 4) or Talent(moment_of_clarity_talent) and BuffPresent(clearcasting_buff) } and Spell(ferocious_bite) } } }
}

### actions.generator

AddFunction FeralGeneratorMainActions
{
	#brutal_slash,if=spell_targets.brutal_slash>desired_targets&combo_points<5
	#pool_resource,if=talent.elunes_guidance.enabled&combo_points=0&energy<action.ferocious_bite.cost+25-energy.regen*cooldown.elunes_guidance.remains
	unless Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() < PowerCost(ferocious_bite) + 25 - EnergyRegenRate() * SpellCooldown(elunes_guidance)
	{
		#pool_resource,for_next=1
		#thrash_cat,if=talent.brutal_slash.enabled&spell_targets.thrash_cat>=9
		if Talent(brutal_slash_talent) and Enemies(tagged=1) >= 9 Spell(thrash_cat)
		unless Talent(brutal_slash_talent) and Enemies(tagged=1) >= 9 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat)
		{
			#pool_resource,for_next=1
			#swipe_cat,if=spell_targets.swipe_cat>=6
			if Enemies(tagged=1) >= 6 Spell(swipe_cat)
			unless Enemies(tagged=1) >= 6 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat)
			{
				#pool_resource,for_next=1
				#rake,cycle_targets=1,if=combo_points<5&(!ticking|(!talent.bloodtalons.enabled&remains<duration*0.3)|(talent.bloodtalons.enabled&buff.bloodtalons.up&(!talent.soul_of_the_forest.enabled&remains<=7|remains<=5)&persistent_multiplier>dot.rake.pmultiplier*0.80))&target.time_to_die-remains>tick_time
				if ComboPoints() < 5 and { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 or Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and { not Talent(soul_of_the_forest_talent) and target.DebuffRemaining(rake_debuff) <= 7 or target.DebuffRemaining(rake_debuff) <= 5 } and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 } and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) Spell(rake)
				unless ComboPoints() < 5 and { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 or Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and { not Talent(soul_of_the_forest_talent) and target.DebuffRemaining(rake_debuff) <= 7 or target.DebuffRemaining(rake_debuff) <= 5 } and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 } and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake)
				{
					#moonfire_cat,cycle_targets=1,if=combo_points<5&remains<=4.2&target.time_to_die-remains>tick_time*2
					if ComboPoints() < 5 and target.DebuffRemaining(moonfire_cat_debuff) <= 4.2 and target.TimeToDie() - target.DebuffRemaining(moonfire_cat_debuff) > target.TickTime(moonfire_cat_debuff) * 2 Spell(moonfire_cat)
					#pool_resource,for_next=1
					#thrash_cat,cycle_targets=1,if=remains<=duration*0.3&spell_targets.swipe_cat>=2
					if target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 2 Spell(thrash_cat)
					unless target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 2 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat)
					{
						#brutal_slash,if=combo_points<5&((raid_event.adds.exists&raid_event.adds.in>(1+max_charges-charges_fractional)*15)|(!raid_event.adds.exists&(charges_fractional>2.66&time>10)))
						
						#swipe_cat,if=combo_points<5&spell_targets.swipe_cat>=3
						if ComboPoints() < 5 and Enemies(tagged=1) >= 3 Spell(swipe_cat)
						#shred,if=combo_points<5&(spell_targets.swipe_cat<3|talent.brutal_slash.enabled)
						if ComboPoints() < 5 and { Enemies(tagged=1) < 3 or Talent(brutal_slash_talent) } Spell(shred)
					}
				}
			}
		}
	}
}

AddFunction FeralGeneratorMainPostConditions
{
}

AddFunction FeralGeneratorShortCdActions
{
	unless Enemies(tagged=1) > Enemies(tagged=1) and ComboPoints() < 5 and Spell(brutal_slash)
	{
		#ashamanes_frenzy,if=combo_points<=2&buff.elunes_guidance.down&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(buff.savage_roar.up|!talent.savage_roar.enabled)
		if ComboPoints() <= 2 and BuffExpires(elunes_guidance_buff) and { BuffPresent(bloodtalons_buff) or not Talent(bloodtalons_talent) } and { BuffPresent(savage_roar_buff) or not Talent(savage_roar_talent) } Spell(ashamanes_frenzy)
		#pool_resource,if=talent.elunes_guidance.enabled&combo_points=0&energy<action.ferocious_bite.cost+25-energy.regen*cooldown.elunes_guidance.remains
		unless Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() < PowerCost(ferocious_bite) + 25 - EnergyRegenRate() * SpellCooldown(elunes_guidance)
		{
			#elunes_guidance,if=talent.elunes_guidance.enabled&combo_points=0&energy>=action.ferocious_bite.cost+25
			if Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() >= PowerCost(ferocious_bite) + 25 Spell(elunes_guidance)
		}
	}
}

AddFunction FeralGeneratorShortCdPostConditions
{
	Enemies(tagged=1) > Enemies(tagged=1) and ComboPoints() < 5 and Spell(brutal_slash) or not { Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() < PowerCost(ferocious_bite) + 25 - EnergyRegenRate() * SpellCooldown(elunes_guidance) } and { Talent(brutal_slash_talent) and Enemies(tagged=1) >= 9 and Spell(thrash_cat) or not { Talent(brutal_slash_talent) and Enemies(tagged=1) >= 9 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { Enemies(tagged=1) >= 6 and Spell(swipe_cat) or not { Enemies(tagged=1) >= 6 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat) } and { ComboPoints() < 5 and { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 or Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and { not Talent(soul_of_the_forest_talent) and target.DebuffRemaining(rake_debuff) <= 7 or target.DebuffRemaining(rake_debuff) <= 5 } and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 } and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) and Spell(rake) or not { ComboPoints() < 5 and { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 or Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and { not Talent(soul_of_the_forest_talent) and target.DebuffRemaining(rake_debuff) <= 7 or target.DebuffRemaining(rake_debuff) <= 5 } and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 } and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake) } and { ComboPoints() < 5 and target.DebuffRemaining(moonfire_cat_debuff) <= 4.2 and target.TimeToDie() - target.DebuffRemaining(moonfire_cat_debuff) > target.TickTime(moonfire_cat_debuff) * 2 and Spell(moonfire_cat) or target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 2 and Spell(thrash_cat) or not { target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 2 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { ComboPoints() < 5 and { False(raid_event_adds_exists) and 600 > { 1 + SpellMaxCharges(brutal_slash) - Charges(brutal_slash count=0) } * 15 or not False(raid_event_adds_exists) and Charges(brutal_slash count=0) > 2.66 and TimeInCombat() > 10 } and Spell(brutal_slash) or ComboPoints() < 5 and Enemies(tagged=1) >= 3 and Spell(swipe_cat) or ComboPoints() < 5 and { Enemies(tagged=1) < 3 or Talent(brutal_slash_talent) } and Spell(shred) } } } } }
}

AddFunction FeralGeneratorCdActions
{
	unless Enemies(tagged=1) > Enemies(tagged=1) and ComboPoints() < 5 and Spell(brutal_slash) or ComboPoints() <= 2 and BuffExpires(elunes_guidance_buff) and { BuffPresent(bloodtalons_buff) or not Talent(bloodtalons_talent) } and { BuffPresent(savage_roar_buff) or not Talent(savage_roar_talent) } and Spell(ashamanes_frenzy)
	{
		#pool_resource,if=talent.elunes_guidance.enabled&combo_points=0&energy<action.ferocious_bite.cost+25-energy.regen*cooldown.elunes_guidance.remains
		unless Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() < PowerCost(ferocious_bite) + 25 - EnergyRegenRate() * SpellCooldown(elunes_guidance)
		{
			unless Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() >= PowerCost(ferocious_bite) + 25 and Spell(elunes_guidance)
			{
				#pool_resource,for_next=1
				#thrash_cat,if=talent.brutal_slash.enabled&spell_targets.thrash_cat>=9
				unless Talent(brutal_slash_talent) and Enemies(tagged=1) >= 9 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat)
				{
					#pool_resource,for_next=1
					#swipe_cat,if=spell_targets.swipe_cat>=6
					unless Enemies(tagged=1) >= 6 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat)
					{
						#shadowmeld,if=combo_points<5&energy>=action.rake.cost&dot.rake.pmultiplier<2.1&buff.tigers_fury.up&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(!talent.incarnation.enabled|cooldown.incarnation.remains>18)&!buff.incarnation.up
						if ComboPoints() < 5 and Energy() >= PowerCost(rake) and target.DebuffPersistentMultiplier(rake_debuff) < 2.1 and BuffPresent(tigers_fury_buff) and { BuffPresent(bloodtalons_buff) or not Talent(bloodtalons_talent) } and { not Talent(incarnation_talent) or SpellCooldown(incarnation_king_of_the_jungle) > 18 } and not BuffPresent(incarnation_king_of_the_jungle_buff) Spell(shadowmeld)
					}
				}
			}
		}
	}
}

AddFunction FeralGeneratorCdPostConditions
{
	Enemies(tagged=1) > Enemies(tagged=1) and ComboPoints() < 5 and Spell(brutal_slash) or ComboPoints() <= 2 and BuffExpires(elunes_guidance_buff) and { BuffPresent(bloodtalons_buff) or not Talent(bloodtalons_talent) } and { BuffPresent(savage_roar_buff) or not Talent(savage_roar_talent) } and Spell(ashamanes_frenzy) or not { Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() < PowerCost(ferocious_bite) + 25 - EnergyRegenRate() * SpellCooldown(elunes_guidance) } and { Talent(elunes_guidance_talent) and ComboPoints() == 0 and Energy() >= PowerCost(ferocious_bite) + 25 and Spell(elunes_guidance) or not { Talent(brutal_slash_talent) and Enemies(tagged=1) >= 9 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and not { Enemies(tagged=1) >= 6 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat) } and { ComboPoints() < 5 and { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 or Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and { not Talent(soul_of_the_forest_talent) and target.DebuffRemaining(rake_debuff) <= 7 or target.DebuffRemaining(rake_debuff) <= 5 } and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 } and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) and Spell(rake) or not { ComboPoints() < 5 and { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 or Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and { not Talent(soul_of_the_forest_talent) and target.DebuffRemaining(rake_debuff) <= 7 or target.DebuffRemaining(rake_debuff) <= 5 } and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.8 } and target.TimeToDie() - target.DebuffRemaining(rake_debuff) > target.TickTime(rake_debuff) and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake) } and { ComboPoints() < 5 and target.DebuffRemaining(moonfire_cat_debuff) <= 4.2 and target.TimeToDie() - target.DebuffRemaining(moonfire_cat_debuff) > target.TickTime(moonfire_cat_debuff) * 2 and Spell(moonfire_cat) or target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 2 and Spell(thrash_cat) or not { target.DebuffRemaining(thrash_cat_debuff) <= BaseDuration(thrash_cat_debuff) * 0.3 and Enemies(tagged=1) >= 2 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { ComboPoints() < 5 and { False(raid_event_adds_exists) and 600 > { 1 + SpellMaxCharges(brutal_slash) - Charges(brutal_slash count=0) } * 15 or not False(raid_event_adds_exists) and Charges(brutal_slash count=0) > 2.66 and TimeInCombat() > 10 } and Spell(brutal_slash) or ComboPoints() < 5 and Enemies(tagged=1) >= 3 and Spell(swipe_cat) or ComboPoints() < 5 and { Enemies(tagged=1) < 3 or Talent(brutal_slash_talent) } and Spell(shred) } } } }
}

### actions.precombat

AddFunction FeralPrecombatMainActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#augmentation,type=defiled
	# Spell(augmentation)
	#regrowth,if=talent.bloodtalons.enabled
	# if Talent(bloodtalons_talent) Spell(regrowth)
	#cat_form
	# Spell(cat_form)
}

AddFunction FeralPrecombatMainPostConditions
{
}

AddFunction FeralPrecombatShortCdActions
{
	unless Spell(augmentation) or Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
	{
		#prowl
		# Spell(prowl)
	}
}

AddFunction FeralPrecombatShortCdPostConditions
{
	Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
}

AddFunction FeralPrecombatCdActions
{
}

AddFunction FeralPrecombatCdPostConditions
{
	Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
}

### actions.sbt_opener

AddFunction FeralSbtOpenerMainActions
{
	#regrowth,if=talent.bloodtalons.enabled&combo_points=5&!buff.bloodtalons.up&!dot.rip.ticking
	if Talent(bloodtalons_talent) and ComboPoints() == 5 and not BuffPresent(bloodtalons_buff) and not target.DebuffPresent(rip_debuff) Spell(regrowth)
}

AddFunction FeralSbtOpenerMainPostConditions
{
}

AddFunction FeralSbtOpenerShortCdActions
{
	unless Talent(bloodtalons_talent) and ComboPoints() == 5 and not BuffPresent(bloodtalons_buff) and not target.DebuffPresent(rip_debuff) and Spell(regrowth)
	{
		#tigers_fury,if=!dot.rip.ticking&combo_points=5
		if not target.DebuffPresent(rip_debuff) and ComboPoints() == 5 Spell(tigers_fury)
	}
}

AddFunction FeralSbtOpenerShortCdPostConditions
{
	Talent(bloodtalons_talent) and ComboPoints() == 5 and not BuffPresent(bloodtalons_buff) and not target.DebuffPresent(rip_debuff) and Spell(regrowth)
}

AddFunction FeralSbtOpenerCdActions
{
}

AddFunction FeralSbtOpenerCdPostConditions
{
	Talent(bloodtalons_talent) and ComboPoints() == 5 and not BuffPresent(bloodtalons_buff) and not target.DebuffPresent(rip_debuff) and Spell(regrowth)
}
]]
	OvaleScripts:RegisterScript("DRUID", "feral", name, desc, code, "script")
end
