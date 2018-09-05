require_relative "OVC_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

jump_to_ymd(2019, 6, 30)

###

@sot.txt 'Another dividend'
@sot.snd @owner_key, 2
@sot.exp :dividend_total, 1_000_000_000_000, 666_666_666_667
@sot.exp :dividend_residue, 0, -1_000_000
@sot.do

###

@sot.txt 'Claim a dividend'
@sot.add :claim_dividend, @admin_key, @a[1]
@sot.exp :get_balance, @a[1], nil, 16_666_666_666_650_000
@sot.exp :get_balance, @contract_address, nil, -16_666_666_666_650_000
@sot.do

###

@sot.txt 'Transfer some tokens (act 5 had received dividend 1, act 6 had not yet received any dividend)'
@sot.add :transfer, @k[5], @a[6], 100_000
@sot.exp :balance_of, @a[5], 450_000, -100_000
@sot.exp :balance_of, @a[6], 850_000, 100_000
@sot.exp :dividend_tracker, @a[5], 1_000_000_000_000, 666_666_666_667
@sot.exp :dividend_tracker, @a[6], 1_000_000_000_000, 1_000_000_000_000
@sot.exp :get_balance, @a[5], nil,  333_333_333_333_500_000 
@sot.exp :get_balance, @a[6], nil,  750_000_000_000_000_000 
@sot.exp :get_balance, @contract_address, nil, - 1_083_333_333_333_500_000 
@sot.do

###

@sot.txt 'Transfer some tokens to an account that was empty'
@sot.add :transfer, @k[5], @a[8], 100_000
@sot.exp :balance_of, @a[5], 350_000, -100_000
@sot.exp :balance_of, @a[8], 100_000, 100_000
@sot.exp :dividend_tracker, @a[5], 1_000_000_000_000, 0
@sot.exp :dividend_tracker, @a[8], 1_000_000_000_000, 1_000_000_000_000
@sot.exp :get_balance, @a[5], nil,  0
@sot.exp :get_balance, @a[6], nil,  0
@sot.exp :get_balance, @contract_address, nil, 0
@sot.do

###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"
