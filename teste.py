import boto3

s3_client = boto3.client('s3')


print("Hello from Python::::::::::::::::::::::::::::::::::::::")

f = open("result_job.txt","w+")
f.close() 

bucket_name = "pablosls-job-python-ec2"

print("File content ::::::::::::::::::::::::::::::::::::::")
# Download the file from S3
s3_client.download_file(bucket_name, 'data_to_process.csv', 'data_to_process.csv')
print(open('data_to_process.csv').read())

# Upload the file to S3
s3_client.upload_file('result_job.txt', bucket_name, 'result_job.txt')

print("End ::::::::::::::::::::::::::::::::::::::")
