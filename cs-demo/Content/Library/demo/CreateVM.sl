namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1295-capa1user"
    - datacenter: Capa1 Datacenter
    - password: Automation123
    - image: Ubuntu
    - folder: Students/Erwin
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: '${"Erwin-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '13'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: FAILURE
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: FAILURE
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: FAILURE
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 32
        y: 113
      substring:
        x: 179
        y: 106
        navigate:
          52b12ff2-0868-6e2c-4ef0-0ed791dd77ae:
            targetId: efed74c5-c014-f270-a76a-c4384bf989e1
            port: FAILURE
      clone_vm:
        x: 349
        y: 101
        navigate:
          a83bc1a0-9df1-aadb-3d24-1dc604522c6c:
            targetId: efed74c5-c014-f270-a76a-c4384bf989e1
            port: FAILURE
      power_on_vm:
        x: 500
        y: 98
        navigate:
          39260ca1-a119-0115-1e2e-a2f7f3cd9c0f:
            targetId: efed74c5-c014-f270-a76a-c4384bf989e1
            port: FAILURE
      wait_for_vm_info:
        x: 501
        y: 297
        navigate:
          747fd927-9ba8-f0e9-acc8-8821b49ed94d:
            targetId: a1565249-5f10-4416-98bf-0f2c5f5d6cc3
            port: SUCCESS
          f634617e-fa96-974d-3012-2146d87fe5aa:
            targetId: efed74c5-c014-f270-a76a-c4384bf989e1
            port: FAILURE
    results:
      SUCCESS:
        a1565249-5f10-4416-98bf-0f2c5f5d6cc3:
          x: 687
          y: 299
      FAILURE:
        efed74c5-c014-f270-a76a-c4384bf989e1:
          x: 354
          y: 287
