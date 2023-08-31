

% Apro eeglab e carico (file-->load existing dataset->\...\LO0197_after_baseline_correction.set) cosi da avere altre informazioni che mi torneranno utili
clear;
%inserisci nome bambino/a
codice_bambino = "LO0334";

%inserisci il nome del tipo (es. sociale_sincrono)
tipo_dataset = "sociale_sincrono";

%carico le trial (es. quelle sociali sincrone)
trials = load ("D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\"+tipo_dataset+"\"+tipo_dataset+".mat");


%indica i path dove salvare i risultati
root_ispc = 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_connectivity_analysis_results\ispc';
root_imaginary_coherence = 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_connectivity_analysis_results\imaginary_coherence';


sampling_rate = 1000;
sampling_period = 1/sampling_rate; % spazio temporale tra un campione e un altro
single_trial_duration = 3000; %ms
size_trials_set = size(trials);
number_of_trials = size_trials_set(2) / single_trial_duration;

%mi riporto le trials nella forma NChannel x LunghezzaTrial x NumeroTrials
%con cui sono più a mio agio
trials = double(trials.('trials_'+tipo_dataset)); 
trials = reshape(trials, 128, single_trial_duration, []);


[number_of_channels, length_of_single_trial, number_of_trials] = size(trials);




%{

    Adesso applico a tutte le trials (con stimolo fermo + stimolo movimento) il filtro Laplaciano al fine di
    rimuovere la volume conduction

%}

channel_trials_without_volume_conduction = remove_volume_conduction(trials, EEG.chanlocs);


%{

 Adesso che ho rimosso la volume conduction posso calcolare le N all-to-all
 connectivity matrix usando l'ISPC dove N sono le frequenze di interesse.

%}

get_all_to_all_ISPC_connectivity(channel_trials_without_volume_conduction, sampling_rate, root_ispc); 


%{

 Senza necessità di rimuovere la volume conduction posso calcolare la
 stessa matrice ma utilizzando l'Imaginary Coherence.

 Computational time on my pc (Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz
 2.80 GHz  16GB RAM Windows 10  NVIDIA GeForce GTX 1050 ):

 137 minutes (2.27 h) for a 128x3000x13 data
 matrix.

%}

mkdir(root_imaginary_coherence);
imaginary_coherence_matrix = get_all_to_all_imaginary_coherence_connectivity(trials, sampling_rate, root_imaginary_coherence);
































