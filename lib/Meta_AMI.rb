require 'rubygems'
require 'right_aws'


class MetaAMI

attr_accessor :name,:app,:eip,:ebs_vol,:hostname,:clone,:ebs_master,:instance_number,:sdb
#def initialize(sdb,name,meta)
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
    # test for instance id, if we have one create lookup record
    if (@iid != nil)
        @sdb.put_attributes("lookup",@iid,@name,:replace)
    end
    
    # we need a test for the apps table
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

end
def self.cleanup
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
end
def dprint
puts "name: #{@name} hostname: #{@hostname} app: #{@app} eip: #{@eip} EBS: #{@ebs_vol} type: #{@type}"
end


end # end class
