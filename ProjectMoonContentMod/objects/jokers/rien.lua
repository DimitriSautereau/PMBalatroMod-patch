SMODS.Joker {
	key = 'rien',
	no_pool_flag = 'rien_extinct',
	name = "Rien",
	pronouns = "he_him",
	config = { extra = { mult = 0, mult_mod = 15,  graceXchips = 0.2, karmaXmult = 0.9, karmaChips = 50, prescriptListShuffled = {}, prescriptActive = false, currentPrescript = 0, soraPresent = false, soraPos = nil, soraDeathCounter = 0, allowPrescriptCheck = false } },
	unlocked = true,
	eternal_compat = true,
	perishable_compat = true,
	blueprint_compat = true,
	rarity = 3,
	cost = 8,
    atlas = 'ModdedProjectMoon2',
	pos = { x = 5, y = 5 },
	attributes = {'mult', 'economy', 'destroy_card', 'destroy_itself', 'scaling', 'position'},
    pools =
	{
		["Index"] = true,
 	},
	loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.mult, PMCMOD.pair_trigger_display(card), card.ability.extra.mult_mod,
			PMCMOD.grace(), PMCMOD.karma(), card.ability.extra.graceXchips, card.ability.extra.karmaXmult, card.ability.extra.karmaChips } }
	end,
	-- Rien carries the Karmic Consequence; destroying or selling him clears it.
	remove_from_deck = function(self, card, from_debuff)
		if not from_debuff and G.GAME then G.GAME.pmcmod_karma = 0 end
	end,
	-- taken once and never offered again
	add_to_deck = function(self, card, from_debuff)
		if G.GAME then G.GAME.pool_flags.rien_extinct = true end

		-- Shuffles prescripts
        local prescriptListUnshuffled = {"j_pmcmod_prescript1", "j_pmcmod_prescript2", "j_pmcmod_prescript3", "j_pmcmod_prescript4", "j_pmcmod_prescript5", "j_pmcmod_prescript6", "j_pmcmod_prescript7", "j_pmcmod_prescript8", "j_pmcmod_prescript9", "j_pmcmod_prescript10", "j_pmcmod_prescript11"}
		card.ability.extra.prescriptListShuffled = Shuffle(prescriptListUnshuffled, 'pmcmod_rien_prescripts')
    end,
	calculate = function(self, card, context)
		-- the pairing is locked in at the start of the Scene and held for it
		if context.setting_blind and not context.blueprint then
			card.ability.extra.soraPresent = PMCMOD.pair_linked(card)
		end


		if context.joker_type_destroyed then


			card.ability.extra.soraPresent = false
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					card.ability.extra.currentPosition = i
					break
				end
			end

			-- only the partner exactly on the correct side counts


			

			if PMCMOD.pair_triggers(card) >= 3 and card.ability.extra.soraPresent then

				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i] == card then
						card.ability.extra.currentPosition = i
						break
					end
				end

				for i = card.ability.extra.currentPosition, #G.jokers.cards do
					if G.jokers.cards[i].config.center.key == "j_pmcmod_sora" then
						card.ability.extra.soraPos = i
					end
				end
				G.GAME.banned_keys["j_pmcmod_sora"] = true
				local sora = G.jokers.cards[card.ability.extra.soraPos]
				PMCMOD.set_pair_trigger(card, 0)
				sora.getting_sliced = true
				G.E_MANAGER:add_event(Event({func = function()
					card:juice_up(0.8, 0.8)
					sora:start_dissolve({G.C.RED}, nil, 1.6)
				return true end }))
			end


		end


		if context.setting_blind and not context.blueprint and not card.edition then
			-- Sora exactly to his right: the Index hands him a random Edition
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					local right = G.jokers.cards[i + 1]
					if right and right.config.center.key == "j_pmcmod_sora" then
						local edition = SMODS.poll_object({ type = 'Edition', guaranteed = true,
							seed = 'pmcmod_rien_edition' .. (G.GAME.round_resets.ante or 0) .. (G.GAME.round or 0) })
						if edition then card:set_edition(edition, true) end
					end
					break
				end
			end
		end

		if context.joker_main then
			-- Grace of the City pays out, Karmic Consequence takes its cut.
			local grace = PMCMOD.grace()
			local karma = PMCMOD.karma()
			local ret = {
				mult = card.ability.extra.mult + card.ability.extra.mult_mod * grace,
				xmult = card.ability.extra.karmaXmult ^ karma,
			}
			if grace > 0 then ret.xchips = card.ability.extra.graceXchips * grace end
			if karma > 0 then ret.chips = -card.ability.extra.karmaChips * karma end
			return ret
		end

    end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge(localize('pmcmod_badge_spiders'), HEX('121212'), HEX('d90000'), 1.2 )
 	end,
	get_weight = function(self, weight)
    	return PMCMOD.bonus_weight(weight, #SMODS.find_card('j_pmcmod_sora')*G.GAME.round_resets.ante + PMCMOD.grace())
	end,
	check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_flower_pot" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end
}