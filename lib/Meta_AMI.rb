require 'rubygems'
require 'right_aws'


class MetaAMI

attr_accessor :name,:app,:eip,:ebs_vol,:hostname,:clone,:ebs_master,:instance_number,:sdb
def initialize(sdb,options={})
    @sdb = sdb
    @name = options["name"]
    @app = options["app"]
    @eip = options["eip"]
    @type = options["type"]
    @hostname = options["hostname"]
    @instance_number = options["instance_number"]
    @ebs_vol = options["ebs_vol"]
    @ebs_master = options["ebs_master"]
    @type = options["type"]
    @clone = options["clone"]
    @iid = options["iid"]
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
		    # TODO  need test for other states
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
def self.types
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
