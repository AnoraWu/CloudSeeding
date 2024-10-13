import pandas as pd
import requests
from bs4 import BeautifulSoup as BS
import ast
from urllib.request import urlopen

def extract_words(url):
    try:
        # Set the timeout to 120 seconds (2 minutes)
        html = requests.get(url, timeout=120)
    except requests.Timeout:
        print(f"Timeout error: The request to {url} took longer than 2 minutes.")
        return "Error: Timeout"
    except Exception as e:
        print(f"Error opening url: {url}. Error: {e}")
        return "Error opening URL"
    
    html.encoding = 'utf-8'
    soup = BS(html.text, features="html.parser")
    text = soup.get_text(separator="\n").strip()
    
    # Try to find any specific 'desc' class divs
    descs = soup.find_all('div', {'class': 'desc'})
    
    if descs:
        for desc in descs:
            if '此网页未在微博完成域名备案' in desc.text.strip():
                # Follow the redirection URL and retry extracting text
                redirect_url = descs[0].text.strip()
                return extract_words(redirect_url)
    
    print(text)
    return text

if __name__ == '__main__':

    filename_list = ['微博数据_人影办_10-13','微博数据_人影办_14-17','微博数据_人影办_18-20','微博数据_人影办_21-23']
    
    for filename in filename_list:

        df = pd.read_csv(filename+'.csv',lineterminator='\n')
        df["网页信息"] = ""

        # Iterate over each row, except the first one
        for index, row in df.iloc[1:].iterrows():
            web_content = []
            urls = row["网页链接"]
            
            # Safely parse the list of URLs
            try:
                url_list = ast.literal_eval(urls)
            except (SyntaxError, ValueError) as e:
                print(f"Error parsing URLs in row {index}: {e}")
                url_list = []

            # Extract content from each URL in the list
            if url_list != []:
                for url in url_list:
                    try:
                        content = extract_words(url)
                        web_content.append(content)
                    except Exception as e:
                        print(f"Error fetching content from {url}: {e}")
                        web_content.append('Error')
            else:
                continue

            # Update DataFrame with the content for the current row
            df.at[index, "网页信息"] = web_content
            
            # Save the updated DataFrame row by row (with append mode)
            df.iloc[[index]].to_csv("{name}_带网页信息.csv".format(name=filename), mode='a', header=not index, index=False)
