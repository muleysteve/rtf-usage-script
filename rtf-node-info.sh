#!/bin/bash

################################
# RTF NodeInfo Reporting Script
# Author: Steve Roberts
# Issued under MIT License

# Copyright (c) 2021 MuleSoft Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Create output file
fileout="nodeinfo_$(date '+%Y%m%d_%H%M').json"

# Check if JQ is available in the environment
search=("./jq" "jq")

for j in $search; do
  $j --version > /dev/null 2> /dev/null
  if [[ $? -eq 0 ]]; then
  	JQEX=$j
  	break
  fi
done

if [[ -z "$JQEX" ]]; then

	echo "* JQ not found on host (https://stedolan.github.io/jq/) *"
	echo "* Please install JQ to continue"

	exit 1
fi

kubectl get pods --all-namespaces -l type=MuleApplication -o json | $JQEX -r '
def parse_cpu:
	if test("[0-9]*m")
	 then match("([0-9]*)m").captures[0].string|tonumber
	else tonumber|.*1000 end;
def parse_memory:
	if test("[0-9]*Mi")
	  then match("([0-9]*)Mi").captures[0].string|tonumber
	elif test("[0-9]*Gi")
	  then match("([0-9]*)Mi").captures[0].string|tonumber * 1024
	elif test("[0-9]*Ki")
	  then match("([0-9]*)Ki").captures[0].string|tonumber / 1024
	else 0 end;

.items
|map(.spec.containers |= map(select(.name == "app")))
|map(select(.status.conditions[]|select(.type=="Ready" and .status=="True")))
|map ({
	name: .metadata.name,
	application: .metadata.labels.app,
	business_group_id: .metadata.labels.organization,
	environment_id: .metadata.labels.environment,
	status: .status.phase,
	started_time: .status.startTime,
	cpu_millis: .spec.containers[0].resources.limits.cpu|parse_cpu,
	memory_mb: .spec.containers[0].resources.limits.memory|parse_memory,
	worker_node_ip: .status.hostIP
})' > $fileout

echo "Saved output to $fileout"
