job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  type        = "service"
  namespace   = [[ var "namespace" . | quote ]]
  datacenters = [[ var "datacenters" . | toPrettyJson ]]
  
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = "${[[ $constraint.attribute ]]}"
    value     = "[[ $constraint.value ]]"
    [[- if ne $constraint.operator "" ]]
    operator  = "[[ $constraint.operator ]]"
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "zigbee2mqtt" {
    count = 1

    ephemeral_disk {
      migrate = true
      size    = 300
      sticky  = true
    }

    network {
      port "frontend" {
        to = 8080
      }
    }

    service {

      name = "zigbee2mqtt"
      port = "frontend"
      [[ if var "service_tags" . ]]
      tags = [[ var "service_tags" . | toPrettyJson]]
      [[- end ]]

      check {
        name     = "alive"
        type     = "http"
        port     = "frontend"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "zigbee2mqtt" {
      driver = "docker"
      config {
        image = "docker.io/koenkk/zigbee2mqtt:[[ var "version_tag" . ]]"
        ports = ["frontend"]
        mount {
          type   = "bind"
          source = "configs/configuration.yaml"
          target = "/app/data/configuration.yaml"
        }
        [[ if var "data_mount" . ]]
        mount { 
            type = "bind"
            source = [[ var "data_mount" . | quote ]]
            target = "/app/data/"
        }
        [[- end ]]
        mount { 
            type = "bind"
            source = "/run/udev"
            target = "/run/udev"
        }
        devices = [
            {
                host_path = "[[ var "zigbee_device" . ]]"
                container_path = "[[ var "zigbee_device" . ]]"
            }
        ]
      }
    resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
    }
    env {
        TZ = "Europe/Vienna"
    }

      template {
        destination = "configs/configuration.yaml"
        change_mode = "restart"
        data        = <<EOH
[[ var "configfile" . ]]
EOH
  
      }

    }
  }
}
