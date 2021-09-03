# frozen_string_literal: true

require 'ruby-asterisk'
require 'logger'
require 'json'
ASTER = 'ASTERISK_IP_ADDRESS'
PORT = 5038
USER = 'ASTERISK_MANAGER_USERNAME'
PASS = 'ASTERISK_MANAGER_PASSWORD'
DEBUG = true
logger = Logger.new('extract.log', 'monthly')
logger.info 'start'

begin
  res = {}
  loop do
    @ami = RubyAsterisk::AMI.new(ASTER, PORT)
    @ami.login(USER, PASS)
    peers = @ami.sip_peers.data
    arr = peers[:peers]
    sip_arr = []
    arr.each do |a|
      sip_arr << a['ObjectName']
    end
    p sip_arr if DEBUG
    sip_arr.each do |s|
      data = @ami.sip_show_peer(s).data[:hints][0]['SIP-Useragent'].to_s
      if data != ''
        p s,  data if DEBUG
        res[s] = data
      end
    end
    p res if DEBUG
    File.write('report.json', JSON.pretty_generate(res))
    sleep(60)
  end
rescue StandardError => e
  logger.error e
end
logger.info 'finish'
