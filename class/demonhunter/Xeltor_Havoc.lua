local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_havoc"
	local desc = "[Xel][7.1.5] Demon Hunter: Havoc"
	local code = [[

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)

AddIcon specialization=1 help=main
{
	if InCombat() HavocInterruptActions()
	
	if target.InRange(chaos_strike) and HasFullControl()
	{
		# Cooldowns
		if Boss()
		{
			HavocCooldownCdActions()
		}
		
		# Short Cooldowns
		HavocDefaultShortCdActions()
		
		# Default Actions
		HavocDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction HavocInterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(consume_magic) Spell(consume_magic)
		if not IsBossFight() Spell(arcane_torrent_dh)
	}
}

AddFunction pooling_for_meta
{
	not Talent(demonic_talent) and SpellCooldown(metamorphosis_havoc) < 6 and FuryDeficit() > 30 and { not waiting_for_nemesis() or SpellCooldown(nemesis) < 10 } and { not waiting_for_chaos_blades() or SpellCooldown(chaos_blades) < 6 }
}

AddFunction pooling_for_chaos_strike
{
	Talent(chaos_cleave_talent) and FuryDeficit() > 40 and not False(raid_event_adds_exists) and 600 < 2 * GCD()
}

AddFunction waiting_for_chaos_blades
{
	not { not Talent(chaos_blades_talent) or Talent(chaos_blades_talent) and SpellCooldown(chaos_blades) == 0 or SpellCooldown(chaos_blades) > target.TimeToDie() or SpellCooldown(chaos_blades) > 60 }
}

AddFunction pooling_for_blade_dance
{
	blade_dance() and Fury() - 40 < 35 - TalentPoints(first_blood_talent) * 20 and Enemies(tagged=1) >= 3 + TalentPoints(chaos_cleave_talent) * 2
}

AddFunction waiting_for_nemesis
{
	not { not Talent(nemesis_talent) or Talent(nemesis_talent) and SpellCooldown(nemesis) == 0 or SpellCooldown(nemesis) > target.TimeToDie() or SpellCooldown(nemesis) > 60 }
}

AddFunction blade_dance
{
	Talent(first_blood_talent) or ArmorSetBonus(T20 2) or Enemies(tagged=1) >= 3 + TalentPoints(chaos_cleave_talent) * 2
}

### actions.default

AddFunction HavocDefaultMainActions
{
	#call_action_list,name=cooldown,if=gcd.remains=0
	if not GCDRemaining() > 0 HavocCooldownMainActions()

	unless not GCDRemaining() > 0 and HavocCooldownMainPostConditions()
	{
		#run_action_list,name=demonic,if=talent.demonic.enabled&talent.demonic_appetite.enabled&talent.blind_fury.enabled
		if Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) HavocDemonicMainActions()

		unless Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) and HavocDemonicMainPostConditions()
		{
			#run_action_list,name=normal
			HavocNormalMainActions()
		}
	}
}

AddFunction HavocDefaultMainPostConditions
{
	not GCDRemaining() > 0 and HavocCooldownMainPostConditions() or Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) and HavocDemonicMainPostConditions() or HavocNormalMainPostConditions()
}

AddFunction HavocDefaultShortCdActions
{
	#auto_attack
	# HavocGetInMeleeRange()
	#call_action_list,name=cooldown,if=gcd.remains=0
	if not GCDRemaining() > 0 HavocCooldownShortCdActions()

	unless not GCDRemaining() > 0 and HavocCooldownShortCdPostConditions()
	{
		#run_action_list,name=demonic,if=talent.demonic.enabled&talent.demonic_appetite.enabled&talent.blind_fury.enabled
		if Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) HavocDemonicShortCdActions()

		unless Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) and HavocDemonicShortCdPostConditions()
		{
			#run_action_list,name=normal
			HavocNormalShortCdActions()
		}
	}
}

AddFunction HavocDefaultShortCdPostConditions
{
	not GCDRemaining() > 0 and HavocCooldownShortCdPostConditions() or Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) and HavocDemonicShortCdPostConditions() or HavocNormalShortCdPostConditions()
}

AddFunction HavocDefaultCdActions
{
	#variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
	#variable,name=waiting_for_chaos_blades,value=!(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready|cooldown.chaos_blades.remains>target.time_to_die|cooldown.chaos_blades.remains>60)
	#variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)&(!variable.waiting_for_chaos_blades|cooldown.chaos_blades.remains<6)
	#variable,name=blade_dance,value=talent.first_blood.enabled|set_bonus.tier20_2pc|spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*2)
	#variable,name=pooling_for_blade_dance,value=variable.blade_dance&fury-40<35-talent.first_blood.enabled*20&(spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*2))
	#variable,name=pooling_for_chaos_strike,value=talent.chaos_cleave.enabled&fury.deficit>40&!raid_event.adds.up&raid_event.adds.in<2*gcd
	#consume_magic
	# HavocInterruptActions()
	#call_action_list,name=cooldown,if=gcd.remains=0
	if not GCDRemaining() > 0 HavocCooldownCdActions()

	unless not GCDRemaining() > 0 and HavocCooldownCdPostConditions()
	{
		#run_action_list,name=demonic,if=talent.demonic.enabled&talent.demonic_appetite.enabled&talent.blind_fury.enabled
		if Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) HavocDemonicCdActions()

		unless Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) and HavocDemonicCdPostConditions()
		{
			#run_action_list,name=normal
			HavocNormalCdActions()
		}
	}
}

AddFunction HavocDefaultCdPostConditions
{
	not GCDRemaining() > 0 and HavocCooldownCdPostConditions() or Talent(demonic_talent) and Talent(demonic_appetite_talent) and Talent(blind_fury_talent) and HavocDemonicCdPostConditions() or HavocNormalCdPostConditions()
}

### actions.cooldown

AddFunction HavocCooldownMainActions
{
}

AddFunction HavocCooldownMainPostConditions
{
}

AddFunction HavocCooldownShortCdActions
{
}

AddFunction HavocCooldownShortCdPostConditions
{
}

AddFunction HavocCooldownCdActions
{
	#metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis|variable.waiting_for_chaos_blades)|target.time_to_die<25
	if { not { Talent(demonic_talent) or pooling_for_meta() or waiting_for_nemesis() or waiting_for_chaos_blades() } or target.TimeToDie() < 25 } and IsBossFight() Spell(metamorphosis_havoc)
	#metamorphosis,if=talent.demonic.enabled&buff.metamorphosis.up&fury<40
	if Talent(demonic_talent) and BuffPresent(metamorphosis_havoc_buff) and Fury() < 40 and IsBossFight() Spell(metamorphosis_havoc)
	#nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
	if False(raid_event_adds_exists) and target.DebuffExpires(nemesis_debuff) and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 60 } Spell(nemesis)
	#nemesis,if=!raid_event.adds.exists&(buff.chaos_blades.up|buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains<20|target.time_to_die<=60)
	if not False(raid_event_adds_exists) and { BuffPresent(chaos_blades_buff) or BuffPresent(metamorphosis_havoc_buff) or SpellCooldown(metamorphosis_havoc) < 20 or target.TimeToDie() <= 60 } Spell(nemesis)
	#chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains>60|target.time_to_die<=12
	if BuffPresent(metamorphosis_havoc_buff) or SpellCooldown(metamorphosis_havoc) > 60 or target.TimeToDie() <= 12 Spell(chaos_blades)
	#use_item,slot=trinket1,if=buff.chaos_blades.up|!talent.chaos_blades.enabled
	# if BuffPresent(chaos_blades_buff) or not Talent(chaos_blades_talent) HavocUseItemActions()
}

AddFunction HavocCooldownCdPostConditions
{
}

### actions.demonic

AddFunction HavocDemonicMainActions
{
	#pick_up_fragment,if=fury.deficit>=35&cooldown.eye_beam.remains>5
	if FuryDeficit() >= 35 and SpellCooldown(eye_beam) > 5 Spell(pick_up_fragment)
	#vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
	# if { Talent(prepared_talent) or Talent(momentum_talent) } and BuffExpires(prepared_buff) and BuffExpires(momentum_buff) and CheckBoxOn(opt_vengeful_retreat) Spell(vengeful_retreat)
	#fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
	# if { Talent(momentum_talent) or Talent(fel_mastery_talent) } and { not Talent(momentum_talent) or { Charges(fel_rush) == 2 or SpellCooldown(vengeful_retreat) > 4 } and BuffExpires(momentum_buff) } and { Charges(fel_rush) == 2 or 600 > 10 and 600 > 10 } Spell(fel_rush)
	#throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
	if Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 Spell(throw_glaive_havoc)
	#death_sweep,if=variable.blade_dance
	if blade_dance() Spell(death_sweep)
	#fel_eruption
	Spell(fel_eruption)
	#fury_of_the_illidari,if=(active_enemies>desired_targets|raid_event.adds.in>55)&(!talent.momentum.enabled|buff.momentum.up)
	if { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 55 } and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } Spell(fury_of_the_illidari)
	#blade_dance,if=variable.blade_dance&cooldown.eye_beam.remains>5&!cooldown.metamorphosis.ready
	if blade_dance() and SpellCooldown(eye_beam) > 5 and not SpellCooldown(metamorphosis_havoc) == 0 Spell(blade_dance)
	#throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
	if Talent(bloodlet_talent) and Enemies(tagged=1) >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies(tagged=1) >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } Spell(throw_glaive_havoc)
	#eye_beam,if=spell_targets.eye_beam_tick>desired_targets|!buff.metamorphosis.extended_by_demonic
	if Enemies(tagged=1) > Enemies(tagged=1) or not False() Spell(eye_beam)
	#annihilation,if=(!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
	if { not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() Spell(annihilation)
	#throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
	if Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) Spell(throw_glaive_havoc)
	#chaos_strike,if=(!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
	if { not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() Spell(chaos_strike)
	#fel_rush,if=!talent.momentum.enabled&buff.metamorphosis.down&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
	# if not Talent(momentum_talent) and BuffExpires(metamorphosis_havoc_buff) and { Charges(fel_rush) == 2 or 600 > 10 and 600 > 10 } Spell(fel_rush)
	#demons_bite
	Spell(demons_bite)
	#throw_glaive,if=buff.out_of_range.up
	if not target.InRange() Spell(throw_glaive_havoc)
	#fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
	# if { target.Distance() > 15 or not target.InRange() and not Talent(momentum_talent) } Spell(fel_rush)
	#vengeful_retreat,if=movement.distance>15
	# if target.Distance() > 15 and CheckBoxOn(opt_vengeful_retreat) Spell(vengeful_retreat)
}

AddFunction HavocDemonicMainPostConditions
{
}

AddFunction HavocDemonicShortCdActions
{
}

AddFunction HavocDemonicShortCdPostConditions
{
	FuryDeficit() >= 35 and SpellCooldown(eye_beam) > 5 and Spell(pick_up_fragment) or Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 and Spell(throw_glaive_havoc) or blade_dance() and Spell(death_sweep) or Spell(fel_eruption) or { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 55 } and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Spell(fury_of_the_illidari) or blade_dance() and SpellCooldown(eye_beam) > 5 and not SpellCooldown(metamorphosis_havoc) == 0 and Spell(blade_dance) or Talent(bloodlet_talent) and Enemies(tagged=1) >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies(tagged=1) >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } and Spell(throw_glaive_havoc) or { Enemies(tagged=1) > Enemies(tagged=1) or not False() } and Spell(eye_beam) or { not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() and Spell(annihilation) or Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) and Spell(throw_glaive_havoc) or { not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and Spell(chaos_strike) or Spell(demons_bite) or not target.InRange() and Spell(throw_glaive_havoc)
}

AddFunction HavocDemonicCdActions
{
}

AddFunction HavocDemonicCdPostConditions
{
	FuryDeficit() >= 35 and SpellCooldown(eye_beam) > 5 and Spell(pick_up_fragment) or Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 and Spell(throw_glaive_havoc) or blade_dance() and Spell(death_sweep) or Spell(fel_eruption) or { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 55 } and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Spell(fury_of_the_illidari) or blade_dance() and SpellCooldown(eye_beam) > 5 and not SpellCooldown(metamorphosis_havoc) == 0 and Spell(blade_dance) or Talent(bloodlet_talent) and Enemies(tagged=1) >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies(tagged=1) >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } and Spell(throw_glaive_havoc) or { Enemies(tagged=1) > Enemies(tagged=1) or not False() } and Spell(eye_beam) or { not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() and Spell(annihilation) or Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) and Spell(throw_glaive_havoc) or { not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and Spell(chaos_strike) or Spell(demons_bite) or not target.InRange() and Spell(throw_glaive_havoc)
}

### actions.normal

AddFunction HavocNormalMainActions
{
	#pick_up_fragment,if=talent.demonic_appetite.enabled&fury.deficit>=35
	if Talent(demonic_appetite_talent) and FuryDeficit() >= 35 Spell(pick_up_fragment)
	#vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
	# if { Talent(prepared_talent) or Talent(momentum_talent) } and BuffExpires(prepared_buff) and BuffExpires(momentum_buff) and CheckBoxOn(opt_vengeful_retreat) Spell(vengeful_retreat)
	#fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
	# if { Talent(momentum_talent) or Talent(fel_mastery_talent) } and { not Talent(momentum_talent) or { Charges(fel_rush) == 2 or SpellCooldown(vengeful_retreat) > 4 } and BuffExpires(momentum_buff) } and { not Talent(fel_mastery_talent) or FuryDeficit() >= 25 } and { Charges(fel_rush) == 2 or 600 > 10 and 600 > 10 } Spell(fel_rush)
	#fel_barrage,if=(charges=max_charges)&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
	if Charges(fel_barrage) == SpellMaxCharges(fel_barrage) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 30 } Spell(fel_barrage)
	#throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
	if Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 Spell(throw_glaive_havoc)
	#felblade,if=fury<15&(cooldown.death_sweep.remains<2*gcd|cooldown.blade_dance.remains<2*gcd)
	if Fury() < 15 and { SpellCooldown(death_sweep) < 2 * GCD() or SpellCooldown(blade_dance) < 2 * GCD() } Spell(felblade)
	#death_sweep,if=variable.blade_dance
	if blade_dance() Spell(death_sweep)
	#fel_rush,if=charges=2&!talent.momentum.enabled&!talent.fel_mastery.enabled
	# if Charges(fel_rush) == 2 and not Talent(momentum_talent) and not Talent(fel_mastery_talent) Spell(fel_rush)
	#fel_eruption
	Spell(fel_eruption)
	#fury_of_the_illidari,if=(active_enemies>desired_targets|raid_event.adds.in>55)&(!talent.momentum.enabled|buff.momentum.up)&(!talent.chaos_blades.enabled|buff.chaos_blades.up|cooldown.chaos_blades.remains>30|target.time_to_die<cooldown.chaos_blades.remains)
	if { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 55 } and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { not Talent(chaos_blades_talent) or BuffPresent(chaos_blades_buff) or SpellCooldown(chaos_blades) > 30 or target.TimeToDie() < SpellCooldown(chaos_blades) } Spell(fury_of_the_illidari)
	#blade_dance,if=variable.blade_dance&(!cooldown.metamorphosis.ready)
	if blade_dance() and not SpellCooldown(metamorphosis_havoc) == 0 Spell(blade_dance)
	#throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
	if Talent(bloodlet_talent) and Enemies(tagged=1) >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies(tagged=1) >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } Spell(throw_glaive_havoc)
	#felblade,if=fury.deficit>=30+buff.prepared.up*8
	if FuryDeficit() >= 30 + BuffPresent(prepared_buff) * 8 Spell(felblade)
	#eye_beam,if=talent.blind_fury.enabled&(spell_targets.eye_beam_tick>desired_targets|fury.deficit>=35)
	if Talent(blind_fury_talent) and { Enemies(tagged=1) > Enemies(tagged=1) or FuryDeficit() >= 35 } Spell(eye_beam)
	#annihilation,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
	if { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() Spell(annihilation)
	#throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
	if Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) Spell(throw_glaive_havoc)
	#eye_beam,if=!talent.blind_fury.enabled&(spell_targets.eye_beam_tick>desired_targets|(!set_bonus.tier19_4pc&raid_event.adds.in>45&!variable.pooling_for_meta&buff.metamorphosis.down&(artifact.anguish_of_the_deceiver.enabled|active_enemies>1)&!talent.chaos_cleave.enabled))
	if not Talent(blind_fury_talent) and { Enemies(tagged=1) > Enemies(tagged=1) or not ArmorSetBonus(T19 4) and 600 > 45 and not pooling_for_meta() and BuffExpires(metamorphosis_havoc_buff) and { HasArtifactTrait(anguish_of_the_deceiver) or Enemies(tagged=1) > 1 } and not Talent(chaos_cleave_talent) } Spell(eye_beam)
	#throw_glaive,if=buff.metamorphosis.down&spell_targets>=2
	if BuffExpires(metamorphosis_havoc_buff) and Enemies(tagged=1) >= 2 Spell(throw_glaive_havoc)
	#chaos_strike,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
	if { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() Spell(chaos_strike)
	#fel_barrage,if=(charges=max_charges-1)&buff.metamorphosis.down&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
	if Charges(fel_barrage) == SpellMaxCharges(fel_barrage) - 1 and BuffExpires(metamorphosis_havoc_buff) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 30 } Spell(fel_barrage)
	#fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&(talent.demon_blades.enabled|buff.metamorphosis.down)
	# if not Talent(momentum_talent) and 600 > Charges(fel_rush) * 10 and { Talent(demon_blades_talent) or BuffExpires(metamorphosis_havoc_buff) } Spell(fel_rush)
	#demons_bite
	Spell(demons_bite)
	#throw_glaive,if=buff.out_of_range.up
	if not target.InRange() Spell(throw_glaive_havoc)
	#felblade,if=movement.distance|buff.out_of_range.up
	if target.Distance() or not target.InRange() Spell(felblade)
	#fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
	# if { target.Distance() > 15 or not target.InRange() and not Talent(momentum_talent) } Spell(fel_rush)
	#vengeful_retreat,if=movement.distance>15
	# if target.Distance() > 15 and CheckBoxOn(opt_vengeful_retreat) Spell(vengeful_retreat)
	#throw_glaive,if=!talent.bloodlet.enabled
	if not Talent(bloodlet_talent) Spell(throw_glaive_havoc)
}

AddFunction HavocNormalMainPostConditions
{
}

AddFunction HavocNormalShortCdActions
{
}

AddFunction HavocNormalShortCdPostConditions
{
	Talent(demonic_appetite_talent) and FuryDeficit() >= 35 and Spell(pick_up_fragment) or Charges(fel_barrage) == SpellMaxCharges(fel_barrage) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 30 } and Spell(fel_barrage) or Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 and Spell(throw_glaive_havoc) or Fury() < 15 and { SpellCooldown(death_sweep) < 2 * GCD() or SpellCooldown(blade_dance) < 2 * GCD() } and Spell(felblade) or blade_dance() and Spell(death_sweep) or Spell(fel_eruption) or { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 55 } and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { not Talent(chaos_blades_talent) or BuffPresent(chaos_blades_buff) or SpellCooldown(chaos_blades) > 30 or target.TimeToDie() < SpellCooldown(chaos_blades) } and Spell(fury_of_the_illidari) or blade_dance() and not SpellCooldown(metamorphosis_havoc) == 0 and Spell(blade_dance) or Talent(bloodlet_talent) and Enemies(tagged=1) >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies(tagged=1) >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } and Spell(throw_glaive_havoc) or FuryDeficit() >= 30 + BuffPresent(prepared_buff) * 8 and Spell(felblade) or Talent(blind_fury_talent) and { Enemies(tagged=1) > Enemies(tagged=1) or FuryDeficit() >= 35 } and Spell(eye_beam) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() and Spell(annihilation) or Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) and Spell(throw_glaive_havoc) or not Talent(blind_fury_talent) and { Enemies(tagged=1) > Enemies(tagged=1) or not ArmorSetBonus(T19 4) and 600 > 45 and not pooling_for_meta() and BuffExpires(metamorphosis_havoc_buff) and { HasArtifactTrait(anguish_of_the_deceiver) or Enemies(tagged=1) > 1 } and not Talent(chaos_cleave_talent) } and Spell(eye_beam) or BuffExpires(metamorphosis_havoc_buff) and Enemies(tagged=1) >= 2 and Spell(throw_glaive_havoc) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and Spell(chaos_strike) or Charges(fel_barrage) == SpellMaxCharges(fel_barrage) - 1 and BuffExpires(metamorphosis_havoc_buff) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 30 } and Spell(fel_barrage) or Spell(demons_bite) or not target.InRange() and Spell(throw_glaive_havoc) or { target.Distance() or not target.InRange() } and Spell(felblade) or not Talent(bloodlet_talent) and Spell(throw_glaive_havoc)
}

AddFunction HavocNormalCdActions
{
}

AddFunction HavocNormalCdPostConditions
{
	Talent(demonic_appetite_talent) and FuryDeficit() >= 35 and Spell(pick_up_fragment) or Charges(fel_barrage) == SpellMaxCharges(fel_barrage) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 30 } and Spell(fel_barrage) or Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 and Spell(throw_glaive_havoc) or Fury() < 15 and { SpellCooldown(death_sweep) < 2 * GCD() or SpellCooldown(blade_dance) < 2 * GCD() } and Spell(felblade) or blade_dance() and Spell(death_sweep) or Spell(fel_eruption) or { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 55 } and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { not Talent(chaos_blades_talent) or BuffPresent(chaos_blades_buff) or SpellCooldown(chaos_blades) > 30 or target.TimeToDie() < SpellCooldown(chaos_blades) } and Spell(fury_of_the_illidari) or blade_dance() and not SpellCooldown(metamorphosis_havoc) == 0 and Spell(blade_dance) or Talent(bloodlet_talent) and Enemies(tagged=1) >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies(tagged=1) >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } and Spell(throw_glaive_havoc) or FuryDeficit() >= 30 + BuffPresent(prepared_buff) * 8 and Spell(felblade) or Talent(blind_fury_talent) and { Enemies(tagged=1) > Enemies(tagged=1) or FuryDeficit() >= 35 } and Spell(eye_beam) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() and Spell(annihilation) or Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) and Spell(throw_glaive_havoc) or not Talent(blind_fury_talent) and { Enemies(tagged=1) > Enemies(tagged=1) or not ArmorSetBonus(T19 4) and 600 > 45 and not pooling_for_meta() and BuffExpires(metamorphosis_havoc_buff) and { HasArtifactTrait(anguish_of_the_deceiver) or Enemies(tagged=1) > 1 } and not Talent(chaos_cleave_talent) } and Spell(eye_beam) or BuffExpires(metamorphosis_havoc_buff) and Enemies(tagged=1) >= 2 and Spell(throw_glaive_havoc) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and Spell(chaos_strike) or Charges(fel_barrage) == SpellMaxCharges(fel_barrage) - 1 and BuffExpires(metamorphosis_havoc_buff) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies(tagged=1) > Enemies(tagged=1) or 600 > 30 } and Spell(fel_barrage) or Spell(demons_bite) or not target.InRange() and Spell(throw_glaive_havoc) or { target.Distance() or not target.InRange() } and Spell(felblade) or not Talent(bloodlet_talent) and Spell(throw_glaive_havoc)
}

### actions.precombat

AddFunction HavocPrecombatMainActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=lavish_suramar_feast,if=!equipped.majordomos_dinner_bell
	#food,type=nightborne_delicacy_platter,if=equipped.majordomos_dinner_bell
	#augmentation,type=defiled
	Spell(augmentation)
}

AddFunction HavocPrecombatMainPostConditions
{
}

AddFunction HavocPrecombatShortCdActions
{
}

AddFunction HavocPrecombatShortCdPostConditions
{
	Spell(augmentation)
}

AddFunction HavocPrecombatCdActions
{
	unless Spell(augmentation)
	{
		#snapshot_stats
		#potion,name=old_war
		#metamorphosis,if=!(talent.demon_reborn.enabled&talent.demonic.enabled)
		if not { Talent(demon_reborn_talent) and Talent(demonic_talent) } and IsBossFight() Spell(metamorphosis_havoc)
	}
}

AddFunction HavocPrecombatCdPostConditions
{
	Spell(augmentation)
}
]]

	OvaleScripts:RegisterScript("DEMONHUNTER", "havoc", name, desc, code, "script")
end
