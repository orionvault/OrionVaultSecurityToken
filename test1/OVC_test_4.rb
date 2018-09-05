require_relative "OVC_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

jump_to_ymd(2019, 12, 1, 0, 0, 0, -1)

###

@sot.txt 'Just before the first voting period'
@sot.exp :get_vote_nr, 0, nil
@sot.do

###

jump_to_ymd(2019, 12, 1, 0, 0, 0, 0)

###

@sot.txt 'First voting period start'
@sot.exp :get_vote_nr, 1, nil
@sot.exp :is_voting_open, true, nil
@sot.exp :get_last_vote_nr, 0, nil
@sot.do

###

@sot.txt 'Some votes'

@sot.add :cast_vote_for, @k[1]
@sot.add :cast_vote_for, @k[2]
@sot.add :cast_vote_against, @k[3]
@sot.add :cast_vote_against, @k[4]

@sot.exp :votes_against, [1], 350_000, 350_000
@sot.exp :votes_total, [1], 450_000, 450_000
@sot.exp :token_total, [1], 3_000_000, 3_000_000
@sot.exp :vote_result, [1], 0, nil
@sot.exp :claimed_team, [1], false, nil

@sot.do

###############################################################################

@sl.h1 'Impact of transfers'

###

jump_to_ymd(2020, 1, 1, 0, 0, 0, -1)

###

@sot.txt 'First voting period is still open!'
@sot.exp :get_vote_nr, 1, nil
@sot.exp :is_voting_open, true, nil
@sot.exp :get_last_vote_nr, 0, nil
@sot.do

###

@sot.txt 'Transfer (0) to (0)'
@sot.add :transfer, @k[5], @a[6], 10_000
@sot.exp :balance_of, @a[5], nil, -10_000
@sot.exp :balance_of, @a[6], nil, 10_000
@sot.exp :votes_against, [1], 350_000, 0
@sot.exp :votes_total, [1], 450_000, 0
@sot.do

###

@sot.txt 'Transfer (1) to (1)'
@sot.add :transfer, @k[1], @a[2], 10_000
@sot.exp :balance_of, @a[1], nil, -10_000
@sot.exp :balance_of, @a[2], nil, 10_000
@sot.exp :votes_against, [1], 350_000, 0
@sot.exp :votes_total, [1], 450_000, 0
@sot.do

###

@sot.txt 'Transfer (-1) to (-1)'
@sot.add :transfer, @k[3], @a[4], 10_000
@sot.exp :balance_of, @a[3], nil, -10_000
@sot.exp :balance_of, @a[4], nil, 10_000
@sot.exp :votes_against, [1], 350_000, 0
@sot.exp :votes_total, [1], 450_000, 0
@sot.do

###

@sot.txt 'Transfer (0) to (1)'
@sot.add :transfer, @k[6], @a[1], 10_000
@sot.exp :balance_of, @a[6], nil, -10_000
@sot.exp :balance_of, @a[1], nil, 10_000
@sot.exp :votes_against, [1], 350_000, 0
@sot.exp :votes_total, [1], 460_000, 10_000
@sot.do

###

@sot.txt 'Transfer (0) to (-1)'
@sot.add :transfer, @k[6], @a[3], 10_000
@sot.exp :balance_of, @a[6], nil, -10_000
@sot.exp :balance_of, @a[3], nil, 10_000
@sot.exp :votes_against, [1], 360_000, 10_000
@sot.exp :votes_total, [1], 470_000, 10_000
@sot.do

###

@sot.txt 'Transfer (1) to (0)'
@sot.add :transfer, @k[2], @a[5], 10_000
@sot.exp :balance_of, @a[2], nil, -10_000
@sot.exp :balance_of, @a[5], nil, 10_000
@sot.exp :votes_against, [1], 360_000, 0
@sot.exp :votes_total, [1], 460_000, -10_000
@sot.do

###

@sot.txt 'Transfer (1) to (-1)'
@sot.add :transfer, @k[1], @a[3], 10_000
@sot.exp :balance_of, @a[1], nil, -10_000
@sot.exp :balance_of, @a[3], nil, 10_000
@sot.exp :votes_against, [1], 370_000, 10_000
@sot.exp :votes_total, [1], 460_000, 0
@sot.do

###

@sot.txt 'Transfer (-1) to (0)'
@sot.add :transfer, @k[3], @a[6], 10_000
@sot.exp :balance_of, @a[3], nil, -10_000
@sot.exp :balance_of, @a[6], nil, 10_000
@sot.exp :votes_against, [1], 360_000, -10_000
@sot.exp :votes_total, [1], 450_000, -10_000
@sot.do

###

@sot.txt 'Transfer (-1) to (1)'
@sot.add :transfer, @k[4], @a[1], 10_000
@sot.exp :balance_of, @a[4], nil, -10_000
@sot.exp :balance_of, @a[1], nil, 10_000
@sot.exp :votes_against, [1], 350_000, -10_000
@sot.exp :votes_total, [1], 450_000, 0
@sot.do

###############################################################################

@sl.h1 'End of '

###

jump_to_ymd(2020, 1, 1, 0, 0, 0, 0)

###

@sot.txt 'First voting period is closed'
@sot.exp :get_vote_nr, 0, nil
@sot.exp :is_voting_open, false, nil
@sot.exp :get_last_vote_nr, 1, nil
@sot.exp :vote_result, [1], 0, nil
@sot.do

###

@sot.txt 'Claim team tokens'
@sot.add :process_vote, @admin_key, 1
@sot.exp :vote_result, [1], 1, nil
@sot.exp :balance_of, @owner_account, 375_000, 375_000
@sot.exp :tokens_issued_total, 3_375_000, 375_000
@sot.do

###


###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"
