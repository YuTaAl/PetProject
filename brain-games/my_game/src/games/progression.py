import random


def progression():
    counts = random.randint(2, 15)
    numbers = [random.randint(1, 20)]
    step = random.randint(10, 50)
    for _ in range(counts-1):
        numbers.append(numbers[-1]*step)

    index = random.randint(0, counts-1)
    correct_answer = str(numbers[index])
    numbers[index] = ".."
    return numbers, correct_answer
