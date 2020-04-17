job "not-a-python-dispatcher" {
  datacenters = ["thenest"]
  type = "batch"
  parameterized {
    payload       = "required"
    meta_required = []
    meta_optional = []
  }
  group "dispatcher" {
    restart {
      attempts = 0
    }
    reschedule {
      attempts = 0
    }
    task "dispatcher" {
      driver = "python"
      user = "pi"
      config {
        script = "local/script.py"
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
