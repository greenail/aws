#!/usr/bin/ruby

require 'rubygems'
require 'right_aws'
require 'creds.rb'
key,skey = getCreds
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
mounted_volumes = []
#all_volumes = @ec2.describe_volumes
#for vol in all_volumes
	#instance = vol[:aws_instance_id]
	#if instance == master_instance
		#logfile.print "Found Master Instance: volume id: #{vol[:aws_id]}.  "
		#mounted_volumes << vol[:aws_id]
	#end
#end

#for vol in mounted_volumes
	logfile.print "Creating Snapshot: \n"
	#snap = @ec2.create_snapshot(vol)
	snap = @ec2.create_snapshot(master_volume)
	sleep 30
	snap_id = snap[:aws_id]
	# ec2.create_volume('snap-000000', 10, zone)
	zone = "us-east-1b"
	logfile.print "Converting Snapshot( #{snap_id} ) to Volume\n"
	new_vol_from_snap = @ec2.create_volume(snap_id, 1, zone)
	sleep 30
	@ec2.delete_snapshot(snap_id)
	new_id = new_vol_from_snap[:aws_id]
	sleep 30
	logfile.print "Attempting to attache new volume: #{new_id} to current instance\n"
	@ec2.attach_volume(new_id,instance_id,'/dev/sdp')
#end
logfile.print "Attempting to mount all volumes\n"
`mount -a`


