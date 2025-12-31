import sys
from collections import defaultdict

def find_xmas(grid, rows, cols):
    directions = [
        (-1, -1), (-1, 0), (-1, 1),  # top-left, top, top-right
        (0, -1),          (0, 1),     # left, right
        (1, -1),  (1, 0),  (1, 1)     # bottom-left, bottom, bottom-right
    ]
    
    found = defaultdict(str)
    target = "XMAS"
    
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] != 'X':  # Only start checking if we find an 'X'
                continue
                
            # Check all 8 directions
            for dy, dx in directions:
                word = ""
                coords = []
                
                # Try to build "XMAS" in this direction
                for i in range(4):  # XMAS is 4 letters
                    new_r, new_c = r + (dy * i), c + (dx * i)
                    
                    # Check bounds
                    if 0 <= new_r < rows and 0 <= new_c < cols:
                        word += grid[new_r][new_c]
                        coords.append((new_r, new_c))
                    else:
                        break
                        
                if word == target:
                    # Store using your coordinate format
                    coord_key = f"{r}, {c} - {coords[-1][0]}, {coords[-1][1]}"
                    found[coord_key] = word
                    
    return len(found)

# Read input
if len(sys.argv) < 2:
    raise Exception("please provide a filename")

with open(sys.argv[1], 'r') as file:
    grid = [list(line.strip()) for line in file]

rows, cols = len(grid), len(grid[0])
print(find_xmas(grid, rows, cols))
