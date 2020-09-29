f = open("ip.txt")
op = open("opSingle.txt","w")
input = f.readlines()
for n,line in enumerate(input):
    input[n] = line.split(" - ")
# print(input)

input.sort(key = lambda x: x[1])

for line in input:
    print(line)
    for i in range(int(line[1])):
        if len(line) == 3:
            op.write(line[0]+"~"+str(int(line[2])))
        else:
            op.write(line[0]+"~1000")
        op.write("\n")
