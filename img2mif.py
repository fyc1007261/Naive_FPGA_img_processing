import cv2
import numpy as np

img = cv2.imread("xmas-hat.png")
row_n, col_n, _ = img.shape
for i in range(row_n):
    for j in range(col_n):
        index = i * row_n + j
        print("{} : {:02X}{:02X}{:02X};".format(index, *img[i, j][::-1]))