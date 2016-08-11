/* Поддержки на ZP 5.0 Patched нет */

#include <amxmodx>
#include <hamsandwich>

#define SUPPORT_ZP_43				// Поддердка ZP 4.3 Patched
//#define SUPPORT_BIO				// Поддердка Biohazerd v2.00 Beta 3b

#if defined SUPPORT_ZP_43
	#include <zombieplague>
#endif

#if defined SUPPORT_BIO
	#tryinclude <biohazard>
#endif

new g_hudmsg1

public plugin_init() {
	register_plugin("ZP Bullet Damager | Hud HP", "1.0.41.7m", "L4D2")
	
	register_event("Damage", "Event_Damage", "b", "2>0", "3=0")
	
	g_hudmsg1 = CreateHudSyncObj()
}

public Event_Damage( iVictim, iAttacker ) {
	new id = get_user_attacker(iVictim)
	if( (1 <= id <= 32) && is_user_connected(id) ) {
		#if defined SUPPORT_ZP_43
		if(iVictim == id || !is_user_alive(id) || zp_get_user_zombie(id)) return HAM_IGNORED
		#endif
		
		#if defined SUPPORT_BIO
		if(iVictim == id || !is_user_alive(id) || is_user_infected(id) || is_user_zombie(id)) return HAM_IGNORED
		#endif
		
		static damage; damage = read_data(2)
		
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(id, g_hudmsg1, "%d^n", damage)
		
		new iVictimHealth = get_user_health(iVictim)
		if(iVictimHealth < 0) iVictimHealth = 0
		
		client_print(id, print_center, "HP: %d", iVictimHealth)
	}
	
	return HAM_IGNORED
}
