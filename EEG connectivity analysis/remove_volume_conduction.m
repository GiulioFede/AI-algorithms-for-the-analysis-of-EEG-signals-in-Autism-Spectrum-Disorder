
%{

    Questa funzione prende in ingresso le trials di ogni canale e rimuove
    la volume conduction applicando il filtro Laplaciano

%}


function channel_trials_without_volume_conduction = remove_volume_conduction(channels_trials, chanlocs)

    % rimuovo/mitigo la volume conduction per ogni istante di tempo per
    % ogni trial di ogni canale
    channel_trials_without_volume_conduction = laplacian_perrinX(channels_trials, [chanlocs.X], [chanlocs.Y], [chanlocs.Z] );

end