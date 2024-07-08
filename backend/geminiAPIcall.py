import os
import google.generativeai as genai
from dotenv import load_dotenv

# Load environment variables from .env file (if it exists)
load_dotenv()

# Access your API key (corrected syntax)
api_key = os.environ.get('API_KEY')

# Check if API_KEY is set
if not api_key:
    print("Error: Please set the API_KEY environment variable.")
    exit(1)  # Exit the program with an error

# Configure genai with API key
genai.configure(api_key=api_key)

# ... rest of your code
model = genai.GenerativeModel('gemini-1.5-flash')

prompt = "Write a story about team rocket from pokemon."

response = model.generate_content(prompt)

print(response.text)
