require "Ethereum.rb"
require "eth"


require_relative "./lib/utils.rb"


require_relative "./lib/Sot.rb"

##

@contract_address = "0xFe89bECFAC8DEd2c9905eBDbcB6d50310B95a3Dc"

##

@token = 'OVC'
@name = 'OrionVaultSecurityToken'

@owner_account = '0xb7C0b4e6156aacdaa767fb1515949d83948F889F'
@wallet_account = '0x6369dA8cedB7E360F82adde7fe4A92B443c424F9'
@admin_account = '0x643a3605038bb84439Ca686727FfF5aE34E944b7'


@owner_key = Eth::Key.new priv: 'bf91a52e415b3201d05e203ae95309d164dbe7acbb25bb21e485c7f9be242c60'
@admin_key = Eth::Key.new priv: '05e69e1129bc44976a5ccf4ea961d489ac54deafa980191eb9690e0deb1b3c03'

# ini variables

@E6, @E18, @DAY  = 10**18, 10**18, 24 * 60 * 60

# ini simple log

@sl = SimpleLog.new({:verbose => true})
@sl.p Time.now.utc

# test accounts

@acts = JSON.parse(File.read("acc/#{@token}.full.json"))
@imax = 10

# variables

@vars = %w[
at_now
owner
wallet
tokens_issued_total
max_token_supply
tokens_tradeable
team_unclaimed_tokens
dividend_total
dividend_residue
is_exchange_open
]

# basic mappings (address => something)

@maps = %w[
balance_of
dividend_tracker
]

# generic mappings

vote_numbers = (1..10).to_a

@gmaps = {
  :vote => [vote_numbers, :accounts],
  :votes_against => [vote_numbers],
  :votes_total   => [vote_numbers],
  :token_total   => [vote_numbers],
  :vote_result   => [vote_numbers],
  :claimed_team  => [vote_numbers],
}

# types

@types = {
  'get_balance' => :ether,
  'balance_of'  => :token,
  'at_now'      => :date,
  'tokens_issued_total' => :token,
  'team_unclaimed_tokens' => :token,
  'tokens_tradeable' => :bool,
}

# initialise contract

@client = Ethereum::HttpClient.new('http://127.0.0.1:8545')
@contract_abi = File.read('abi/abi.txt')

@sot = Sot.new(
  {
  :client   => @client,
  :name     => @name,
  :address  => @contract_address,
  :abi      => @contract_abi,
  :own_key  => @owner_key,
  :sl       => @sl,
  :acts     => @acts,
  :vars     => @vars,
  :maps     => @maps,
  :gmaps     => @gmaps,
  :types    => @types,
  :test_nr  => @test_nr,
  :imax     => @imax,
  :decimals => 0
  }
)
sot = @sot

@a  = @sot.a
@h  = @sot.h
@lk = @sot.lk
@k  = @sot.k

# sot.get_state
#
# sot.call [ 'e:get_balance', @a[300] ]
# sot.call [ 'balance_of', @a[300] ]
#
#output_pp(@sot.get_state(true), 'state.txt')


###############################################################################

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

def jump_to(epoch, label)
  @sot.txt "Jump to: " + label
  @sot.own :set_test_time, epoch
  @sot.exp :at_now, epoch
  @sot.do
end

def jump_to_ymd(yy, mm, dd, h=0, m=0, s=0, offset=0)
  epoch = Time.utc(yy, mm, dd, h, m, s).to_i + offset
  @sot.txt "Jump to: #{Time.at(epoch).utc}"
  @sot.own :set_test_time, epoch
  @sot.exp :at_now, epoch
  @sot.do
end

def d(i)
  return i*24*3600
end

def e(eth)
  return eth*@E18
end

