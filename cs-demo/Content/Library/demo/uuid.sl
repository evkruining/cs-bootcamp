########################################################################################################################
#!!
#! @description: generate random id
#!
#! @output uuid: Generated id
#!!#
########################################################################################################################

namespace: io.cloudslang.demo

operation:
    name: uuid

    python_action:
      script: |
        import uuid
        uuid = str(uuid.uuid1())


    outputs:
      - uuid: ${uuid}

    results:
      - SUCCESS