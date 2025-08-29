#!/bin/bash

# Fonction pour obtenir le mode GPU actuel
get_current_mode() {
    # On exécute la commande et on retourne sa sortie
    supergfxctl -g
}

# Fonction pour changer le mode GPU
switch_mode() {
    local mode_to_set="$1"

    # On utilise un 'case' pour vérifier si le mode est valide
    # C'est plus propre que plusieurs 'if || ...'
    case "$mode_to_set" in
      Integrated|Hybrid|AsusMuxDgpu)
        # Si le mode est valide, on exécute la commande de changement
        echo "Changement vers le mode $mode_to_set en cours..."
        supergfxctl -m "$mode_to_set"
        
        # On attend une seconde pour laisser le temps au changement de se faire
        sleep 1 
        
        # On affiche un message de confirmation avec le nouveau mode
        echo "Le mode est maintenant : $(get_current_mode)"
        ;;
      *)
        # Si le mode n'est pas dans la liste, on affiche une erreur
        echo "Erreur : Mode '$mode_to_set' invalide."
        echo "Options valides : Integrated, Hybrid, AsusMuxDgpu"
        exit 1 # On quitte avec un code d'erreur
        ;;
    esac
}

# --- Logique principale du script ---

# Si un argument est passé au script (ex: ./Gpu.sh Hybrid)
if [[ -n "$1" ]]; then
    # On appelle la fonction pour changer le mode
    switch_mode "$1"
else
    # Si aucun argument n'est passé, on affiche juste le statut actuel
    echo "Mode GPU actuel : $(get_current_mode)"
fi
