#!/usr/bin/ruby

require 'rubygems'
require 'right_aws'
require '/root/creds.rb'
key,skey = getCreds
require '/root/aws/sAws_tools.rb'
`mkdir /ebs`
logfile = File.new("/var/log/ebs.log", "a")
#logfile.print "#{Time.now}"



#  clone volumes from this instance
master_instance = 'i-28a05d40'
master_volume = 'vol-0dd62164'



url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body
logfile.print "MountEBS: #{Time.now}\tCurrent Instance ID: #{instance_id}\n"
@ec2 = RightAws::Ec2.new(key,skey)


#ec2.create_snapshot('vol-898a6fe0')

logfile.print "Creating Snapshot: \n"
snap = @ec2.create_snapshot(master_volume)
snap_id = snap[:aws_id]
wait_for_volume(snap_id,@ec2)
zone = "us-east-1b"
logfile.print "Converting Snapshot( #{snap_id} ) to Volume\n"
new_vol_from_snap = @ec2.create_volume(snap_id, 1, zone)
new_id = new_vol_from_snap[:aws_id]
logfile.print "Waiting for volume creation\n"
wait_for_volume(new_id,@ec2)
logfile.print "Deleting old snapshot\n"
@ec2.delete_snapshot(snap_id)
logfile.print "Attempting to attache new volume: #{new_id} to current instance\n"
@ec2.attach_volume(new_id,instance_id,'/dev/sdp')
wait_for_volume(new_id,@ec2)
logfile.print "Attempting to mount all volumes\n"
`mount -a`


