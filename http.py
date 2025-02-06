import requests

# List of URLs to connect to
urls = [
    "http://www.google.com",
    "http://www.example.com",
    "http://www.github.com"
]

# Iterate over each URL in the list
for url in urls:
    # Make a GET request to fetch data
    try:
        response = requests.get(url)
        
        # Check if the connection is successful
        if response.status_code == 200:
            print(f"Successfully connected to {url}.")
            print("Response content:")
            print(response.text)  # Printing the HTML content of the page
        else:
            print(f"Failed to connect to {url}.")
            print("Status code:", response.status_code)
    except requests.exceptions.RequestException as e:
           print(f"An error occurred while trying to connect to {url}: {e}")
