import sys

def find_xmas(grid, rows, cols):
    directions = [
        (-1, -1), (-1, 1),  # top-left, top-right
              (0, 0),       # middle
        (1, -1), (1, 1)     # bottom-left, bottom-right
    ]
    
    count = 0
    targets = [
        "MSAMS", "MMASS", "SMASM", "SSAMM" 
    ]
    
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] != 'A':  # Only start checking if we find an 'X'
                continue
                
            word = ""
            # Check all 8 directions
            for dy, dx in directions:
                
                # Try to build "XMAS" in this direction
                new_r, new_c = (r + dy), (c + dx)
                    
                # Check bounds
                if 0 <= new_r < rows and 0 <= new_c < cols:
                    word += grid[new_r][new_c]
                else:
                    break
                        
            for target in targets:
                if word == target:
                    count += 1
                    
                    
    return count

# Read input
if len(sys.argv) < 2:
    raise Exception("please provide a filename")

with open(sys.argv[1], 'r') as file:
    grid = [list(line.strip()) for line in file]

rows, cols = len(grid), len(grid[0])
print(find_xmas(grid, rows, cols))
#     M M   S M   S S   M S   S 
#      A     A     A     A   MAS
#     S S   S M   M M   M S
