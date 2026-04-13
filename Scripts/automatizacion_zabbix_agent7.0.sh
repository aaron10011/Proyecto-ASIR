#!/bin/bash

# =====================================================
# Script de instalación de Zabbix Agent 7.0
# =====================================================

# Ruta del archivo de configuración del agente
CONF="/etc/zabbix/zabbix_agentd.conf"

# Verificamos que se ejecute el script como root
if [ "$EUID" -ne 0 ]; then
    echo "DEBES DE EJECUTAR EL SCRIPT COMO ROOT, SALIENDO..."
    exit 1
fi

# 1º – Instalamos el repositorio del Zabbix Agent

echo ""
echo "=== PASO 1: Instalando repositorio de Zabbix 7.0 ==="

wget -q https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb -O /tmp/zabbix-release.deb
dpkg -i /tmp/zabbix-release.deb
apt update -q		# -q Lo ponemos para que sea silenciosa la salida

echo "Repositorio instalado."

# 2º – Instalamos el agente

echo ""
echo "=== PASO 2: Instalando zabbix-agent ==="

apt install -y zabbix-agent

echo "Agente instalado."

# 3º – Preguntamos la IP del servidor Zabbix

echo ""
echo "=== PASO 3: Configurar IP del servidor Zabbix ==="

read -p "Introduce la IP del servidor Zabbix: " ip_serv

# Cambiamos la IP en las dos líneas del archivo de configuración:
# Server --> chequeos pasivosn(el servidor pregunta al agente)
# ServerActive --> chequeos activos (el agente envía datos al servidor)
sed -i "s/^Server=.*/Server=$ip_serv/" $CONF
sed -i "s/^ServerActive=.*/ServerActive=$ip_serv/" $CONF

echo "IP configurada: $ip_serv"

# 4º – Preguntamos el Hostname

echo ""
echo "=== PASO 4: Configurar Hostname en el agente ==="

read -p "Introduce el Hostname que desea para este equipo: " hostname

sed -i "s/^Hostname=.*/Hostname=$hostname/" $CONF

echo "Hostname configurado: $hostname"

# 5º – Preguntamos si se quiere cambiar el Timeout

echo ""
echo "=== PASO 5: Timeout del agente (valor por defecto: 3 segundos) ==="

read -p "¿Quieres cambiar el Timeout? (s/n): " respuesta

if [ "$respuesta" = "s" ]; then
    read -p "Introduce el nuevo Timeout (número entre 1 y 30): " timeout

    # Comprobamos que el número esté entre 1 y 30
    if [ "$timeout" -ge 1 ] && [ "$timeout" -le 30 ]; then
        echo "Timeout=$timeout" >> $CONF
        echo "Timeout configurado a $timeout segundos."
    else
        echo "Valor fuera de rango. Se mantiene el Timeout por defecto."
    fi
else
    echo "Se mantiene el Timeout por defecto (3 segundos)."
fi

# 6º – Preguntamos si se quiere añadir un UserParameter

echo ""
echo "=== PASO 6: UserParameter (chequeo personalizado) ==="

read -p "¿Quieres añadir un UserParameter? (s/n): " respuesta_param

if [ "$respuesta_param" = "s" ]; then
    read -p "Introduce la clave del UserParameter (ejemplo: test.asir.proyec): " clave
    read -p "Introduce la ruta completa del script (ejemplo: /home/scripts/prueba.sh): " ruta

    # Añadimos la línea UserParameter al final del archivo de configuración
    echo "UserParameter=$clave,$ruta" >> $CONF

    echo "UserParameter añadido: $clave - $ruta"
else
    echo "No se añade ningún UserParameter."
fi

# INICIAMOS EL SERVICIO

echo ""
echo "=== Iniciando el servicio zabbix-agent ==="

systemctl enable zabbix-agent
systemctl restart zabbix-agent

echo "Servicio iniciado correctamente."

# RESUMEN FINAL DE LA CONFIGURACIÓN AÑADIDA

echo ""
echo "=============================="
echo " CONFIGURACIÓN COMPLETADA"
echo "=============================="
echo " Servidor Zabbix : $ip_serv"
echo " Hostname        : $hostname"
echo " Timeout         : $timeout"
echo " Clave UP        : $clave"
echo " Ruta UP         : $ruta"
echo " Archivo conf    : $CONF"
echo "=============================="
