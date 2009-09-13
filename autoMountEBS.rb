#!/usr/bin/ruby

require 'rubygems'
require 'right_aws'
require 'net/http'
require '../creds.rb'
require 'sAws_tools.rb'
key,skey = getCreds()

url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body

AMAZON_PUBLIC_KEY=key
AMAZON_PRIVATE_KEY=skey
EC2_LOG_VOL='vol-09ab5a60'

ec2 = RightAws::Ec2.new(AMAZON_PUBLIC_KEY, AMAZON_PRIVATE_KEY)

vol = ec2.attach_volume(EC2_LOG_VOL, instance_id, '/dev/sdp')
puts vol

# It can take a few seconds for the volume to become ready.
# This is just to make sure it is ready before mounting it.
sleep 20

system('mount -a')
