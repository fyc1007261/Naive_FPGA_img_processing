import cv2
import numpy as np

img = cv2.imread("google.png")
row_n, col_n, _ = img.shape

print("DEPTH = 10000;")
print("WIDTH = 24;")
print("ADDRESS_RADIX = DEC;")
print("DATA_RADIX = HEX;")
print("CONTENT")
print("BEGIN")


for i in range(row_n):
    for j in range(col_n):
        index = i * row_n + j
        print("{} : {:02X}{:02X}{:02X};".format(index, *img[i, j][::-1]))

print("END;")