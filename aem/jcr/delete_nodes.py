#!/usr/bin/env python3
# This script is designed to delete multiple JCR nodes from multiple hosts,
# defined by a YAML config file, via HTTP Request.
# This is the template of the config:
# -
#   hostname: '<hostname_1>'
#   port: '<aem_port>'
#   user: '<user_with_delete_permissions>'
#   password: '<users_password>'
#   nodes:
#     - '<path_to_node1>'
#     - '<path_to_node2>'
#     - '<path_to_node3>'

import re, requests, sys, yaml

try:
    config_file = sys.argv[1]
except IndexError:
    print("usage: delete_nodes.py <config_file>")
    sys.exit()

hosts = yaml.load( open(config_file).read() )

for host in hosts:
    print(f"o {host['hostname']}:{host['port']}")

    for node in host['nodes']:
        url = f"http://{host['hostname']}:{host['port']}{node}"
        print(f"  o {url}")
        try:
            response = requests.post(
                url,
                data={':operation': 'delete'},
                auth=(host['user'], host['password'])
            )
            print(f"    o Response code: {response.status_code}")
            if re.match('200', f"{response.status_code}"):
                print("    o SUCCESS")
            elif re.match('401', f"{response.status_code}"):
                print("    o FAILURE: Authentication Error")
            elif re.match('40[34]', f"{response.status_code}"):
                print("    o FAILURE: Resource Not Found")
        except requests.exceptions.ConnectionError as err:
            print(f"    o FAILURE: Connection Error")
            print(f"    o {err}")
