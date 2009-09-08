#!/usr/bin/ruby

require 'rubygems'
require 'right_aws'
require 'creds.rb'
key,skey = getCreds

logfile = File.new("/var/log/ebs.log", "a")
#logfile.print "#{Time.now}"

#  clone volumes from this instance
master_instance = 'i-28a05d40'
master_volume = 'vol-0dd62164'



url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body
logfile.print "uMountEBS: #{Time.now}\tCurrent Instance ID: #{instance_id}\n"
@ec2 = RightAws::Ec2.new(key,skey)

my_volume = ""
all_volumes = @ec2.describe_volumes
for vol in all_volumes
        instance = vol[:aws_instance_id]
        if instance == instance_id
                logfile.print "Found Master Instance: volume id: #{vol[:aws_id]}.\n"
                my_volume = vol[:aws_id]
        end
end
if ( my_volume == "")
	puts "No Volumes!!!"
	logfile.print "No volume found!!! #{Time.now}\n" unless my_volume != ""
	exit 1
end
logfile.print "This would be a good place to copy logs and stuff\n"


logfile.print "Unmounting Data Partition: \n"
`umount /ebs`
logfile.print "Detaching Volume\n"
@ec2.detach_volume(my_volume)
sleep 30

#logfile.print "Forcing Detach for good measure\n"
#@ec2.detach_volume(my_volume ,force=true)
#sleep 30


logfile.print "Deleting Volume\n"
@ec2.delete_volume(my_volume)
sleep 30
logfile.print "Finished on #{Time.now}\n"


