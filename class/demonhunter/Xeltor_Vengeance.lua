local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_vengeance"
	local desc = "[Xel][7.2] Demon Hunter: Vengeance"
	local code = [[
Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)

AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() and { target.Casting(interrupt) or not IsBossFight() } InterruptActions()
	
    if target.InRange(shear) and HasFullControl()
    {
		# Cooldown
		VengeanceDefaultCdActions()
		
		# Short Cooldown
		VengeanceDefaultShortCdActions()
		
		# Main rotation
		VengeanceDefaultMainActions()
    }
	
	if InCombat() and target.InRange(felblade) Spell(felblade)
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

# Common functions.
AddFunction InterruptActions
{
	if not target.IsFriend() and target.Casting()
	{
		if target.InRange(consume_magic) and target.IsInterruptible() Spell(consume_magic)
		if target.InRange(fel_eruption) and not target.Classification(worldboss) Spell(fel_eruption)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_dh)
		if target.InRange(imprison) and not target.Classification(worldboss) and target.CreatureType(Demon Humanoid Beast) Spell(imprison)
		if target.InRange(shear)
		{
			if target.IsInterruptible() and not target.Classification(worldboss) and not SigilCharging(silence misery chains) and target.RemainingCastTime() >= 2 - Talent(quickened_sigils_talent) + GCDRemaining() Spell(sigil_of_silence)
			if not target.Classification(worldboss) and not SigilCharging(silence misery chains) and target.RemainingCastTime() >= 2 - Talent(quickened_sigils_talent) + GCDRemaining() Spell(sigil_of_misery)
			if not target.Classification(worldboss) and not SigilCharging(silence misery chains) and target.RemainingCastTime() >= 2 - Talent(quickened_sigils_talent) + GCDRemaining() Spell(sigil_of_chains)
		}
	}
}

### actions.default

AddFunction VengeanceDefaultMainActions
{
	#infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&artifact.fiery_demise.enabled&dot.fiery_brand.ticking
	if not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) Spell(infernal_strike)
	#infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&(!artifact.fiery_demise.enabled|(max_charges-charges_fractional)*recharge_time<cooldown.fiery_brand.remains+5)&(cooldown.sigil_of_flame.remains>7|charges=2)
	if not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } Spell(infernal_strike)
	#spirit_bomb,if=debuff.frailty.down
	if target.DebuffExpires(frailty_debuff) and BuffStacks(soul_fragments) >= 1 Spell(spirit_bomb)
	#soul_carver,if=dot.fiery_brand.ticking
	if target.DebuffPresent(fiery_brand_debuff) Spell(soul_carver)
	#immolation_aura,if=pain<=80
	if Pain() <= 80 Spell(immolation_aura)
	#felblade,if=pain<=70
	if Pain() <= 70 Spell(felblade)
	#soul_barrier
	Spell(soul_barrier)
	#soul_cleave,if=soul_fragments=5
	if BuffStacks(soul_fragments) == 5 Spell(soul_cleave)
	#soul_cleave,if=incoming_damage_5s>=health.max*0.70
	if IncomingDamage(5) >= MaxHealth() * 0.7 Spell(soul_cleave)
	#fel_eruption
	Spell(fel_eruption)
	#sigil_of_flame,if=remains-delay<=0.3*duration
	if target.DebuffRemaining(sigil_of_flame_debuff) - 0 <= 0.3 * BaseDuration(sigil_of_flame_debuff) Spell(sigil_of_flame)
	#fracture,if=pain>=80&soul_fragments<4&incoming_damage_4s<=health.max*0.20
	if Pain() >= 80 and BuffStacks(soul_fragments) < 4 and IncomingDamage(4) <= MaxHealth() * 0.2 Spell(fracture)
	#soul_cleave,if=pain>=80
	if Pain() >= 80 Spell(soul_cleave)
	#shear
	Spell(shear)
}

AddFunction VengeanceDefaultMainPostConditions
{
}

AddFunction VengeanceDefaultShortCdActions
{
	#auto_attack
	# VengeanceGetInMeleeRange()
	#demon_spikes,if=charges=2|buff.demon_spikes.down&!dot.fiery_brand.ticking&buff.metamorphosis.down
	if Charges(demon_spikes) == 2 or BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) Spell(demon_spikes)

	unless not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave)
	{
		#fel_devastation,if=incoming_damage_5s>health.max*0.70
		if IncomingDamage(5) > MaxHealth() * 0.7 Spell(fel_devastation)
	}
}

AddFunction VengeanceDefaultShortCdPostConditions
{
	not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave) or IncomingDamage(5) >= MaxHealth() * 0.7 and Spell(soul_cleave) or Spell(fel_eruption) or target.DebuffRemaining(sigil_of_flame_debuff) - 0 <= 0.3 * BaseDuration(sigil_of_flame_debuff) and Spell(sigil_of_flame) or Pain() >= 80 and BuffStacks(soul_fragments) < 4 and IncomingDamage(4) <= MaxHealth() * 0.2 and Spell(fracture) or Pain() >= 80 and Spell(soul_cleave) or Spell(shear)
}

AddFunction VengeanceDefaultCdActions
{
	#consume_magic
	# VengeanceInterruptActions()
	#use_item,slot=trinket2
	# VengeanceUseItemActions()
	#fiery_brand,if=buff.demon_spikes.down&buff.metamorphosis.down
	if BuffExpires(demon_spikes_buff) and BuffExpires(metamorphosis_veng_buff) Spell(fiery_brand)

	unless { Charges(demon_spikes) == 2 or BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) } and Spell(demon_spikes)
	{
		#empower_wards,if=debuff.casting.up
		if target.IsInterruptible() Spell(empower_wards)

		unless not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave)
		{
			#metamorphosis,if=buff.demon_spikes.down&!dot.fiery_brand.ticking&buff.metamorphosis.down&incoming_damage_5s>health.max*0.70
			if BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) and IncomingDamage(5) > MaxHealth() * 0.7 Spell(metamorphosis_veng)
		}
	}
}

AddFunction VengeanceDefaultCdPostConditions
{
	{ Charges(demon_spikes) == 2 or BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) } and Spell(demon_spikes) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave) or IncomingDamage(5) > MaxHealth() * 0.7 and Spell(fel_devastation) or IncomingDamage(5) >= MaxHealth() * 0.7 and Spell(soul_cleave) or Spell(fel_eruption) or target.DebuffRemaining(sigil_of_flame_debuff) - 0 <= 0.3 * BaseDuration(sigil_of_flame_debuff) and Spell(sigil_of_flame) or Pain() >= 80 and BuffStacks(soul_fragments) < 4 and IncomingDamage(4) <= MaxHealth() * 0.2 and Spell(fracture) or Pain() >= 80 and Spell(soul_cleave) or Spell(shear)
}

### actions.precombat

AddFunction VengeancePrecombatMainActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#augmentation,type=defiled
	Spell(augmentation)
}

AddFunction VengeancePrecombatMainPostConditions
{
}

AddFunction VengeancePrecombatShortCdActions
{
}

AddFunction VengeancePrecombatShortCdPostConditions
{
	Spell(augmentation)
}

AddFunction VengeancePrecombatCdActions
{
}

AddFunction VengeancePrecombatCdPostConditions
{
	Spell(augmentation)
}
]]

	OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end
