require 'rubygems'
require 'right_aws'
require '../creds.rb'
key,skey = getCreds
`touch /root/itworked.txt`


@ec2 = RightAws::Ec2.new(key,skey)
sdb = RightAws::SdbInterface.new(key,skey)

url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body
am = My_AMI.new(sdb,"merb",instance_id)

eip = am.eip
if (eip)
	#associate_address(instance_id, public_ip) 
	@ect.associate_address(instance_id,eip)
end

hostname = am.hostname
if (hostname)
	`echo #{hostname} > /etc/hostname`	
	`hostname #{hostname} `
end

