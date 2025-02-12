# Generate key pair and set permissions (all on one line)
aws ec2 create-key-pair --key-name my-instance-key > my-instance-key.pem && chmod 400 my-instance-key.pem &&

# Launch instance (replace AMI ID and security group ID)
instance_id=$(aws ec2 run-instances --image-id ami-078c688b7999805d2 --instance-type t2.micro --key-name my-instance-key --placement AvailabilityZone=ap-southeast-1a --security-groups <your_security_group_id> --user-data file://user_data.sh --output text --query 'Instances[*].InstanceId') &&

# Get public IP
public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text) &&

# Connect to instance
ssh -i my-instance-key.pem ec2-user@$public_ip