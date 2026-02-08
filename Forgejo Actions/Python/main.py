import requests
from rich import print
from rich.panel import Panel

def fetch_joke():
    url = "https://official-joke-api.appspot.com/random_joke"
    response = requests.get(url, timeout=5)
    response.raise_for_status()
    data = response.json()
    return f"{data['setup']}\n{data['punchline']}"

def main():
    print(Panel("Fetching a random joke...", style="bold cyan"))
    try:
        joke = fetch_joke()
        print(Panel(joke, title="Your Joke", style="green"))
    except Exception as e:
        print(Panel(f"Error: {e}", style="bold red"))

if __name__ == "__main__":
    main()
