SMODS.Joker {
	key = 'voiceOfTheCity',
	name = "Voice of the City",
	pronouns = "it_its",
	config = { extra = { } },
	no_collection = true, 
	perishable_compat = true,   
	eternal_compat = true,
	blueprint_compat = true,
	rarity = 3,
	cost = 8,
    atlas = 'ModdedProjectMoon',
	pos = { x = 5, y = 14 },
    pools =
	{

 	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = {set = "Other", key = "effect_prescript"}
		return { vars = { PMCMOD.grace(), PMCMOD.karma(), PMCMOD.PRESCRIPT_SCENES } }
	end,
	-- The Voice is the Index's cashier: while it is on the team, every prescript that resolves is
	-- settled in money - $15 when it was fulfilled, everything you hold when it was not.
	-- PMCMOD.grant_grace and PMCMOD.grant_karma apply that; this card holds no state of its own.
	calculate = function(self, card, context)

	end,
	in_pool = function(self, args)
        -- never in the random pool: summon/transform-only (was G.GAME.pool_flags.fake_robot_flag)
        return false
    end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(localize('pmcmod_badge_index'), HEX('e0e0e0'), HEX('59a5e3'), 1.2 )
 	end
}