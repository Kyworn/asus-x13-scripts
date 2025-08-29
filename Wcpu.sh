#!/bin/bash

# --- GESTION AUTOMATIQUE DE SUDO ---
SUDO_CMD=""
if [ "$EUID" -ne 0 ]; then
  SUDO_CMD="sudo"
fi

PROFILE=$1
if [ -z "$PROFILE" ]; then
  PROFILE="status"
fi

case $PROFILE in
  status)
    echo "Vérification du profil CPU actuel..."
    
    CURRENT_STAPM_WATTS=$($SUDO_CMD ryzenadj --info 2>/dev/null | grep "STAPM LIMIT" | awk -F'|' '{print $3}' | sed 's/ //g')

    if [ -z "$CURRENT_STAPM_WATTS" ]; then
      echo "Erreur : Impossible de lire les informations de ryzenadj."
      exit 1
    fi
    
    # --- MODIFICATION POUR ENLEVER LA DÉPENDANCE À 'bc' ---
    # 1. On extrait la partie entière du nombre (ex: "55.000" -> "55")
    INTEGER_WATTS=$(echo "$CURRENT_STAPM_WATTS" | cut -d. -f1)
    # 2. On multiplie l'entier par 1000 en pur Bash
    CURRENT_STAPM_MW=$((INTEGER_WATTS * 1000))

    case $CURRENT_STAPM_MW in
      60000) echo "Profil Actuel : 🚀 Performance (60W)" ;;
      55000) echo "Profil Actuel : ⚙️ Standard (55W)" ;;
      45000) echo "Profil Actuel : ⚖️ Moyen (45W)" ;;
      25000) echo "Profil Actuel : 🌱 Éco (25W)" ;;
      10000) echo "Profil Actuel : 🔋 Ultra (10W)" ;;
      *) echo "Profil Actuel : 🛠️ Personnalisé (Limite STAPM : ${CURRENT_STAPM_WATTS}W)" ;;
    esac
    ;;

standard)
    echo "Application du profil 'Standard'..."
    $SUDO_CMD ryzenadj --stapm-limit=50000 --fast-limit=60000 --slow-limit=55000 --apu-slow-limit=50000 --vrm-current=40000 --vrmsoc-current=15000 --vrmmax-current=80000 --vrmsocmax-current=20000 --tctl-temp=90
    echo "Profil 'Standard' appliqué."
    ;;

perf)
    echo "Application du profil 'Performance'..."
    $SUDO_CMD ryzenadj --stapm-limit=60000 --fast-limit=70000 --slow-limit=65000 --apu-slow-limit=60000 --vrm-current=42000 --vrmsoc-current=18000 --vrmmax-current=90000 --vrmsocmax-current=23000 --tctl-temp=95
    echo "Profil 'Performance' appliqué."
    ;;

mid)
    echo "Application du profil 'Moyen'..."
    $SUDO_CMD ryzenadj --stapm-limit=40000 --fast-limit=45000 --slow-limit=42000 --apu-slow-limit=40000 --vrm-current=30000 --vrmsoc-current=12000 --vrmmax-current=60000 --vrmsocmax-current=15000 --tctl-temp=88
    echo "Profil 'Moyen' appliqué."
    ;;

eco)
    echo "Application du profil 'Éco'..."
    $SUDO_CMD ryzenadj --stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --apu-slow-limit=25000 --vrm-current=20000 --vrmsoc-current=10000 --vrmmax-current=30000 --vrmsocmax-current=15000 --tctl-temp=85
    echo "Profil 'Éco' appliqué."
    ;;

ultra)
    echo "Application du profil 'Ultra'..."
    $SUDO_CMD ryzenadj --stapm-limit=10000 --fast-limit=10000 --slow-limit=10000 --apu-slow-limit=10000 --vrm-current=15000 --vrmsoc-current=10000 --vrmmax-current=20000 --vrmsocmax-current=15000 --tctl-temp=80
    echo "Profil 'Ultra' appliqué."
    ;;
  *)
    echo "Usage: $0 {perf|mid|eco|ultra|standard|status}"
    echo "Si aucun argument n'est fourni, 'status' est utilisé par défaut."
    exit 1
    ;;
esac
