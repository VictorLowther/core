
name "proxy-client"
description "Proxy Client Role - Configures the system to point at the proxy server"
run_list(
         "recipe[rebar-squid::client]"
)
default_attributes()
override_attributes()

