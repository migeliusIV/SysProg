def int_repr(x):
    while (x > 10):
        print(x % 10)
        x = x // 10
    print(x)
    return

a = 3372
b = 35
print()
int_repr(a)