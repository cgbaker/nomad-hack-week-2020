import sys
import os
import time

from PIL import ImageFont

import inkyphat

colour = os.environ.get("INKYPHAT_COLOR", "red")

try:
    inkyphat.set_colour(colour)
except ValueError:
    print('Defaulting to "red"')

inkyphat.set_border(inkyphat.RED)
inkyphat.set_image("alloc/resources/hello-badge.png")

font = ImageFont.truetype(inkyphat.fonts.AmaticSCBold, 38)

name = "Nomad Hack Week"

w, h = font.getsize(name)

# Center the text and align it with the name strip

x = (inkyphat.WIDTH / 2) - (w / 2)
y = 71 - (h / 2)

inkyphat.text((x, y), name, inkyphat.BLACK, font)

inkyphat.show()
