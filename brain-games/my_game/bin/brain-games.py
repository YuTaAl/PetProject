from ..src.play_game import play_game
from ..src.cli import hello
from ..src.games.LCM import LCM
from ..src.games.progression import progression


def main():
    name = hello()
    print(f"What game do you want to play, {name}?)")
    print("1) LCM")
    print("2) Progression")
    code = input("Enter game code : ")

    if code == "1":
        print("Write a least common multiple")
        play_game(name, LCM)
    elif code == "2":
        print("Write a missing element of the geometric progression")
        play_game(name, progression)
    else:
        print("Sorry, incorrect game code, try again!")


if __name__ == "__main__":
    main()
