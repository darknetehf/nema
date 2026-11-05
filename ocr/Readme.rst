OCR
===

The problem: you have been given scans of documents, but you are unable to search inside these documents, let alone copy-paste text.
The solution: use OCR to extract text from images.

You will need the following open-source software packages:

- Tesseract (OCR tool)
- poppler (provides pdftoppm)
- ImageMagick (for image processing)

These tools are easy to install on a Linux system, but should be available on other platforms.

On Arch Linux, the packages required would be:
- tesseract
- tesseract-data-isl (data files for the Icelandic language)
- poppler

On other Linux systems, the package names may sometimes vary.

The process is as follows:

Step 1: extract images from PDF files

Tesseract cannot process PDF files directly, so you have to extract the images from the PDF files.
This snippet will process all .pdf files in the current directory and output each page to a numbered image file (in PNG format).

NB: pdftoppm is generally preferred over pdfimages.

.. code:: bash

   for file in *.pdf; do pdftoppm -png -rx 300 -ry 300 "$file" "${file%.pdf*}"; done

Verify that the images are rendered correctly before proceeding to the next step.

Step 2: optional - rotate all images

You can change the orientation of the images, if they are turned upside down.
OCR will work regardless of image orientation.

For example, this snippet will rotate all images by 90 degrees, counter-clockwise and replace the original files:

.. code:: bash

   magick mogrify -rotate -90 *.png

Step 3: process images with Tesseract and recreate PDF

.. code:: bash

   ls *.jpg | tesseract -l isl - Almenn_málfræði txt pdf
