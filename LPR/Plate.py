import pytesseract
from PIL import Image, ImageEnhance, ImageFilter


image_path = 'car2.jpg'

try:
    image = Image.open(image_path)
    
    # Preprocessing the image
    image = image.convert('L')  # Convert to grayscale
    image = image.filter(ImageFilter.MedianFilter())  # Apply a median filter
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(2)  # Increase contrast
    
    text = pytesseract.image_to_string(image, lang='ara')
    print(text)

except pytesseract.pytesseract.TesseractError as e:
    print('Tesseract Error:', e)
except Exception as e:
    print('General Error:', e)

print("Done")
