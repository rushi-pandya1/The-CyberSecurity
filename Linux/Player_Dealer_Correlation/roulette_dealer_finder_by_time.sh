#!/bin/bash
grep -E "$1*$2" 0310_Dealer_schedule | awk -F " " '{print $1, $2, $5, $6}'
