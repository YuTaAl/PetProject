import random
import math


def LCM():
    numbers = [random.randint(1, 100) for _ in range(3)]
    correct_answer = str(math.lcm(numbers[0], numbers[1], numbers[2]))
    return numbers, correct_answer
