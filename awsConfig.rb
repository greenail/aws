require 'rubygems'
require 'right_aws'
require '../creds.rb'
require 'lib/My_Ami.rb'
key,skey = getCreds
logfile = File.new("/var/log/awsconfig.log", "a")

@ec2 = RightAws::Ec2.new(key,skey)
sdb = RightAws::SdbInterface.new(key,skey)

url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body

logfile.print "\nInstance ID: #{instance_id}"

lookup_table = My_AMI.new(sdb,"lookup",instance_id)
iname = lookup_table.cname
logfile.print " Index Name: #{iname}"
ami_type = lookup_table.ami_type
if (!ami_type)
	logfile.print "Could not find instance type Exiting"
	exit 1
end
logfile.print " AMI Type: #{ami_type}\n"
am = My_AMI.new(sdb,ami_type,iname)
exit 1 unless am

eip = am.eip
if (eip)
	#associate_address(instance_id, public_ip) 
	logfile.print "Attemptint to attach Elastic IP : #{eip} "
	result = @ec2.associate_address(instance_id,eip)
	logfile.print "#{result}\n"
end

hostname = am.hostname
if (hostname)
	logfile.print "Hostname found, trying to update: "
	result = `echo #{hostname} > /etc/hostname`	
	logfile.print result  
	result = `hostname #{hostname} `
	logfile.print result + "\n"
end
is_merb = false
if (am.cname.to_s =~ /merb\d/)
	is_merb = true
end
if (is_merb)
	logfile.print "Detected Merb Clone, restarting sytems\n"
	ip = "/etc/init.d"
	`#{ip}/nginx start`
	`#{ip}/monit restart`
	`#{ip}/collectd start`
	`elb-register-instances-with-lb schoch-lb --instances #{instance_id}`
	
	sleep 5
end
