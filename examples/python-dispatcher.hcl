job "python-dispatcher" {
  datacenters = ["thenest"]
  type = "batch"
  parameterized {
    payload       = "required"
    meta_required = []
    meta_optional = ["artifacts"]
  }
  group "dispatcher" {
    restart {
      attempts = 0
    }
    reschedule {
      attempts = 0
    }
    task "getter" {
      driver = "exec"
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      config {
        command = "./getter.sh"
      }
      template {
        perms = "755"
        destination = "getter.sh"
        data = <<EOF
#!/bin/bash 
cd $NOMAD_ALLOC_DIR
mkdir -p resources
cd resources
echo Current working directory: $PWD
IFS=','
read -ra ADDR <<< "$NOMAD_META_ARTIFACTS"
for a in "${ADDR[@]}"; do # access each element of array
    if [ "$a" != "" ]; then
      echo getting artifact "$a"
      wget "$a"
    fi
done
EOF
      }
    }
    task "dispatcher" {
      driver = "python"
      user = "pi"
      config {
        script = "local/script.py"
        # args = ["${NOMAD_META_arg}"]
      }
      dispatch_payload {
        file = "script.py"
      }
      resources {
        cpu = 3000
        memory = 32
        device "epaper" {}
      }
    }
  }
}
