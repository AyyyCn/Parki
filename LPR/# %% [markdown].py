
# %%
import cv2
from matplotlib import pyplot as plt
import numpy as np
import imutils
import easyocr
from IPython.display import display
from PIL import Image, ImageEnhance, ImageFilter

# %% [markdown]
# ## 1. Read in Image, Grayscale and Blur
import io
import sys

# Set the default encoding to UTF-8
#sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# %%
img = cv2.imread('aa.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
plt.imshow(cv2.cvtColor(gray, cv2.COLOR_BGR2RGB))

# Adaptive Thresholding
adaptive_thresh = cv2.adaptiveThreshold(
    gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
)
plt.imshow(cv2.cvtColor(adaptive_thresh, cv2.COLOR_BGR2RGB))
plt.show()

# Morphological operations
kernel = np.ones((3,3),np.uint8)
dilation = cv2.dilate(adaptive_thresh, kernel, iterations = 1)
erosion = cv2.erode(dilation, kernel, iterations = 1)

plt.imshow(cv2.cvtColor(erosion, cv2.COLOR_BGR2RGB))
plt.show()
# Noise Removal
noise_removal = cv2.bilateralFilter(erosion,9,75,75)

plt.imshow(cv2.cvtColor(noise_removal, cv2.COLOR_BGR2RGB))
plt.show()


# %% [markdown]
# ## 2. Apply filter and find edges for localization


edged = cv2.Canny(noise_removal, 30, 200) #Edge detection
plt.imshow(cv2.cvtColor(edged, cv2.COLOR_BGR2RGB))



# %% [markdown]
# ## 3. Find Contours and Apply Mask

# %%
keypoints = cv2.findContours(edged.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
contours = imutils.grab_contours(keypoints)
contours = sorted(contours, key=cv2.contourArea, reverse=True)[:10]

# %%
location = None
for contour in contours:
    approx = cv2.approxPolyDP(contour, 10, True)
    if len(approx) == 4:
        location = approx
        break

# %%
location

# %%
mask = np.zeros(gray.shape, np.uint8)
new_image = cv2.drawContours(mask, [location], 0,255, -1)
new_image = cv2.bitwise_and(img, img, mask=mask)

# %%
plt.imshow(cv2.cvtColor(new_image, cv2.COLOR_BGR2RGB))

# %%
(x,y) = np.where(mask==255)
(x1, y1) = (np.min(x), np.min(y))
(x2, y2) = (np.max(x), np.max(y))
cropped_image = gray[x1:x2+1, y1:y2+1]

# %%
plt.imshow(cv2.cvtColor(cropped_image, cv2.COLOR_BGR2RGB))

# %% [markdown]
# ## 4. Use Easy OCR To Read Text

# %%
reader = easyocr.Reader(['ar'])
result = reader.readtext(cropped_image)
result

# %% [markdown]
# ## 5. Render Result

# %%
for i in range(len(result)):
    display(result[i][-2])




