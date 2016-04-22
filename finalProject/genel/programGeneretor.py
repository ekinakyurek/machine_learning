import sys
import random
import math
args = sys.argv


class MyOperation:
    def __init__(self):
        self.operation = ''
        self.params = []
        self.codes = []

    def evaluate(self,values):
        self.params = values
        op = self.operation
        if op == '+':
            return self.params[0] + self.params[1]
        elif op == '-':
            return self.params[0] - self.params[1]
        elif op == '*':
            return self.params[0] * self.params[1]
        elif op == '<':
            return self.params[0] < self.params[1]
        elif op == '>':
            return self.params[0] > self.params[1]
        elif op == '==':
            return self.params[0] == self.params[1]
        elif op == 'for-':
            my_value = self.params[1]
            for x in range(self.params[0]): my_value -= self.params[2]
            return my_value
        elif op == 'for+':
            my_value = self.params[1]
            for x in range(self.params[0]): my_value += self.params[2]
            return my_value
        elif op == '=':
            return self.params[1]

    def generate(self, codes):
        self.codes = codes
        op = self.operation
        if op == '+':
            return codes[0] + " + " + codes[1]
        elif op == '-':
            return codes[0] + " - " + codes[1]
        elif op == '*':
            return codes[0] + " * " + codes[1]
        elif op == '<':
            return "if " + codes[0] + " < " + codes[1] + ":"
        elif op == '>':
            return "if " + codes[0] + " > " + codes[1] + ":"
        elif op == '==':
            return "if " + codes[0] + " == " + codes[1] + ":"
        elif op == 'for-':
            return "for x in range(" + codes[0] + "):" + codes[1] + "-=" +  codes[2]
        elif op == 'for+':
            return "for x in range(" + codes[0] + "):" + codes[1] + "+=" +  codes[2]
        elif op == '=':
            return codes[0] + " = " + codes[1]

    @property
    def getparamcount(self):
        op = self.operation
        if op == '+':
            return 2
        elif op == '-':
            return 2
        elif op == '*':
            return 2
        elif op == '<':
            return 2
        elif op == '>':
            return 2
        elif op == '==':
            return 2
        elif op == 'for-':
            return 3
        elif op == 'for+':
            return 3
        elif op == '=':
            return 2


length = int(args[1])
nesting = int(args[2])
max_number = math.pow(10, length + 1)
min_number = math.pow(10, length)
stack = []
Operations = ['+', '-', '*', '<','>','==', 'for-', '=', 'for+']

for i in range(1, nesting):
    operation = MyOperation()
    operation.operation = random.choice(Operations)
    Values = []
    Code = []
    for param in range(operation.getparamcount):
        if len(stack) != 0 and random.uniform(0, 1) < 0.5:
            value, code = stack.pop()
        else:
            value = int(random.uniform(min_number, max_number))
            code = str(value)
            print(value)

        Values.append(value)
        Code.append(code)
    new_value = operation.evaluate(Values)
    new_code = operation.generate(Code)
    stack.append((new_value, new_code))
print(stack)
final_value, final_code = stack.pop()
print(final_code)
