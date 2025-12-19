job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  type        = "service"
  namespace   = [[ var "namespace" . | quote ]]
  datacenters = [[ var "datacenters" . | toPrettyJson ]]
  
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "evcc" {
    count = 1

    ephemeral_disk {
      migrate = true
      size    = 300
      sticky  = true
    }

    network {
        [[ if var "network_mode" . ]]
        mode = [[ var "network_mode" . | quote ]]
        [[- end ]]
        port "frontend" { to = 443 }
        port "ocpp" { to = 8887 }
    }

    service {

      name = "evcc"
      port = "frontend"
      [[ if var "frontend_service_tags" . ]]
      tags = [[ var "frontend_service_tags" . | toPrettyJson]]
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
    service {
      [[ if var "ocpp_service_tags" . ]]
      tags = [[ var "ocpp_service_tags" . | toPrettyJson]]
      [[- end ]]

      name = "ocpp-evcc"
      port = "ocpp"
    }


      [[ if var "vault_policy" . ]]
      vault {
        policies  = [ [[ var "vault_policy" . | quote ]] ]
        change_mode   = "signal"
        change_signal = "SIGINT"
      }
      [[- end ]]
    task "evcc" {
      driver = "docker"


      config {
        image = "[[ var "image" . ]]:[[ var "version_tag" . ]]"
        ports = ["frontend", "ocpp"]
        mount {
          type   = "bind"
          source = "configs/configuration.yaml"
          target = "/etc/evcc.yaml"
        }
        [[ if var "data_mount" . ]]
        mount { 
            type = "bind"
            source = [[ var "data_mount" . | quote ]]
            target = "/root/.evcc/"
        }
        [[- end ]]
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
        left_delimiter = [[ var "left_delimiter" . | quote ]]
        right_delimiter = [[ var "right_delimiter" . | quote ]]
        data        = <<EOH
[[ var "configfile" . ]]
EOH
  
      }

    }
  }
}
