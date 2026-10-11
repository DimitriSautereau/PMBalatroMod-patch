SMODS.Joker {
	key = 'gloria',
	name = "Gloria",
	pronouns = "she_her",
	config = { extra = { graceDollars = 0.2, handGranted = false } },
	unlocked = false,
	eternal_compat = true,
	perishable_compat = true,
    blueprint_compat = false,    
	rarity = 2,
    cost = 6,
	atlas = 'ModdedProjectMoonTrue',
	pos = { x = 0, y = 2 },
	attributes = {'economy', 'singleton'},
	pools =
	{
        ["Index"] = true,
 	},
	loc_vars = function (self, info_queue, card)
		info_queue[#info_queue+1] = {set = "Other", key = "effect_singleton"}
    	return {vars = { math.max(0, math.floor(1 + card.ability.extra.graceDollars * PMCMOD.sora_grace())), PMCMOD.grace(), PMCMOD.karma(), PMCMOD.sora_grace() }}
	end,
	calculate = function(self, card, context)
		
		-- +1 hand size the first time the City's favour reaches 5
		if context.setting_blind and not context.blueprint and not card.ability.extra.handGranted
			and PMCMOD.sora_grace() >= 5 and G.hand then
			card.ability.extra.handGranted = true
			G.hand:change_size(1)
		end

		if context.individual and context.cardarea == G.play and not context.blueprint then
			local singletonCounter = 0
			local singletonSuit = context.other_card.base.suit
			local singletonRank = context.other_card:get_id()
			-- Singleton means no other card is exactly like this one: same rank and same suit.
			-- (Rank alone, as this did before, let a card of any other suit break it; the suit was
			-- computed and never compared, so this finishes that intent.)
			if G.playing_cards then
				for _, playing_card in ipairs(G.playing_cards) do
					if playing_card:get_id() == singletonRank and playing_card.base.suit == singletonSuit then
						singletonCounter = singletonCounter + 1
					end
				end
			end

			if singletonCounter == 1 then
				local d = math.max(0, math.floor(1 + card.ability.extra.graceDollars * PMCMOD.sora_grace()))
				if d > 0 then
					return { dollars = d }
				end
			end
		end
		
	end,
	-- Grace of the City makes Index Keypages more likely (x2 each, capped by PMCMOD.bonus_weight).
	get_weight = function(self, weight)
		return PMCMOD.index_weight(weight, self and self.key)
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(localize('pmcmod_badge_index'), HEX('e0e0e0'), HEX('59a5e3'), 1.2 )
 	end,
	check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_troubadour" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end
}