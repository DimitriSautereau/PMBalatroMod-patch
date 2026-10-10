SMODS.Joker {
	key = 'nikolai',
	name = "Nikolai",
	pronouns = "she_her",
	config = { extra = { mult = 0, mult_mod = 5, rcorpXmult = 1.5, savedJokers = {}, highlightedJokerStatus = "" } },	
	unlocked = false,
	eternal_compat = true,
	perishable_compat = true,
    blueprint_compat = true,
	rarity = 3,
	cost = 8,
	atlas = 'ModdedProjectMoonTrue',
	pos = { x = 3, y = 3 },
	attributes = {'mult', 'scaling'},
	pools =
	{
        ["RCorp"] = true,
 	},
	loc_vars = function (self, info_queue, card)


		if G.GAME.blind then
			if G.jokers.highlighted[1] then
				card.ability.extra.highlightedJokerStatus = localize('pmcmod_nikolaiCataloguedFalse')
				for i=1, #card.ability.extra.savedJokers do
					if card.ability.extra.savedJokers[i] == G.jokers.highlighted[1].config.center.key then
						card.ability.extra.highlightedJokerStatus = localize('pmcmod_nikolaiCataloguedTrue')
						break
					end
				end
			else
				card.ability.extra.highlightedJokerStatus = ""
			end
		end

    	return {vars = { card.ability.extra.mult, card.ability.extra.mult_mod, card.ability.extra.highlightedJokerStatus, card.ability.extra.rcorpXmult }}
	end,
	calculate = function(self, card, context)
		
        if context.buying_card and context.card.ability.set == "Joker" and not context.blueprint then

            local cardAlreadySaved = false

            if #card.ability.extra.savedJokers >=1 then
                for i=1, #card.ability.extra.savedJokers do
                   if card.ability.extra.savedJokers[i] == context.card.config.center.key then
                        cardAlreadySaved = true
                    break
                   else
                        cardAlreadySaved = false
                   end
                end
            end

            if cardAlreadySaved == false then
                card.ability.extra.savedJokers[#card.ability.extra.savedJokers + 1] = context.card.config.center.key
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            end

        end

		if context.joker_main then
			-- R Corp keypages give x1.5 Mult each while Nikolai is held. They compound:
			-- three of them is 1.5^3 = x3.375.
			local rcorp = 0
			local jokers = (G.jokers and G.jokers.cards) or {}
			for i = 1, #jokers do
				local pools = jokers[i].config and jokers[i].config.center and jokers[i].config.center.pools
				if pools and pools.RCorp then rcorp = rcorp + 1 end
			end
			local ret = { mult = card.ability.extra.mult }
			if rcorp > 0 then
				ret.xmult = card.ability.extra.rcorpXmult ^ rcorp
			end
			return ret
		end
		
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(localize('pmcmod_badge_RCorp'), HEX('2e2b2b'), HEX('c4560c'), 1.2 )
 	end,
	check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_abstract" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end
}