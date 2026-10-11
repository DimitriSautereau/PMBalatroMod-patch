SMODS.Joker {
	key = 'sora',
	no_pool_flag = 'sora_extinct',
	name = "Sora",
	pronouns = "she_her",
	config = { extra = { chips = 0, chips_mod = 20, mult = 0, xmult = 1, chargeStacks = 0, chargeHand = -1, chargeSpendHand = -1, chargeTriggers = 0, doubleReception = -1, lastReception = -1, soraDeathCounter = 0, rienPresent = false, rienPos = nil, locked = false, counter = 0 } },
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

		-- she carries the Charge edition's rules once she has absorbed one
		if card.ability.extra.chargeStacks > 0 then
			info_queue[#info_queue + 1] = G.P_CENTERS.e_pmcmod_charge
		end



		-- the stats as the player will actually get them, i.e. after the net-Grace factor, plus how
		-- many times her keypage triggers this hand
		local ex = card.ability.extra
		local factor = ex.locked and (1 + 0.1 * PMCMOD.sora_grace()) or 1
		local here = (G.GAME.round_resets.ante or 0) * 10000 + (G.GAME.round or 0)
		local triggersNow = 1 + (((ex.doubleReception == here) and 1) or 0) + (ex.chargeTriggers or 0)

        return {vars = { ex.chips, ex.chips_mod, PMCMOD.pair_trigger_display(card),
            PMCMOD.grace(), PMCMOD.karma(), ex.mult, ex.xmult, ex.chargeStacks, PMCMOD.sora_grace(),
            ex.chips * factor, ex.mult * factor, ex.xmult * factor, triggersNow } }
	end,
	-- taken once and never offered again
	add_to_deck = function(self, card, from_debuff)
		if G.GAME then G.GAME.pool_flags.sora_extinct = true end
	end,
	calculate = function(self, card, context)
		-- the pairing is locked in at the start of the Scene and held for it
		if context.setting_blind and not context.blueprint then
			card.ability.extra.rienPresent = PMCMOD.pair_linked(card)
		end

		if context.before then
			-- Rien has to be exactly to her left (she is the apprentice)
		end

		-- three Receptions WITHOUT stealing and she reveals her second form. Gated on setting_blind,
		-- which fires exactly once per Scene - running this on every calculate call, keyed on
		-- G.GAME.round, advanced it several times inside a single Scene.
		if context.setting_blind and not card.ability.extra.locked and not context.blueprint then
			card.ability.extra.dryReceptions = (card.ability.extra.dryReceptions or 0) + 1
			if card.ability.extra.dryReceptions >= 3 then
				card.ability.extra.locked = true
			end
		end

		if context.setting_blind and not card.ability.extra.locked and not context.blueprint then

			-- any Keypage holding an edition is fair game, however many Sora has taken already
			local wearingNegative = card.edition and card.edition.key == 'e_negative'
			local editionJokers = {}
			local priority = nil
			for i = 1, #G.jokers.cards do
				local other = G.jokers.cards[i]
				-- Rien sits directly to her left (she is the apprentice): his Edition goes first
				if other == card then
					local father = G.jokers.cards[i - 1]
					if father and father.config.center.key == "j_pmcmod_rien" and father.edition
						and not (wearingNegative and father.edition.key == 'e_negative') then
						priority = father
					end
				end
				-- she wears one Negative and never takes a second
				if other ~= card and other.edition
					and not (wearingNegative and other.edition.key == 'e_negative') then
					editionJokers[#editionJokers + 1] = other
				end
			end

			if priority or #editionJokers > 0 then
				card.ability.extra.dryReceptions = 0   -- a steal restarts the three-Reception count
				local eligible_card = priority or pseudorandom_element(editionJokers, 'sora')
				local stolen = eligible_card.edition.key
				eligible_card:set_edition()          -- it always leaves its owner


				if stolen == 'e_negative' then
					-- the one edition Sora wears rather than absorbs, and the only steal that pays
					card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
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

			-- 5 Charge buys her own keypage another trigger, once per hand. This used to sit in
			-- context.repetition - the card-retrigger context - which is why she retriggered played
			-- cards. Per stack her keypage triggers once more, for the same single spend.
			if context.joker_main and not context.blueprint then
				-- starts fresh every hand: only a spend made in this hand counts
				card.ability.extra.chargeTriggers = 0
			end

			if context.joker_main and not context.blueprint and PMCMOD.get_charge() >= 5
				and card.ability.extra.chargeSpendHand ~= handKey then
				card.ability.extra.chargeSpendHand = handKey
				PMCMOD.add_charge(-5)
				card.ability.extra.chargeTriggers = card.ability.extra.chargeStacks
				card_eval_status_text(card, 'extra', nil, nil, nil, {
					message = localize('pmcmod_chargeSpend'),
					colour = G.C.BLUE,
				})
			end
		end

		if context.joker_main then

			local reception = (G.GAME.round_resets.ante or 0) * 10000 + (G.GAME.round or 0)

			-- The counter rises once per Reception, but she triggers twice for the rest of it.
			if card.ability.extra.rienPresent and card.ability.extra.doubleReception ~= reception then
				card.ability.extra.doubleReception = reception
				if not context.blueprint then PMCMOD.add_pair_trigger(card, 1) end
			end
			local doubleTrigger = card.ability.extra.doubleReception == reception and 1 or 0

			if PMCMOD.pair_triggers(card) >= 5 then
				card.getting_sliced = true
				G.E_MANAGER:add_event(Event({func = function()
					card:start_dissolve({G.C.RED}, nil, 1.6)
				return true end }))
			end

			local ex = card.ability.extra
			local ret = {}
			-- Her keypage triggers once, plus once per Charge stack spent on it, plus the
			-- adjacency double. Each trigger applies the whole effect again.
			local triggers = 1 + (ex.chargeTriggers or 0) + doubleTrigger

			if ex.locked then
				-- second form: the net Grace (Grace less Karma, which can go negative) is added to
				-- each channel on top of what she absorbed
				local sg = PMCMOD.sora_grace()
				local factor = 1 + 0.1 * sg
				ret.chips = ex.chips * factor * triggers
				ret.mult = ex.mult * factor * triggers
				local xm = ex.xmult * factor
				if xm > 0 then ret.xmult = xm ^ triggers end
			else
				ret.chips = ex.chips * triggers
				if ex.mult > 0 then ret.mult = ex.mult * triggers end
				if ex.xmult ~= 1 then ret.xmult = ex.xmult ^ triggers end
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