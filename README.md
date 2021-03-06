### Lambda Version Alias

This example provides house alias routing can be used in API Gateway and in Kinesis Streams (lambda event mapping to alias)

High level Steps

- The solution has "src" and "templates". src has the java sample lambda. templates have the .tf files. 
- Upon "mvn clean package" "target" folder will have the jar generated. 
- "exec.sh" has the aws cli/bash commands to deploy the lambda function and modify the alias accordingly

1) Initial Setup

	 - Build java source
	 - Run terraform templates to create API Gateway/Lambda. This pushes the above jar to the lambda
	 - Created API points to lambda:active alias. "red" and "black" aliases are also created at this point

2) Modify the code

	 - Run the "exec.sh". This is similar to GIT pipelines deploying the function
	 - At this point the the cli sets current version as red and new code being deployed as black
	 - cli sets the routing pointing to black and additional routing config weightage for the fallback/red


![Alt text](lambda%20alias%20routing.png?raw=true "Title")

##### Commands

$ cd templates
$ terraform init
$ terraform plan
$ terraform apply
[//]: # (Modify the java code) and execute the below shell script to modify the red/black version with old and new code

$ cd ..
$ chmod +x exec.sh
$ ./exec.sh

# Sample commands to push to Kinesis stream

aws kinesis put-record --stream-name ingest-redblack-kinesis --data "{\"id\": \"value1\"}" --partition-key 'id'
aws kinesis put-record --stream-name ingest-redblack-kinesis --data "{\"id\": \"value2\"}" --partition-key 'id'
aws kinesis put-record --stream-name ingest-redblack-kinesis --data "{\"id\": \"value3\"}" --partition-key 'id'
aws kinesis put-record --stream-name ingest-redblack-kinesis --data "{\"id\": \"value4\"}" --partition-key 'id'
aws kinesis put-record --stream-name ingest-redblack-kinesis --data "{\"id\": \"value5\"}" --partition-key 'id'
aws kinesis put-record --stream-name ingest-redblack-kinesis --data "{\"id\": \"value6\"}" --partition-key 'id'


### References

https://docs.aws.amazon.com/lambda/latest/dg/configuration-versions.html