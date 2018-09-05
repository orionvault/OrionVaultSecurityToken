require_relative "OVC_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

@sl.h1 'Set wallet and other initial checks'

###

@sot.txt 'Set wallet'
@sot.own :set_wallet, @wallet_account
@sot.exp :wallet, @sot.strip0x(@wallet_account)
@sot.do

@sot.txt 'Initial checks'
@sot.exp :max_token_supply, 10_000_000, nil
@sot.exp :tokens_tradeable, false, nil
@sot.exp :is_exchange_open, false, nil
@sot.exp :available_to_mint, 8_500_000, nil
@sot.exp :get_vote_nr, 0, nil
@sot.exp :is_voting_open, false, nil

@sot.do


###############################################################################

@sl.h1 'Some minting'

###

@sot.txt 'Change max supply (initial is 10_000_000) and mint some'

@sot.own :change_max_token_supply, 4_500_000
@sot.own :mint_tokens, @a[1], 50_000
@sot.own :mint_tokens, @a[2], 100_000
@sot.own :mint_tokens, @a[3], 150_000
@sot.own :mint_tokens, @a[4], 200_000
@sot.own :mint_tokens, @a[5], 500_000
@sot.own :mint_tokens, @a[6], 750_000
@sot.own :mint_tokens, @a[7], 1_250_000
@sot.own :mint_tokens, @a[8], 1 # fail: over
@sot.add :transfer, @k[1], @a[2], 10_000 # fail: not transferable

@sot.exp :max_token_supply, 4_500_000, nil
@sot.exp :balance_of, @a[1], 50_000, 50_000
@sot.exp :balance_of, @a[2], 100_000, 100_000
@sot.exp :balance_of, @a[3], 150_000, 150_000
@sot.exp :balance_of, @a[4], 200_000, 200_000
@sot.exp :balance_of, @a[5], 500_000, 500_000
@sot.exp :balance_of, @a[6], 750_000, 750_000
@sot.exp :balance_of, @a[7], 1_250_000, 1_250_000
@sot.exp :balance_of, @a[8], 0, 0
@sot.exp :total_supply, 3_000_000, 3_000_000

@sot.do

###############################################################################

###

jump_to_ymd(2018, 1, 1)

###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"
