require 'rubygems'
require 'right_aws'
require '../creds.rb'
require 'lib/My_Ami.rb'
key,skey = getCreds
`touch /root/itworked.txt`


@ec2 = RightAws::Ec2.new(key,skey)
sdb = RightAws::SdbInterface.new(key,skey)

url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body
lookup_table = My_AMI.new(sdb,"lookup",instance_id)
iname = lookup_table.cname
type = lookup_table.type
am = My_AMI.new(sdb,type,iname)
exit 1 unless am

eip = am.eip
if (eip)
	#associate_address(instance_id, public_ip) 
	@ec2.associate_address(instance_id,eip)
end

hostname = am.hostname
if (hostname)
	`echo #{hostname} > /etc/hostname`	
	`hostname #{hostname} `
end
is_merb = false
if (am.cname =~ /merb\d/)
	is_merb = true
end
if (is_merb)
	ip = "/etc/init.d"
	`#{ip}/nginx start`
	`#{ip}/monit restart`
	`#{ip}/collectd start`
	
	sleep 5
end
