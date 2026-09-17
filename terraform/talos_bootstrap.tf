# # resource "time_sleep" "wait_for_controlplane" {
# #   create_duration = "90s"
  
# #   depends_on = [talos_machine_configuration_apply.controlplane]
# # }


# resource "talos_machine_bootstrap" "controlplane" {
# #   depends_on = [
# #     time_sleep.wait_for_controlplane
# #   ]
#   node                 = local.controlplane_ip
#   endpoint             = local.controlplane_ip
#   client_configuration = talos_machine_secrets.secrets.client_configuration
# }