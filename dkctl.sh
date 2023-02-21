#!/bin/sh

set -e

# 加载框架
. "$(dirname $(realpath $0))/libshfw/framework-entrance.sh"

# 处理命令行参数
_OPTION_TEMP=$(getopt --unquoted --options "" --longoptions "kubeconfig-list:,kubecontext-list:,debug" -n "$0" -- "$@")
log_debug "command line options: ${_OPTION_TEMP}"
set -- $_OPTION_TEMP
while true; do
    case $1 in
    --kubeconfig-list)
        __KUBECONFIG_LIST=$2
        shift 2
        ;;
    --kubecontext-list)
        __KUBECONTEXT_LIST=$2
        shift 2
        ;;
    --debug)
        __DEBUG=1
        shift 1
        ;;
    --)
        shift
        __SUBCOMMAND=$1
        log_debug "subcommand: ${__SUBCOMMAND}"
        ;;
    *) break ;;
    esac
done

# 在集群中部署 Agent 服务
_deploy() {
    IFS=,
    for i in $__KUBECONFIG_LIST; do
        log_info $i
        export KUBECONFIG="$i"
        kubectl create namespace detector-k --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n detector-k apply -f ./resource/
        kubectl -n detector-k get service
    done
}

# 等待 Agent 正常运行
# 等待 Agent 获取 External IP 地址
_status() {
    IFS=,
    for i in $__KUBECONFIG_LIST; do
        log_info $i
        export KUBECONFIG="$i"
        # eip_status=$(kubectl -n detector-k get service detector-service -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
        kubectl -n detector-k get service detector-service
        # pod_status=$(kubectl get pods -l app=detector -o jsonpath="{.items[0].metadata.name}")
        kubectl get pods -l app=detector
    done
}

# 开始执行检测
_execute() {
    IFS=,
    for i in $__KUBECONFIG_LIST; do
        log_info $i
        export KUBECONFIG="$i"
        EIP=$(kubectl -n detector-k get service detector-service -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
        for j in $__KUBECONFIG_LIST; do

            if [ "$(basename $j)" = "$(basename $i)" ]; then
                log_warn "$(basename $j) => $(basename $i)"
                continue
            else
                log_info "$(basename $j) => $(basename $i)"
            fi
            export KUBECONFIG="$j"
            detector_pod=$(kubectl get pods -l app=detector -o jsonpath="{.items[0].metadata.name}")
            out=$(kubectl exec ${detector_pod} -- nc -v -z $EIP 80)
            log_info $(basename $j) = : echo $? >$(basename $i)
        done
    done
}

# 运行命令

_${__SUBCOMMAND}