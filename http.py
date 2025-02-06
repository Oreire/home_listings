import requests
import boto3
import numpy 

# URL to connect to
url = "http://www.google.com"


# Make a GET request to fetch data
response = requests.get(url)

# Check if the connection is successful
if response.status_code == 200:
    print("Successfully connected to the internet.")
    print("Response content:")
    print(response.text)  # Printing the HTML content of the page
else:
    print("Failed to connect to the internet.")