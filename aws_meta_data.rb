require 'rubygems'
#require 'dm-core'
require 'right_aws'
require '/root/creds.rb'
require 'lib/My_Ami.rb'
key,skey = getCreds()
sdb = RightAws::SdbInterface.new(key,skey)
sb = My_AMI.new(sdb,"lookup",'i-97894bff')



