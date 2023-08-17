from django.shortcuts import render
from django.http import HttpResponse
from .forms import UploadFileForm
# from django.core.files.storage import default_storage
from .models import Invoices
import json
import boto3
from botocore.exceptions import ClientError



def create_folder(bucket, subfolder):
    client = boto3.client('s3')
    # target_bucket = 's3-osk-bucket'
    # subfolder = 'esample'
    client.put_object(Bucket=bucket, Key=subfolder)


def transfer_file(source_bucket,
                   destination_bucket, filename, foldername):
    result = {'Filename' : filename}
    try:
        s3_resource = boto3.resource('s3')
        source = {
            'Bucket':source_bucket,
            'Key':filename
        }

        # create folder in destination
        create_folder(destination_bucket, foldername)

        destination_bucket_folder = "{}/{}".format(destination_bucket, foldername)
        s3_resource.meta.client.copy(source,destination_bucket,filename)
        s3_resource.Object(source_bucket, filename).delete()

        result['Status'] = 'Success'
    except ClientError as e:
        print(e)
        result['Status'] = 'Error' + e.response['Error']['Code']

    return result


def delete_file_from_bucket(bucket, filename):
    s3_resource = boto3.resource('s3')
    s3_resource.Object(bucket, filename).delete()


def upload_file(request):
    if request.method == 'POST':
        form = UploadFileForm(request.POST, request.FILES)
        file = request.FILES['file']
        
        invoice = Invoices(username="tahoors", pdf_file=file)
        invoice.save()

        file_name = str(file)
        if file_name[len(file_name)-3:] == 'pdf':
            return HttpResponse('The name of the uploaded file is: '+ str(file))
        else:
            return HttpResponse('Alert')
    else:
        form = UploadFileForm()

    return render(request, 'administration/upload.html', {'form': form})



# transfer_file('source_bucket_a', 'source_bucket_b.folder','se.example')