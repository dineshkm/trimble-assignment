import boto3
from botocore.vendored import requests
from botocore.exceptions import ClientError
import csv
import os

HTTP_ENDPOINT=None
SERVICE_TAG_VALUES = ["Data", "Processing", "Web"]
REGION="us-west-2"
BUCKET="compliance-error-inventory"

def find_service_tag_values():
    if HTTP_ENDPOINT:
        response = requests.get(url=HTTP_ENDPOINT)
        res_json = response.json()
        SERVICE_TAG_VALUES = res_json["SERVICE_TAG_VALUES"]

def get_ec2_client():
    client = boto3.client('ec2',region_name=REGION)
    return client

def get_s3_client():
    client = boto3.client('s3',region_name=REGION)
    return client

def get_running_instances():
    ec2_client = get_ec2_client()
    response = ec2_client.describe_instances(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )
    all_running_instances = []
    for reservation in response['Reservations']:
        instances = reservation['Instances']
        for instance in instances:
            instance_minimal_data = {
                "ImageId"       : instance['ImageId'],
                "InstanceId"    : instance['InstanceId'],
                "InstanceType"  : instance['InstanceType'],
                "Tags"          : instance["Tags"]
            }
            all_running_instances.append(instance_minimal_data)                        

    return all_running_instances

def check_instances_tag():
    running_instances = get_running_instances()
    instances_without_tag = []
    for instance in running_instances:    
        tags = instance["Tags"]
        tag_service_found = False
        error = None
        for tag in tags:
            if tag['Key'] == 'Service':
                tag_service_found = True
                if not tag['Value'] in SERVICE_TAG_VALUES:
                    error = "For Tag: '"+tag["Key"]+"' Value: '"+tag['Value']+"' is not from the allowed values: '"+", ".join(SERVICE_TAG_VALUES)+"'"
        if not tag_service_found:
            error = "Tag 'Service' is not found"
        if error:
            instance["Error"] = error
            instances_without_tag.append(instance)
    return instances_without_tag

def upload_inventory_to_s3(problematic_instances):    
    csv_file = "/tmp/inventory.csv"
    filename = "inventory.csv"
    csv_columns = ["ImageId", "InstanceId", "InstanceType", "Tags", "Error"]
    s3_client = get_s3_client()
    mode='w'
    try:
        # download s3 csv file to lambda tmp folder
        s3_client.download_file(BUCKET,filename,csv_file)
        mode='a'
        print("inventory downloaded")
    except Exception as e:
        print("inventory not found already")
    
    try:
        with open(csv_file, mode) as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
            writer.writeheader()
            for instance in problematic_instances:                
                writer.writerow(instance)
    except IOError:
        print("Error creating CSV file")

    # Upload the file
    try:
        s3_client.upload_file(csv_file, BUCKET, "inventory.csv")
    except ClientError as e:
        print(e)

def alert_tag_compliance(problematic_instances,test=False):
    
    if not test:
        print("Alert!!!! Problematic instances are below")
        print(problematic_instances)
    upload_inventory_to_s3(problematic_instances)


def lambda_handler(event, context):
    test = False
    if not os.environ.get('test'):
        test = os.environ.get('test').lower() == "true"
    
    print("Test2",test)
    find_service_tag_values()
    problematic_instances = check_instances_tag()
    alert_tag_compliance(problematic_instances,test)
    return {
    "statusCode": 200,
    "body": problematic_instances
    }