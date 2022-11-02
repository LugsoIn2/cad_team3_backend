from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework import status
from rest_framework import generics, filters
from django.http import JsonResponse
from datetime import datetime
import boto3
from django.conf import settings

# Dynamodb configuration
dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id=settings.AWS_ACCESS_KEY,
    aws_secret_access_key=settings.AWS_SECRET,
    region_name='eu-central-1')

# Get All Files
def list(request):
    table = dynamodb.Table('CAD_Team3')
    response = table.scan()
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        try:
            items = response['Items']
        except KeyError as e:
            print('Something went wrong')
        return JsonResponse(items, safe=False)

# Upload a File
def upload(request):
    # Get Parameters
    filebinary = request.FILES["file"]
    filename = request.POST.get('filename')
    title = request.POST.get('title')
    # Upload file to S3 Storage
    s3 = boto3.resource('s3')
    image = s3.Object('cad-team3-filebucket', filename)
    image.put(Body=filebinary)
    # Upload meta to DynamoDB
    table = dynamodb.Table('CAD_Team3')
    item = table.put_item(
        Item={
            'file': 'https://cad-team3-filebucket.s3.eu-central-1.amazonaws.com/' + filename,
            'filename': filename,
            'title': title,
            'timestamp': str(datetime.now())
        })
    # Return item
    return JsonResponse(item, safe=False) 
