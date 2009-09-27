require '/root/creds.rb'
require 'rubygems'
require 'right_aws'
key,skey = getCreds


if (ARGV[0] == nil)
	puts "Usage bundle <your imagename>" 
	exit 1
end
`rm -rf /mnt/bundleimage`
`mkdir /mnt/bundleimage`

s3 = RightAws::S3.new(key,skey)
bucket = "schoch-#{ARGV[0]}-ami"
b = s3.bucket(bucket)
if (b == nil)
    b = RightAws::S3::Bucket.create(s3,bucket,true)
    b.keys
end
@ec2 = RightAws::Ec2.new(key,skey)
url = 'http://169.254.169.254/2008-02-01/meta-data/instance-id'
instance_id = Net::HTTP.get_response(URI.parse(url)).body
#ec2.bundle_instance('i-e3e24e8a', 'my-awesome-bucket', 'my-win-image-1')

#ignore, this is for bundling windows 
#@ec2.bundle_instance(instance_id,bucket,bucket)

result = `ec2-bundle-vol -d /mnt/bundleimage -u 2118-4602-5673 -r i386 -k /root/pk-XOCQDQQQHX4ME7OR6RRJV6Y6SIMJRRXK.pem -c /root/cert-XOCQDQQQHX4ME7OR6RRJV6Y6SIMJRRXK.pem -r i386 -e /ebs`
puts result

result = `ec2-upload-bundle -b #{bucket} -m /mnt/bundleimage/image.manifest.xml -a AKIAIDT73TXLB4XHLPJA -s +zj29X2jsaq+rKD/Te114ZCdWik8yJyur+XvBQ12`

puts result 

#url = 'http://169.254.169.254/2008-02-01/meta-data/ami-id'
#old_image = Net::HTTP.get_response(URI.parse(url)).body

result = @ec2.describe_images_by_owner('self')
for r in result
	if ( r[:aws_location] == "#{bucket}/image.manifest.xml" )
		@ec2.deregister_image(r[:aws_id])
	end
end

image = @ec2.register_image("#{bucket}/image.manifest.xml")
puts image



