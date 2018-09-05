require_relative "OVC_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

@sl.h1 'No votes during second voting period'

jump_to_ymd(2020, 7, 10, 0, 0, 0, 0)

###

@sot.txt 'After 2nd voting period - no votes'
@sot.exp :is_voting_open, false, nil
@sot.exp :get_last_vote_nr, 2, nil
@sot.exp :vote_result, [2], 0, nil
@sot.do

###

@sot.txt 'Claim team tokens'
@sot.add :process_vote, @admin_key, 2
@sot.exp :vote_result, [2], 1, nil
@sot.exp :balance_of, @owner_account, 750_000, 375_000
@sot.exp :tokens_issued_total, 3_750_000, 375_000
@sot.do

###


###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"
