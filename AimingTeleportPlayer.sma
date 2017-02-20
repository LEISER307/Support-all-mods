/*********************************************************************************************
	-			Copyright © 2016/2017 L4D2			   -
	----------------------------------------------------
	- Aiming Teleport Player | Телепорт игрока в точку -
	----------------------------------------------------
	
	Support forum:: http://amx-x.ru/viewtopic.php?f=11&t=35965&p=293990
	GitHub: 
	
	~~~~~~~~~~~~~~
	- Changelog: -
	~~~~~~~~~~~~~~
		v 0.4.2 - First Release
		v 0.5.1 - Add support Zombie Plague
		v 0.5.2.2 - Fixed to Sky bugs Thanks for Subb98
		v 0.5.2a - Refactoring
	
	~~~~~~~~~~~~~~~~~
	- [*] Описание: -
	~~~~~~~~~~~~~~~~~
		- Телерот как для Паблик/классика так и для других модов, присутствует поддержка ZP мода.
		- Чтобы включить/выключить поддержку для ZP мода, раскоментируйте: #define ZP_SUPPORT По дефолту: //#define ZP_SUPPORT
		- Если вы используете для ZP мода, то в экстра итемах покупка доступна для Людей.
	
	[~] Чтобы телепортироваться, нужно забиндить кнопку: bind "Ваша кнопка" teleport (bind f teleport)
*********************************************************************************************/	

#include <amxmodx>
#include <fakemeta>
#include <fun>

//#define ZP_SUPPORT

#define	CONTENTS_SKY	-6	/* Thanks for Subb98 */

#if defined ZP_SUPPORT
	#include <zombieplague>
#endif

#if defined ZP_SUPPORT
	// Item ID
	new g_teleport;

	// Name Item
	new const g_item_name[] = "Teleport";

	// Cost ammo
	new const COST = 10;

	// Extra Team
	new const g_extra_team = ZP_TEAM_HUMAN;	// ZP_TEAM_HUMAN - Люди | ZP_TEAM_ZOMBIE - Зомби
#endif

// Game Variables
new bool:hasTeleport[33];
new teleport_counter;
new Float:g_lastusetime[33];

// CVAR Pointers
new pcv_teleport_limit, pcv_teleport_cooldown;

// Sprite Index
new BubbleSprite;

public plugin_init() {
	register_plugin("[All mods] Teleport Player", "0.5.2a", "L4D2");
	
	register_clcmd("teleport", "ActivTeleport");
	
	#if defined ZP_SUPPORT
		g_teleport = zp_register_extra_item(g_item_name, COST, g_extra_team);
	#else
		register_clcmd("say /t", "extra_buy_item");
	#endif
	
	// CVARs
	pcv_teleport_limit = register_cvar("zp_teleport_limit", "5");			// Сколько за раунд можно активировать
	pcv_teleport_cooldown = register_cvar("zp_teleport_cooldown", "10");	// Через какое n время можно телепортироваться
}

public plugin_precache() {
	// Teleport Sound
	precache_sound("warcraft3/blinkarrival.wav");
	
	// Sprite
	BubbleSprite = precache_model("sprites/blueflare2.spr");
}

#if defined ZP_SUPPORT
	public zp_round_started(gamemode, id) if(hasTeleport[id]) return;
#endif

public extra_buy_item(owner) {
	hasTeleport[owner] = true;
	teleport_counter = 0;
	client_print(owner, print_chat, "Введите в консоль: bind key teleport Пример:(bind f teleport)");
}

#if defined ZP_SUPPORT
	public zp_extra_item_selected(owner, itemid) {
		if(itemid == g_teleport) {
			if(hasTeleport[owner]) {
				client_print(owner, print_center, "Куплено");
				hasTeleport[owner] = false;
			} else {
				hasTeleport[owner] = true;
				teleport_counter = 0;
				client_print(owner, print_chat, "[ZP] Введите в консоль: bind key teleport Пример:(bind f teleport)");
			}
		}
	}
#endif

// Activate Teleport
public ActivTeleport(id) {
	if(!is_user_alive(id) && !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	// For some reason zombie or survivor or nemesis has teleport
	#if defined ZP_SUPPORT
		if(zp_get_user_zombie(id) || zp_get_user_survivor(id) || zp_get_user_nemesis(id)) return PLUGIN_CONTINUE;
	#endif
	
	// Check if player has bought teleport
	if(!hasTeleport[id]) {
		client_print(id, print_center, "Купите телепорт, чтобы им воспользоваться");
		return PLUGIN_CONTINUE;
	}
	
	// Teleport cooldown not over	
	if(get_gametime() - g_lastusetime[id] < get_pcvar_float(pcv_teleport_cooldown)) {
		client_print(id, print_center, "Перезарядка: %.fc", get_pcvar_float(pcv_teleport_cooldown) - ( get_gametime() - g_lastusetime[id] ));
		return PLUGIN_CONTINUE;
	}
	
	if(is_aiming_at_sky(id)) return PLUGIN_CONTINUE;
	
	// Get old and new location
	new OldLocation[3], NewLocation[3];
	
	// Get current players location
	get_user_origin(id, OldLocation);
	
	// Get location where player is aiming(where he will be teleported)
	get_user_origin(id, NewLocation, 3);
	
	// Create bubbles in a place where player teleported
	// First, get user origin
	new UserOrigin[3];
	get_user_origin(id, UserOrigin);
	
	// Now create bubbles
	new BubbleOrigin[3];
	BubbleOrigin[0] = UserOrigin[0];
	BubbleOrigin[1] = UserOrigin[1];
	BubbleOrigin[2] = UserOrigin[2] + 40;
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL) // TE ID
	write_coord(BubbleOrigin[0]) // Start Position X
	write_coord(BubbleOrigin[1]) // Start Position Y
	write_coord(BubbleOrigin[2]) // Start Position Z
	write_coord(UserOrigin[0]) // End Position X
	write_coord(UserOrigin[1]) // End Position Y
	write_coord(UserOrigin[2]) // End Position Z
	write_short(BubbleSprite) // Sprite Index
	write_byte(30) // Count
	write_byte(10) // Life
	write_byte(1) // Scale
	write_byte(50) // Velocity Along Vector
	write_byte(10) // Rendomness of Velocity
	message_end();

	// Increase teleport counter
	teleport_counter++
	
	// Play needed sound
	emit_sound(id, CHAN_STATIC, "warcraft3/blinkarrival.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	// Player cannot stuck in the wall/floor
	NewLocation[0] += ((NewLocation[0] - OldLocation[0] > 0) ? -50 : 50);
	NewLocation[1] += ((NewLocation[1] - OldLocation[1] > 0) ? -50 : 50);
	NewLocation[2] += 40;
	
	// Teleport player
	set_user_origin(id, NewLocation);
	
	// Set current teleport use time
	g_lastusetime[id] = get_gametime();
	
	// Check if user has reached limit
	new teleport_limit = get_pcvar_num(pcv_teleport_limit);
	if(teleport_counter == teleport_limit) hasTeleport[id] = false;
	
	return PLUGIN_CONTINUE;
}

//Thanks Exolent[jNr]
stock bool:is_aiming_at_sky(index) {
    static iOrigin[3];
    get_user_origin(index, iOrigin, 3);
    
    static Float:vOrigin[3];
    IVecFVec(iOrigin, vOrigin);
    return (engfunc(EngFunc_PointContents, vOrigin) == CONTENTS_SKY);
}
