SMODS.Seal {
    key = 'sinWrath',
    atlas = "ModdedProjectMoonEditions",
    pos = { x = 6, y = 4 },
    config = {    },
    badge_colour = G.C.RED,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then

            local randomValue = pseudorandom('pmcmod_sinWrath_branch', 0, 10)

            local slothCount = 0

            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.seal == "pmcmod_sinSloth" then slothCount = slothCount + 1 end
            end

            local slothCountChips = slothCount * 2
            local normal = (G.GAME.probabilities and G.GAME.probabilities.normal) or 1
            local growth = 1.2 ^ slothCount

            -- 1.2 ^ Sloth in 10: the seal consumes the card and leaves Burn behind
            if not SMODS.has_enhancement(card, 'm_pmcmod_burn')
                and pseudorandom('pmcmod_sinWrath_toBurn') < (normal * growth) / 10 then
                card:set_ability(G.P_CENTERS.m_pmcmod_burn, nil, true)
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize('pmcmod_sinWrath_burn'), colour = G.C.RED,
                })
            end

            -- 1.2 ^ Sloth in 20: it passes itself to a card that carries no seal
            if pseudorandom('pmcmod_sinWrath_spread') < (normal * growth) / 20 then
                local candidates = {}
                for _, playing_card in ipairs(G.playing_cards or {}) do
                    if playing_card ~= card and not playing_card.seal and not playing_card.debuff then
                        candidates[#candidates + 1] = playing_card
                    end
                end
                if #candidates > 0 then
                    local target = pseudorandom_element(candidates, pseudoseed('pmcmod_sinWrath_spread'))
                    target:set_seal('pmcmod_sinWrath', nil, true)
                    card_eval_status_text(target, 'extra', nil, nil, nil, {
                        message = localize('pmcmod_sinWrath_spread'), colour = G.C.RED,
                    })
                end
            end
            

            if randomValue <= 6 then
                card.ability.perma_bonus = (card.ability.perma_bonus or 0) + pseudorandom('pmcmod_sinWrath_chips', 0, 8) + slothCountChips
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
                }
            elseif randomValue >=7 and randomValue <= 9 then
                card.ability.perma_mult = (card.ability.perma_mult or 0) + pseudorandom('pmcmod_sinWrath_mult', 0, 4) + slothCount
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT
                }
            else
                card.ability.perma_p_dollars = (card.ability.perma_p_dollars or 0) + 1
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.GOLD
                }
            end

        end
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end
}