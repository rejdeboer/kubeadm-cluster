#!/usr/bin/env bash
ssh ubuntu@$(terraform -chdir=terraform output -raw master_node_ip) -i cluster-key.pem
