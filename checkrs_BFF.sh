#!/bin/bash
echo "Monitoramento de subidas e alteracoes no ambiente, qualquer subida somente com CRQ e formalizada ao PCP"
echo "-----------------------------"
#kubectl get rs -n production | awk '{print $1} {printf "%s ",$5}' | grep ^[1-9][1-9]m
echo "check RS in last minutes:"
#kubectl get rs -n production | awk '{print $1} {printf "%s ",$5}' | grep ^[1-9][1-9]m
A=$(sudo kubectl get rs -n prd | grep  '.[0-9][0-9]h')
C=$(sudo kubectl get rs -n prd | grep  '.[0-9][0-9]m')
#A=$(kubectl get rs -n ms | awk '{print $1} {printf "%s ",$5}' | grep ^[0-9][0-9]m)
#=$(kubectl get rs -n ms | awk '{print $1} {printf "%s ",$5}' | grep ^[0-9][0-9][0-9]m)
echo "subidas nas ultimas horas"
echo "$A"
echo "subida nos ultimos minutos"
echo "$C"
echo "."
echo ".."
B=$(sudo kubectl get rs -n prd | awk '{printf $1} {print "%s ",$5}' | grep ^[1-9][1-9]h)
D=$(sudo kubectl get rs -n prd-front | awk '{printf $1} {print "%s ",$5}' | grep ^[1-9][1-9]h)
echo "Validação de ultimos deploys - check ReplicaSet in last hours:"
echo "$B"
echo "$D"


exit 0
