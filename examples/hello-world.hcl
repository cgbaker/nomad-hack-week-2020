job "hello-world" {
  datacenters = ["thenest"]
  type = "batch"
  group "hello" {
    restart {
      attempts = 0
    }
    reschedule {
      attempts = 0
    }
    task "inky-python-hello" {

      driver = "python"
      user = "pi"
      config {
        script = "local/hello.py"
      }

      artifact {
        source = "https://github.com/pimoroni/inky-phat/raw/master/examples/resources/hello-badge.png"
        destination = "local/hello-badge.png"
        mode = "file"
      }

      template {
        destination = "local/hello.py"
        data = <<EOF
import sys
import os
import time

from PIL import ImageFont

import inkyphat

colour = os.environ.get("INKYPHAT_COLOR", "red")
print "using color ", colour

try:
    inkyphat.set_colour(colour)
except ValueError:
    print('Defaulting to "red"')

inkyphat.set_border(inkyphat.RED)
inkyphat.set_image("local/hello-badge.png")

font = ImageFont.truetype(inkyphat.fonts.AmaticSCBold, 38)

name = "Nomad Hack Week"

w, h = font.getsize(name)

# Center the text and align it with the name strip

x = (inkyphat.WIDTH / 2) - (w / 2)
y = 71 - (h / 2)

inkyphat.text((x, y), name, inkyphat.BLACK, font)

if inkyphat.get_version() == 1:
    inkyphat.set_partial_mode(56, 96, 0, inkyphat.WIDTH)

inkyphat.show()

print "Sleeping for a bit"
time.sleep( 5 )
print "Done"
EOF
      }

      resources {
        cpu = 1500
        memory = 32
        device "epaper" {}
      }
    }
  }
}
