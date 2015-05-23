/obj/item/clothing/under/marine2
	name = "Marine jumpsuit"
	desc = "A standard quilted Colonial Marine jumpsuit. Weaved with armored plates to protect against low-caliber rounds and light impacts."
	armor = list(melee = 20, bullet = 20, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9

	icon = 'icons/marine_armor.dmi'
	icon_state = "jumpsuit2_s"
	item_state = "jumpsuit2"
	item_color = "jumpsuit2"
	var/sleeves = 2
	icon_override = 'icons/marine_armor.dmi'
//Sleves 2 = long
//Sleves 1 = short
//Sleves 0 = none
/obj/item/clothing/under/marine2/verb/sleeves()
	set category = "Object"
	set name = "Adjust sleeves"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		src.sleeves += 1
		if(src.sleeves > 2)
			src.sleeves = 0
		switch(src.sleeves)
			if(0)
				icon_state = "jumpsuit0_s"
				item_state = "jumpsuit0"
				item_color = "jumpsuit0"
				usr << "You roll up the sleves."
			if(1)
				icon_state = "jumpsuit1_s"
				item_state = "jumpsuit1"
				item_color = "jumpsuit1"
				usr << "You roll down the sleves."
			if(2)
				icon_state = "jumpsuit2_s"
				item_state = "jumpsuit2"
				item_color = "jumpsuit2"
				usr << "You roll down the sleves."
		usr.update_inv_w_uniform()	//so our mob-overlays updates



#define ALPHA		1
#define BRAVO		2
#define CHARLIE		3
#define DELTA		4
#define NONE 		5

var/list/armormarkings = list()
var/list/armormarkings_sql = list()
var/list/helmetmarkings = list()
var/list/helmetmarkings_sql = list()
var/list/squad_colors = list(rgb(255,0,0), rgb(255,255,0), rgb(160,32,240), rgb(0,0,255))



/proc/initialize_marine_armor()
	var/i
	for(i=1, i<5, i++)
		var/image/armor
		var/image/helmet
		armor = image('icons/marine_armor.dmi',icon_state = "std-armor")
		armor.color = squad_colors[i]
		armormarkings += armor
		armor = image('icons/marine_armor.dmi',icon_state = "sql-armor")
		armor.color = squad_colors[i]
		armormarkings_sql += armor

		helmet = image('icons/marine_armor.dmi',icon_state = "std-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings += helmet
		helmet = image('icons/marine_armor.dmi',icon_state = "sql-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings_sql += helmet

/obj/item/clothing/head/helmet/marine2
	icon = 'icons/marine_armor.dmi'
	icon_state = "helmet"
	icon_override = 'icons/marine_armor.dmi'
	item_state = "comhelm"
	name = "M10 Pattern Marine Helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	armor = list(melee = 50, bullet = 80, laser = 50,energy = 10, bomb = 35, bio = 0, rad = 0)
	health = 5
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH
	var/mob/living/carbon/human/wornby
	var/squad = 0
	var/rank = 0
	var/image/markingoverlay

	proc/get_squad(var/obj/item/weapon/card/id/card)
		rank = 0
		squad = 0
		if(!card)
			return
		if(findtext(card.assignment, "Leader") != 0)
			rank = 1
		if(findtext(card.assignment, "Alpha") != 0)
			squad = 1
		if(findtext(card.assignment, "Bravo") != 0)
			squad = 2
		if(findtext(card.assignment, "Charlie") != 0)
			squad = 3
		if(findtext(card.assignment, "Delta") != 0)
			squad = 4
		return

	proc/update_helmet(var/obj/item/weapon/card/id/card = null)
		if(!card)
			if(wornby && wornby.wear_id)
				card = wornby.wear_id
		get_squad(card)
		update_icon()

	New(loc)
		..(loc)

	equipped(var/mob/living/carbon/human/mob, slot)
		if(slot == slot_head)
			wornby = mob
			update_helmet()
			if(istype(markingoverlay))
				mob.overlays_standing += markingoverlay
		else
			if(istype(markingoverlay) && markingoverlay in mob.overlays_standing)
				mob.overlays_standing.Remove(markingoverlay)

	dropped(var/mob/living/carbon/human/mob)
		if(istype(markingoverlay) && markingoverlay in mob.overlays_standing)
			mob.overlays_standing.Remove(markingoverlay)

	update_icon()
		overlays = list() //resets list
		underlays = list()

		if(istype(markingoverlay) && markingoverlay in wornby.overlays_standing)
			wornby.overlays_standing.Remove(markingoverlay)

		if(squad > 0)
			if(rank)
				markingoverlay = helmetmarkings_sql[squad]
				overlays += markingoverlay
				wornby.overlays_standing += markingoverlay
			else
				markingoverlay = helmetmarkings[squad]
				overlays += markingoverlay
				wornby.overlays_standing += markingoverlay
		wornby.update_icons()



/obj/item/clothing/suit/storage/marine2
	icon = 'icons/marine_armor.dmi'
	icon_state = "1"
	item_state = "1"
	icon_override = 'icons/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECITON_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECITON_TEMPERATURE
	name = "M3 Pattern Marine Armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 80, laser = 50, energy = 10, bomb = 35, bio = 0, rad = 0)
	siemens_coefficient = 0.7
	allowed = list(/obj/item/weapon/gun/, /obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton, /obj/item/weapon/melee/stunprod, /obj/item/weapon/handcuffs, /obj/item/weapon/restraints, /obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/weapon/grenade, /obj/item/weapon/combat_knife)
	var/mob/living/carbon/human/wornby
	var/squad = 0
	var/rank = 0
	var/image/markingoverlay

	proc/get_squad(var/obj/item/weapon/card/id/card)
		rank = 0
		squad = 0
		if(!card)
			return
		if(findtext(card.assignment, "Leader") != 0)
			rank = 1
		if(findtext(card.assignment, "Alpha") != 0)
			squad = 1
		if(findtext(card.assignment, "Bravo") != 0)
			squad = 2
		if(findtext(card.assignment, "Charlie") != 0)
			squad = 3
		if(findtext(card.assignment, "Delta") != 0)
			squad = 4
		return

	proc/update_armor(var/obj/item/weapon/card/id/card = null)
		if(!card)
			if(wornby && wornby.wear_id)
				card = wornby.wear_id
		get_squad(card)
		update_icon()

	New(loc)
		..(loc)
		icon_state = "[rand(1,6)]"
		item_state = icon_state

	equipped(var/mob/living/carbon/human/mob, slot)
		if(slot == slot_wear_suit)
			wornby = mob
			update_armor()
			if(istype(markingoverlay))
				mob.overlays_standing += markingoverlay
		else
			if(istype(markingoverlay) && markingoverlay in mob.overlays_standing)
				mob.overlays_standing.Remove(markingoverlay)

	dropped(var/mob/living/carbon/human/mob)
		if(istype(markingoverlay) && markingoverlay in mob.overlays_standing)
			mob.overlays_standing.Remove(markingoverlay)

	update_icon()
		overlays = list() //resets list
		underlays = list()

		if(istype(markingoverlay) && markingoverlay in wornby.overlays_standing)
			wornby.overlays_standing.Remove(markingoverlay)

		if(squad > 0)
			if(rank)
				markingoverlay = armormarkings_sql[squad]
				overlays += markingoverlay
				wornby.overlays_standing += markingoverlay
			else
				markingoverlay = armormarkings[squad]
				overlays += markingoverlay
				wornby.overlays_standing += markingoverlay
		wornby.update_icons()

/obj/item/weapon/card/id/equipped(var/mob/living/carbon/human/mob, slot)
	if(slot == slot_wear_id)
		if(mob.wear_suit && istype(mob.wear_suit, /obj/item/clothing/suit/storage/marine2))
			var/obj/item/clothing/suit/storage/marine2/armor = mob.wear_suit
			armor.update_armor(src)
		if(mob.head && istype(mob.head, /obj/item/clothing/head/helmet/marine2))
			var/obj/item/clothing/head/helmet/marine2/helmet = mob.head
			helmet.update_helmet(src)

/obj/item/weapon/card/id/dropped(var/mob/living/carbon/human/mob)
	if(!mob.wear_id)
		if(mob.wear_suit && istype(mob.wear_suit, /obj/item/clothing/suit/storage/marine2))
			var/obj/item/clothing/suit/storage/marine2/armor = mob.wear_suit
			armor.update_icon()
		if(mob.head && istype(mob.head, /obj/item/clothing/head/helmet/marine2))
			var/obj/item/clothing/head/helmet/marine2/helmet = mob.head
			helmet.update_icon()