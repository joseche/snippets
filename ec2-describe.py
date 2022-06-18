#!/usr/bin/env python

# query the instances in all regions, dump specific attrs into a csv file
# optionally filter the instances


import csv
import jmespath
import boto3
import os

# Get list of regions
ec2_client = boto3.client("ec2")
regions = [region["RegionName"] for region in ec2_client.describe_regions()["Regions"]]

# Get list of EC2 attributes for all regions
instances = []
# for region in ["us-west-1"]:
for region in regions:
    current_session = boto3.Session(region_name=region)
    client = current_session.client("ec2")
    response = client.describe_instances()
    output = jmespath.search(
        "Reservations[].Instances[].[NetworkInterfaces[0].OwnerId, InstanceId, InstanceType, \
        State.Name, Placement.AvailabilityZone, PrivateIpAddress, IamInstanceProfile.Arn, KeyName, [Tags[?Key=='Name'].Value] [0][0]]",
        response,
    )
    [
        instances.append(instance)
        for instance in output
        if not instance[3] == "terminated"  # ignore terminated instances
    ]

# if you want to filter instance by a specific field
filtered = [instance for instance in instances if not instance[6]]

# Write instances to CSV file with headers
with open("ec2-inventory-latest.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(
        [
            "AccountID",
            "InstanceID",
            "Type",
            "State",
            "AZ",
            "PrivateIP",
            "InstanceProfile",
            "KeyPair",
            "Name",
        ]
    )
    writer.writerows(instances)
    # writer.writerows(filtered)
