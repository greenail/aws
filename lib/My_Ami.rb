require 'rubygems'
require 'right_aws'


class My_AMI
attr_accessor :domain, :name
def initialize(sdb,domain, name)
	@sdb = sdb
	@domain = domain
	@name = name
	@meta = {}
	results = sdb.list_domains
	found = false
	#puts "Domain List: "
	for d in results[:domains] 
		#puts "\t#{d}"
		if (d == domain)	
			found = true	
			puts "Found Domain: #{domain}, skipping Domain creation"
		end
	end
	@sdb.create_domain(domain) unless found
end
def get(instance_id)
	meta = @sdb.get_attributes(@domain,@name)
	instance_id = meta[:instance_id]
end
def print_meta
	@meta = @sdb.get_attributes(@domain,@name)
	attributes = @meta[:attributes]
	for k in attributes.keys
		puts "#{k}: Values: #{attributes[k]}" unless k == "attributes"
	end
end
def ami_type
	meta = @sdb.get_attributes(@domain,@name)
	attributes = meta[:attributes]
        attributes['ami_type']
end
def ami_type=(ami_type)
	@meta['ami_type'] = ami_type
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end
def instance_id
	meta = @sdb.get_attributes(@domain,@name)
	attributes = meta[:attributes]
	instance_id = attributes['instance_id']
end
def instance_id=(id)
	@meta['instance_id'] = id
	@sdb.put_attributes(@domain, @name, @meta,:replace)
end

def create_domain(domain)
	result = @sdb.create_domain(domain)
	return result
end

def hostname
	#hostname = @sdb.get_attributes(@domain,'hostname')	
	meta = @sdb.get_attributes(@domain,@name)
	attributes = meta[:attributes]
        hostname = attributes['hostname']
end
def hostname=(hn)
	#@sdb.put_attributes(@domain, 'hostname',hn,:replace)
	@meta['hostname'] = hn
	@sdb.put_attributes(@domain, @name, @meta,:replace)
end

def is_clone?
	meta = @sdb.get_attributes(@domain,@name)
        attributes = meta[:attributes]
        is_clone = attributes['is_clone']
	if (is_clone == "true")
		return true
	else
		return false
	end
end
def is_clone=(clone)
	@meta['is_clone'] = clone
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end

def eip?

end

def eip=(eip)
	@meta['eip'] = eip
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end
def eip
	meta = @sdb.get_attributes(@domain,@name)
        attributes = meta[:attributes]
        hostname = attributes['eip']


end

def ebs_vol
	meta = @sdb.get_attributes(@domain,@name)
        attributes = meta[:attributes]
        ebs_vol = attributes['ebs_vol']

end
def ebs_vol=(ebs_vol)
	@meta['ebs_vol'] = ebs_vol
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end
def cname
        meta = @sdb.get_attributes(@domain,@name)
        attributes = meta[:attributes]
        cname = attributes['cname']

end
def cname=(cname)
        @meta['cname'] = cname
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end
def app
        meta = @sdb.get_attributes(@domain,@name)
        attributes = meta[:attributes]
        app = attributes['app']

end
def app=(app)
        @meta['app'] = app
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end

def security_group
        meta = @sdb.get_attributes(@domain,@name)
        attributes = meta[:attributes]
        security_group = attributes['security_group']

end
def security_group=(security_group)
        @meta['security_group'] = security_group
        @sdb.put_attributes(@domain, @name, @meta,:replace)
end



end

