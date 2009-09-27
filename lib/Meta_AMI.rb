require 'rubygems'
require 'right_aws'


class MetaAMI

attr_accessor :name,:app,:eip,:ebs_vol,:hostname,:clone,:ebs_master,:instance_number,:sdb,:instance_id
def initialize(sdb,options={})
    @sdb = sdb
    @name = options["name"]
    @app = options["app"]
    # TODO need to check for domain, and create if it does not exist
    @type = options["type"]
    @instance_number = options["instance_number"]

    # TODO need to do some meta programming here to make arbitrary list of attributes
    @eip = options["eip"]
    @hostname = options["hostname"]
    @ebs_vol = options["ebs_vol"]
    @ebs_master = options["ebs_master"]
    @type = options["type"]
    @clone = options["clone"]
    @instance_id = options["instance_id"]
    #@ = options[:]
    #@ = options[:]

    #  without these we can't pull the data from SDB
    if (@app == nil || @type == nil || @instance_number == nil)
	raise "Needed attributes not defined"
    end

    # test for name, if it is not in our options create it from input
    if (@name == nil)
	@name = "#{@app}:#{@type}:#{@instance_number}"
    end
    
    # we need a test for the apps table
end
def put_lookup(iid)
	@sdb.put_attributes("lookup",iid,{"name" => @name},:replace)
	@instance_id = iid
	self.save
end


def self.get(name,sdb)
    app,type,instance_number = parse_name(name)
    meta = @sdb.get_attributes(type,name)
    options = meta[:attributes]
    options["type"] = type
    options["app"] = app
    options["instance_number"] = instance_number
    self.new(sdb,options)
end
def self.lookup(iid,sdb)
    meta = sdb.get_attributes("lookup",iid)
    a = meta[:attributes]
    name = a["name"]
end
def self.cleanup(ec2)
    # method to clean out instance ID's that don't exist from our reverse lookup table
    instances = @sdb.select(["select * from lookup"])
    for i in instances[:items]
	for key in i.keys
		instance =  ec2.describe_instances(key)[0]
		if(instance)
		    state = instance[:aws_state]
		    puts "Checking State: #{state}"
		    # TODO  need test for other states such as "pending"
		    if (state != "running")
			puts "Deleting lookup record for: #{key}"
			@sdb.delete_attributes("lookup",key)
		    end
		else
			puts "Deleting lookup record for: #{key}"
                        @sdb.delete_attributes("lookup",key)	
		end
	end
    end
end
def self.create
end
def self.types(ec2)
    # not sure how we do this query without new table with only types, may 
    # want to put a bunch of this stuff in a single table with multiple things 
    # like this.
    #
    # we can also drive this via @ec2.describe_images_by_owner('self')

    result = ec2.describe_images_by_owner('self')
    for r in result
    	#puts "Testing: #{r[:aws_location]} against: -#{ami_type}-"
        location =  r[:aws_location].to_s
	base, crap = location.split('/')
	u,type,crap = base.split('-')
	puts "Type : #{type}"
    end
end
def self.apps
end

def save
    @meta = {:hostname => @hostname,:app => @app,:eip => @eip,:ebs_vol => @ebs_vol,:type => @type,:clone => @clone,:ebs_master => @ebs_master}
    @sdb.put_attributes(@type,@name,@meta,:replace)
end
def running?
    if(@iip)
	instance = @ec2.describe_instances(@iip)[0]
	if (instance[:aws_state] == "running")
		return true
	end
    end
end
def dprint
puts "name: #{@name} hostname: #{@hostname} app: #{@app} eip: #{@eip} EBS: #{@ebs_vol} type: #{@type}"
end


end # end class
