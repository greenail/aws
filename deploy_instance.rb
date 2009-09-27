require 'rubygems'
require 'right_aws'
require '/root/creds.rb'
require 'lib/Meta_AMI.rb'
key,skey = getCreds()

if (ARGV[0] == nil || ARGV[1] == nil || ARGV[2] == nil)
	puts "Usage: launch <instance type> <application name> <instance_number>"
	exit 1
end 
ami_type = ARGV[0]
app = ARGV[1]
instance_number = ARGV[2]
# TODO need to figure out if this is a new instance, or replacement

@ec2 = RightAws::Ec2.new(key,skey)
sdb = RightAws::SdbInterface.new(key,skey)

# get ami that matches type
result = @ec2.describe_images_by_owner('self')
for r in result
	if (r[:aws_location].to_s =~ /-#{ami_type}-/)
		puts "Found image match in: #{r[:aws_location]}"
		merb_ami_id = r[:aws_id]
	end
end
if (merb_ami_id == '')
	puts "Could not find ami for type: #{ami_type}"
	exit 1
end
puts "Launching AMI Image ID: #{merb_ami_id}"
# TODO, need to add ssh key name to metadata
# TODO, need to check that security group exists
# TODO, need to figure out how to deal with Availability Zones
results = @ec2.launch_instances(merb_ami_id, :addressing_type => "public",:group_ids => ami_type,:key_name => 'test1',:availability_zone => "us-east-1b") 
puts "Printing results of launch"

for result in results
	for key in result.keys
		puts "\t#{key} ---- #{result[key]}"
	end
end

instance_id = results[0][:aws_instance_id]
if (instance_id)
	puts "Adding instance meta data for Instance: #{instance_id}"
	puts "..."
	# TODO need to figure out why lack of domain does not throw an answer
	mami = MetaAMI.new(sdb,{"type" => ami_type,"app" => app,"instance_number" => instance_number})
	mami.put_lookup(instance_id)
	if (mami)
		mami.put_lookup(instance_id)
		mami.hostname = "merb1.stink.net"
		mami.eip = "174.129.23.27"
		mami.clone = "false"
		mami.app = app
		mami.instance_id = instance_id 
		puts "Saving Meta AMI info"
		mami.save
	else
		puts "problem with ami meta data or sdb"
	end
end



