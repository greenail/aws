require 'rubygems'
require 'right_aws'


class MetaAMI

attr_accessor :tname,:app,:eip,:ebs_vol,:hostname,:clone,:ebs_master

def initialize(sdb,type,instance_number,app)
        @sdb = sdb
        @domain = type
	@instance_number = instance_number
	@app = app
	@type = type
        @name = "#{@app}:#{@type}:#{@instance_number}"
        results = sdb.list_domains
        found = false
        #puts "Domain List: "
        for d in results[:domains]
                #puts "\t#{d}"
                if (d == @type)
                        found = true
                        puts "Found Domain: #{@type}, skipping Domain creation"
                end
        end
        @sdb.create_domain(@type) unless found
end
def self.parse_name(name)
    @app, @type,@instance_number = name.split(':')
end
def self.get(name,sdb)
    @sdb = sdb
    parse_name(name)
    @meta = @sdb.get_attributes(@type,name)
    a = @meta[:attributes]
    @app = a[:app]
    @eip = [:eip]
    @ebs_vol = [:ebs_vol]
    @ebs_master = [:ebs_master]
    @type = [:type]
    @clone = [:clone]
    #@ = [:]
    #@ = [:]
    return self
end
def self.lookup
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
