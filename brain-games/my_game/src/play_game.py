def play_game(name, name_game):
    for _ in range(3):
        numbers, correct_answer = name_game()
        print("Question: "+' '.join(str(x) for x in numbers))
        answer = input("Your answer: ")
        if answer == correct_answer:
            print("Correct!")
        else:
            print(f"'{answer}' is wrong answer ;(. Correct answer was '{correct_answer}'.")
            print(f"Let's try again, {name}!")
    print(f"Congratulations, {name}!")
