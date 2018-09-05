require_relative "OVC_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################


@sl.h1 'Some minting'

###

@sot.txt 'Reduce token supply - not possible'
@sot.own :change_max_token_supply, 4_499_000
@sot.exp :max_token_supply, 4_500_000, nil
@sot.do

###

@sot.txt 'Dividend - not owner'
@sot.snd @admin_key, 1
@sot.exp :dividend_total, 0, 0
@sot.exp :dividend_residue, 0, 0
@sot.do

###

@sot.txt 'Dividend - owner'
@sot.snd @owner_key, 1
@sot.exp :dividend_total, 333_333_333_333, 333_333_333_333
@sot.exp :dividend_residue, 1_000_000, 1_000_000
@sot.do

###

@sot.txt 'Claim some dividends'
@sot.add :claim_dividend, @k[3], @a[1]
@sot.add :claim_dividend_multiple, @k[5], [@a[2], @a[3], @a[4]]
@sot.exp :dividend_tracker, @a[1], 333_333_333_333, 333_333_333_333
@sot.exp :dividend_tracker, @a[2], 333_333_333_333, 333_333_333_333
@sot.do

###

@sot.txt 'Make tradeable'
@sot.own :make_tradeable
@sot.exp :tokens_tradeable, true, nil
@sot.do

###

@sot.txt 'Transfer some tokens and check '
@sot.add :transfer, @k[2], @a[5], 50_000
@sot.exp :balance_of, @a[2], 50_000, -50_000
@sot.exp :balance_of, @a[5], 550_000, 50_000
@sot.exp :dividend_tracker, @a[2], 333_333_333_333, 0
@sot.exp :dividend_tracker, @a[5], 333_333_333_333, 333_333_333_333
@sot.do

###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"
