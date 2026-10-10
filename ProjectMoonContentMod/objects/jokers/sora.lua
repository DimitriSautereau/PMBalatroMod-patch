SMODS.Joker {
	key = 'sora',
	name = "Sora",
	pronouns = "she_her",
	config = { extra = { chips = 0, chips_mod = 20, mult = 0, xmult = 1, chargeStacks = 0, chargeHand = -1, soraDeathCounter = 0, rienPresent = false, rienPos = nil, locked = false, counter = 0 } },
	unlocked = true,
	eternal_compat = true,
	perishable_compat = true,
	blueprint_compat = true,
	rarity = 2,
	cost = 6,
    atlas = 'ModdedProjectMoon2',
	pos = { x =0, y = 6 },
	attributes = {'chips', 'editions', 'scaling', 'destroy_itself', 'position'},
    pools =
	{
		["Index"] = true,
 	},
	loc_vars = function(self, info_queue, card)
		
		if card.edition then
			card.children.center:set_sprite_pos({x = 0 , y = 11})
		end
		
		if card.ability.extra.locked then
			card.children.center:set_sprite_pos({x = 1 , y = 11})
		end



        return {vars = { card.ability.extra.chips, card.ability.extra.chips_mod, card.ability.extra.soraDeathCounter,
            PMCMOD.grace(), PMCMOD.karma(), card.ability.extra.mult, card.ability.extra.xmult, card.ability.extra.chargeStacks } }
	end,
	calculate = function(self, card, context)

		if context.before then
			card.ability.extra.rienPresent = false
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					card.ability.extra.currentPosition = i
					break
				end
			end

			if card.ability.extra.currentPosition <= #G.jokers.cards then
				for i = card.ability.extra.currentPosition, #G.jokers.cards do
					if G.jokers.cards[i].config.center.key == "j_pmcmod_rien" then
						card.ability.extra.rienPresent = true
						card.ability.extra.rienPos = i
						break
					end
				end
			end
			
		end

		if context.setting_blind and not card.ability.extra.locked and not context.blueprint then

			-- any Keypage holding an edition is fair game, however many Sora has taken already
			local editionJokers = {}
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] ~= card and G.jokers.cards[i].edition then
					editionJokers[#editionJokers + 1] = G.jokers.cards[i]
				end
			end

			if #editionJokers > 0 then
				local eligible_card = pseudorandom_element(editionJokers, 'sora')
				local stolen = eligible_card.edition.key
				eligible_card:set_edition()          -- it always leaves its owner

				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
				card.ability.extra.counter = 0

				if stolen == 'e_negative' then
					-- the one edition Sora wears rather than absorbs
					card:set_edition('e_negative', true)
				elseif stolen == 'e_foil' then
					card.ability.extra.chips = card.ability.extra.chips + 50
				elseif stolen == 'e_holo' then
					card.ability.extra.mult = card.ability.extra.mult + 10
				elseif stolen == 'e_polychrome' then
					card.ability.extra.xmult = card.ability.extra.xmult * 1.5
				elseif stolen == 'e_pmcmod_charge' then
					card.ability.extra.chargeStacks = card.ability.extra.chargeStacks + 1
				else
					card:set_edition(stolen, true)   -- unknown edition: keep the old behaviour
				end
			else
				card.ability.extra.counter = card.ability.extra.counter + 1

				if card.ability.extra.counter >= 3 then
					-- transforms. No doubling any more: everything absorbed carries over.
					card.ability.extra.locked = true
				end
			end

		end

		-- Charge stacks: Sora feeds the pool from them, and spends the usual 5 to buy extra triggers
		-- with each stack. Give and triggers both scale with the stacks, the spend never does.
		if card.ability.extra.chargeStacks > 0 then
			local rr = G.GAME.round_resets or {}
			local handKey = (rr.ante or 0) * 10000 + (G.GAME.round or 0) * 100 + ((G.GAME.current_round or {}).hands_played or 0)

			if context.individual and context.cardarea == G.play and not context.blueprint
				and card.ability.extra.chargeHand ~= handKey then
				card.ability.extra.chargeHand = handKey
				PMCMOD.add_charge(PMCMOD.charge_gain() * card.ability.extra.chargeStacks)
			end

			if context.repetition and context.cardarea == G.play and not context.blueprint
				and PMCMOD.get_charge() >= 5 then
				PMCMOD.add_charge(-5)
				return { repetitions = card.ability.extra.chargeStacks }
			end
		end

		if context.joker_main then

			local multiplier = 1

			if card.ability.extra.rienPresent then
				multiplier = 2
				if not context.blueprint then card.ability.extra.soraDeathCounter = card.ability.extra.soraDeathCounter + 1 end
			end

			if card.ability.extra.soraDeathCounter >= 5 then
				card.getting_sliced = true
				G.E_MANAGER:add_event(Event({func = function()
					card:start_dissolve({G.C.RED}, nil, 1.6)
				return true end }))
			end

			local ex = card.ability.extra
			local grace = PMCMOD.grace()
			local ret = {}

			if ex.locked then
				-- second form: Grace improves every channel, on top of what she absorbed
				ret.chips = ex.chips * multiplier * (1 + 1.5 * grace)
				ret.mult = ex.mult + 5 * grace
				local xm = ex.mult + 0.5 * grace
				if xm > 0 then ret.xmult = ex.xmult * xm end
			else
				ret.chips = ex.chips * multiplier
				if ex.mult > 0 then ret.mult = ex.mult end
				if ex.xmult ~= 1 then ret.xmult = ex.xmult end
			end

			return ret
		end
end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(localize('pmcmod_badge_spiders'), HEX('121212'), HEX('d90000'), 1.2 )
 	end,
	-- Rien on the team (times the Act) and Grace of the City both raise the odds of Sora showing up.
	get_weight = function(self, weight)
    	return PMCMOD.bonus_weight(weight, #SMODS.find_card('j_pmcmod_rien')*G.GAME.round_resets.ante + PMCMOD.grace())
	end,
	check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_pmcmod_rien" then
                if get_joker_win_sticker(v, true) >= 1 then
                    return true
                end
                break
            end
        end
    end
}