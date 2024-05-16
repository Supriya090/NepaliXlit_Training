rom_vals = []
with open('final_transliteration.txt', 'r') as infile:
    for line in infile:
        each_line = line.strip()
        rom_vals.append(" ".join((each_line.split("-")[1]).split()))

with open('rom_vals.txt', 'a') as outfile:
    for val in rom_vals:
        outfile.write(f"{val}\n")