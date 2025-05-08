set -x
curl -k --location --request POST 'https://ms.vivo.com.br/email/v1/send' --header 'app-key: {{appkey-email}}' --header 'Content-Type: application/json' --raw '{ "from": "monitoracao_ms@telefonica.com", "subject": "Monitoracao MicroServicos", "to": "santos.antonio@telefonica.com", "template": { "templateId": "dynamic-content" }, "text": "Origem = FALE_PF<br>nPerfil do usuario = vivo pre<br>nMotivo do contato = Servicos / Solicitacoes<br>nNome = augusto cesar da encarnaao<br>nEmail = Augusto_pastor@yahoo.com.br<br>nCelular = 21967694154<br>nCPF = 878.385.407-04<br>nAssunto = Servicos<br>nReincidenca = nao<br>nMensagem = Meu chip danificou, estou precisando reativa-lo.<br>n" }'
      PORTAL_AUTOMACAO pcpweb@brtlvlts3995sl ~]$ cat scripts/monitora_restart_pod.sh
kubectl get hpa > TABLE_KUBECTL_GET_HPA.txt
#for APP in `kubectl get deploy | awk '{print $1}' | grep -v NAME | grep -i invoice`
for APP in `kubectl get deploy | awk '{print $1}' | grep -v NAME | grep -vi redis`
do
 LOG=/tmp/LOG_POD_APP_${APP}.`date +%d%m%Y%H%M%S`
 MIN_POD=`grep "${APP} " TABLE_KUBECTL_GET_HPA.txt | awk '{print $4}'`
 MAX_POD=`grep "${APP} " TABLE_KUBECTL_GET_HPA.txt | awk '{print $5}'`
 QTD_REPLICA_ATIVA=`grep "${APP} " TABLE_KUBECTL_GET_HPA.txt | awk '{print $6}'`
 echo -e "\033[40;32;1;1m${APP} \033[m MIN_POD=\033[40;32;1;1m${MIN_POD}\033[m MAX_POD=\033[40;32;1;1m${MAX_POD}\033[m REPLICAS_ATIVAS=\033[40;32;1;1m${QTD_REPLICA_ATIVA=}\033[m "

  kubectl -n producao get pods -o wide -l app=${APP} --sort-by='.status.containerStatuses[0].restartCount' > ${LOG}
  cat ${LOG} | grep -v RESTARTS | \
  while true
   read NAME_POD READY STATUS RESTARTS AGE IP NODE NOMINATED_NODE READINESS_GATES
 do
  if [ ${RESTARTS} -gt 10 ];then

     AAAAMM=`date +%y%m`
     AAMMDDHHMM=`date +%y%m%d%H%M`
   grep ${NAME_POD} /tmp/HISTORICO_${APP}.${AAAAMM}.txt 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      DATA_ULTIMA_CONSULTA=`grep ${NAME_POD} /tmp/HISTORICO_${APP}.${AAAAMM}.txt | tail -1 | cut -f1 -d";"`
     if [ -s /tmp/HISTORICO_${APP}.${AAAAMM}.txt ];then
      QTD_RESTART_ULTIMA_CONSULTA=`grep ${NAME_POD}  /tmp/HISTORICO_${APP}.${AAAAMM}.txt | tail -1 | cut -f4 -d";"`
     else
      QTD_RESTART_ULTIMA_CONSULTA=0
     fi

       if [ ${QTD_RESTART_ULTIMA_CONSULTA} -ne ${RESTARTS} ];then
           INTERVALO=`expr ${AAMMDDHHMM} - ${DATA_ULTIMA_CONSULTA}`
           QTD_RESTART_SOFRIDOS=`expr ${RESTARTS} - ${QTD_RESTART_ULTIMA_CONSULTA}`
          echo "POD ${NAME_POD} sofreu ${QTD_RESTART_SOFRIDOS} RESTARTS nos ultimos ${INTERVALO} minutos "
       fi
    echo "`date +%y%m%d%H%M`;${NAME_POD};${NODE};${RESTARTS};${AGE} " >> /tmp/HISTORICO_${APP}.${AAAAMM}.txt
   else
    echo "`date +%y%m%d%H%M`;${NAME_POD};${NODE};${RESTARTS};${AGE} " >> /tmp/HISTORICO_${APP}.${AAAAMM}.txt
   fi
  fi
done
done
rm /tmp/LOG_POD_APP_*
