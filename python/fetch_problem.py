from aocd.models import Puzzle
import os
from bs4 import BeautifulSoup
import requests


def get_soup_with_auth(day):
    token_path = os.path.expanduser("~/.config/aocd/token")
    with open(token_path) as f:
        session_token = f.read().strip()

    headers = {"Cookie": f"session={session_token}"}
    url = f"https://adventofcode.com/2024/day/{day}"
    response = requests.get(url, headers=headers)
    return BeautifulSoup(response.text, "html.parser")


def get_soup(html_content):
    return BeautifulSoup(html_content, "html.parser")


def create_python_template(day, dir_path):
    template = f"""from aocd import get_data, submit
import re

if __name__ == "__main__":
    raw_dat = get_data(day={day}, year=2024)

    # submit(f'{{}}', part="", day={day}, year=2024)
"""
    py_path = f"{dir_path}/{day}.py"
    with open(py_path, "w", encoding="utf-8") as f:
        f.write(template)


def process_text(text_content):
    soup = BeautifulSoup(text_content, "html.parser")

    titles = []
    for h2 in soup.find_all("h2"):
        titles.append(h2.get_text())
        h2.decompose()

    for code_elem in soup.find_all("code"):
        code_text = code_elem.get_text()
        code_elem.replace_with(f"\n```\n{code_text}\n```\n")

    for pre_elem in soup.find_all("pre"):
        pre_elem.replace_with("\n" + pre_elem.get_text() + "\n")

    for link in soup.find_all("a"):
        link.replace_with(link.get_text())

    for em in soup.find_all("em"):
        text = em.get_text()
        em.replace_with(f"*{text}*")

    main_text = soup.get_text()

    result = ""
    for title in titles:
        result += f"\n{title}\n\n"
    result += main_text

    return result


def fetch_problem(day):
    try:
        puzzle = Puzzle(year=2024, day=day)
        dir_path = f"solutions/{puzzle.year}/{day}"
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)

        # Get authenticated page content for part 2
        soup = get_soup_with_auth(day)
        all_articles = soup.find_all("article", class_="day-desc")

        # Get regular content for part 1
        prose = puzzle._get_prose()
        base_soup = get_soup(prose)
        part1_article = base_soup.find("article", class_="day-desc")

        if len(all_articles) > 1:
            md_path = f"{dir_path}/part2.md"
            with open(md_path, "w", encoding="utf-8") as f:
                f.write("\n\n-- Part Two ---\n\n")
                f.write(process_text(str(all_articles[1])))
        else:
            md_path = f"{dir_path}/part1.md"
            with open(md_path, "w", encoding="utf-8") as f:
                f.write(f"--- Day {day}: {puzzle.title} ---\n\n")
                f.write(process_text(str(part1_article)))

            # Only add part 2 if we have more than one article in authenticated response

        txt_path = f"{dir_path}/day{day}.txt"
        with open(txt_path, "w", encoding="utf-8") as f:
            f.write(puzzle.input_data)

        create_python_template(day, dir_path)
        print(f"Successfully fetched problem and input for day {day}")
        return True

    except Exception as e:
        print(f"Error fetching problem for day {day}: {str(e)}")
        return False


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        day = int(sys.argv[1])
        if not fetch_problem(day):
            print(f"Failed to fetch problem for day {day}")
    else:
        print("Please provide a day number")
