# rtf-usage-script
Script to output current RTF usage data in JSON format.

Automatically ignores monitoring containers and RTF system pods.

The output is intended to be consumed by a downstream application such as Splunk or Elastic for generating usage data charts.

_This script may also be used with self-managed RTF by running on your local workstation or support bastion node, with `kubectl` and `jq` installed and your `KUBE_CONFIG` set appropriately._

## Usage
- Copy `rtf-node-info.sh` onto a controller node in your fabric.
- Ensure the execute bit is set: `chmod u+x rtf-node-info.sh`.
- Log into planet: `sudo gravity enter`
- Run `./rtf-node-info.sh` to generate the output.
- A file named `nodeinfo_<timestamp>.json` will be created with the current usage data.

## Requirements
`jq` [https://stedolan.github.io/jq] must be installed on the host for the script to execute.

## Output

| Field | Description
| --- | --- |
| Name | Name of the application pod |
| Application | Name of the MuleSoft application |
| Business Group ID | Anypoint business group ID |
| Environment ID | Anypoint Environment ID |
| Status | Pod status |
| Started time | Pod started or deployment time |
| CPU millis | vCPU millicores consumed by the Mule application |
| Memory MB | MB of memory consumed by the Mule application |
| Worker node IP | Primary public IP of the worker node |

Example output:
```json
[
  {
    "name": "my-api-euw1-84d499bb57-gzp9t",
    "application": "my-api-euw1",
    "business_group_id": "d4b1562c-aa0c-48b7-9389-be44c58fddd7",
    "environment_id": "55eae73b-b9b5-4adf-a410-29b6d5920112",
    "status": "Running",
    "started_time": "2021-02-23T15:40:55Z",
    "cpu_millis": 500,
    "memory_mb": 1000,
    "worker_node_ip": "172.31.30.156"
  },
  {
    "name": "my-api-euw2-7bd8cc485f-v5d4p",
    "application": "my-api-euw2",
    "business_group_id": "d4b1562c-aa0c-48b7-9389-be44c58fddd7",
    "environment_id": "55eae73b-b9b5-4adf-a410-29b6d5920112",
    "status": "Running",
    "started_time": "2021-02-23T15:41:42Z",
    "cpu_millis": 500,
    "memory_mb": 1000,
    "worker_node_ip": "172.31.45.3"
  }
]
```
